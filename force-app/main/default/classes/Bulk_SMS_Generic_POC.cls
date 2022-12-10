public class Bulk_SMS_Generic_POC {
    public static void sendBulkSMS_Common(String smsType, List<String> mobileNumbers, List<String> dynamicVars)
    {
        //To get Authorization Details
        SMS_API_Setup__mdt auth = [SELECT Username__c, Password__c, URL__c FROM SMS_API_Setup__mdt WHERE DeveloperName =:'SMS_API'];
        
        CredentialsWrapper objCredential = new CredentialsWrapper();
        objCredential.user=auth.Username__c;
        objCredential.password=auth.Password__c;      
        
        //Waiting for SMS Template details from Reva Team.
        String strURL = 'https://api.oot.bz/api/v1/one2Many';
        
        List<RecepientsWrapper> recpient = new List<RecepientsWrapper>();
        for(String mobileNumber: mobileNumbers){
            RecepientsWrapper objRecpient = new RecepientsWrapper();
            objRecpient.mobile = mobileNumber;
            recpient.add(objRecpient);
        }
        
        //To get SMS Types
        SMS_Types__mdt smsTypeAPI = [SELECT Dlt_Content_Id__c, Sender__c, Unicode__c, SMS_Template__c FROM SMS_Types__mdt WHERE DeveloperName =:smstype];
        String varSMSTemplate = smsTypeAPI.SMS_Template__c;
        system.debug(varSMSTemplate);
        String smsText = '';

        if(smsType == 'Counsellor_Online_Paid_Application'){   
            
            
            //Dynamically passes the variable to sms template text
            Integer searchFrom = 0;
            
            Integer idx = 0;
            Integer openBracePos = varSMSTemplate.indexOf('{', searchFrom);
            while (openBracePos != -1) {
                smsText+= varSMSTemplate.substring(searchFrom, openBracePos) + dynamicVars[idx];
                searchFrom = varSMSTemplate.indexOf('}', searchFrom) + 1;
                openBracePos = varSMSTemplate.indexOf('{', searchFrom);
                idx++;
            }   
            smsText+= varSMSTemplate.substring(searchFrom);
        } else if(smsType == 'Application_Number'){
            //Dynamically passes the variable to sms template text
            
            Integer applicationSearchFrom = 0;
            Integer applicationIdx = 0;
            Integer applicationOpenBracePos = varSMSTemplate.indexOf('{', applicationSearchFrom);
            while (applicationOpenBracePos != -1) {
                smsText+= varSMSTemplate.substring(applicationSearchFrom, applicationOpenBracePos) + dynamicVars[applicationIdx];
                applicationSearchFrom = varSMSTemplate.indexOf('}', applicationSearchFrom)+1;
                applicationOpenBracePos = varSMSTemplate.indexOf('{', applicationSearchFrom);
                
                
            }   
            smsText+= varSMSTemplate.substring(applicationSearchFrom);        
        }  

        OptionsWrapper objExtraWrapper = new OptionsWrapper();
        objExtraWrapper.dltContentId =smsTypeAPI.Dlt_Content_Id__c;
        
        SMSMainWrapper objSmsMainWrapper = new SMSMainWrapper();
        objSmsMainWrapper.credentials = objCredential;
        objSmsMainWrapper.sender = smsTypeAPI.Sender__c;
        objSmsMainWrapper.unicode = smsTypeAPI.Unicode__c; //unicode should be false
        objSmsMainWrapper.messageText =smsText;
        objSmsMainWrapper.options = objExtraWrapper; 
        objSmsMainWrapper.recpients =recpient;
        
        
        Blob headerValue = Blob.valueOf(auth.Username__c+ ':' + auth.Password__c);
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        String JSON = JSON.serialize(objSMSMainWrapper);
        //Replacing the "sender" keyword to "from" in JSON 
        JSON = JSON.replaceAll('"sender":', '"from":');
        
        System.debug('JSON=='+JSON);
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        httpReq.setEndpoint(strURL);
        httpReq.setHeader('Authorization', authHeader);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setMethod('POST');
        //httpReq.setTimeout(120000);
        httpReq.setBody(JSON);
        httpRes = http.send(httpReq);
       
        System.debug('Response Body POST=='+httpRes.getBody());
        System.debug('Response Code POST=='+httpRes.getStatusCode());
        System.debug('Response Status POST=='+httpRes.getStatus());


    }
       public class SMSMainWrapper
    {
        public CredentialsWrapper credentials; 
        public String messageText;
        public List<RecepientsWrapper> recpients;
        public String sender;  //using sender string instead of from where from is a define token
        public Boolean unicode;
        public OptionsWrapper options;
          
        
    }
    public class OptionsWrapper{
        public String dltContentId;
    }
    public class CredentialsWrapper{
        public String user;
        public String password;
    }    
    public class RecepientsWrapper{
        public String mobile;
    }
    public static void sendBulkSMS_Personalized(String smsType, Map<String, List<String> > phoneWithDynamicVariables ){
        SMS_API_Setup__mdt auths = [SELECT Username__c, Password__c, URL__c FROM SMS_API_Setup__mdt WHERE DeveloperName =:'SMS_API'];
        
        CredentialWrapper objeCredential = new CredentialWrapper();
        objeCredential.user=auths.Username__c;
        objeCredential.password=auths.Password__c;      
        
        //Waiting for SMS Template details from Reva Team.
        String strgURL = auths.URL__c;

        SMS_Types__mdt smsTypeAPIs = [SELECT Dlt_Content_Id__c, Sender__c, Unicode__c, SMS_Template__c FROM SMS_Types__mdt WHERE DeveloperName =:smstype];
        String varSMSTemplate = smsTypeAPIs.SMS_Template__c;
       
        List<ShortMessageWrapper> shortMsgs = new List<ShortMessageWrapper>();
       
        for(string phoneKey: phoneWithDynamicVariables.keySet()){
        
       system.debug('Each phone and msg'+phoneKey+' : '+phoneWithDynamicVariables.get(phoneKey));
       String smsText = '';
            
            //Dynamically passes the variable to sms template text
            Integer searchFrom = 0;
            
            Integer idx = 0;
            Integer openBracePos = varSMSTemplate.indexOf('{', searchFrom);
            while (openBracePos != -1) {
                smsText+= varSMSTemplate.substring(searchFrom, openBracePos) + phoneWithDynamicVariables.get(phoneKey)[idx];

                searchFrom = varSMSTemplate.indexOf('}', searchFrom) + 1;
                openBracePos = varSMSTemplate.indexOf('{', searchFrom);
                idx++;
            }   
            smsText+= varSMSTemplate.substring(searchFrom);
           
            ShortMessageWrapper shortMsg = new ShortMessageWrapper();
            shortMsg.recipient = phoneKey;
            system.debug('m1'+shortMsg.recipient);
            shortMsg.dltContentId= smsTypeAPIs.Dlt_Content_Id__c;
            shortMsg.message= smsText;
            system.debug('m2'+shortMsg.message);
           shortMsgs.add(shortMsg);  
           
            system.debug('AllSMS'+shortMsgs);
        }
        MainSMSWrapper objMainSMSWrapper = new MainSMSWrapper();
        objMainSMSWrapper.credentials = objeCredential;
        objMainSMSWrapper.sender = smsTypeAPIs.Sender__c;
        objMainSMSWrapper.unicode = smsTypeAPIs.Unicode__c;
        objMainSMSWrapper.shortMessages =shortMsgs;
        system.debug('2'+shortMsgs);
        
        Blob headerValues = Blob.valueOf(auths.Username__c+ ':' + auths.Password__c);
        String authHeaders = 'Basic ' + EncodingUtil.base64Encode(headerValues);
        
        String JSON = JSON.serialize(objMainSMSWrapper);
        //Replacing the "sender" keyword to "from" in JSON 
        JSON = JSON.replaceAll('"sender":', '"from":');
        
        System.debug('JSON=='+JSON);
        
        Http http = new Http();
        HttpRequest httpRequ = new HttpRequest();
        HttpResponse httpResp = new HttpResponse();
        httpRequ.setEndpoint(strgURL);
        httpRequ.setHeader('Authorization', authHeaders);
        httpRequ.setHeader('Content-Type', 'application/json');
        httpRequ.setHeader('Accept', 'application/json');
        httpRequ.setMethod('POST');
        //httpReq.setTimeout(120000);
        httpRequ.setBody(JSON);
        httpResp = http.send(httpRequ);
       
        System.debug('Response Body POST=='+httpResp.getBody());
        System.debug('Response Code POST=='+httpResp.getStatusCode());
        System.debug('Response Status POST=='+httpResp.getStatus());

    }
    public class MainSMSWrapper
    {
        public CredentialWrapper credentials; 
        public String sender;  //using sender string instead of from where from is a define token
        public Boolean unicode;
        public List<ShortMessageWrapper> shortMessages;         
        
    }

    public class CredentialWrapper{
        public String user;
        public String password;
    } 
    public class ShortMessageWrapper{
        public String dltContentId;
        public String message;
        public String recipient;
    }     
}