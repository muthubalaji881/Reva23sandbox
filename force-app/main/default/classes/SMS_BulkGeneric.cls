public without sharing class SMS_BulkGeneric {
    public static HttpResponse sendBulkSMS_Personalized(String smsType, Map<String, List<String> > phoneWithDynamicVariables ){
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
            if(smsText.Contains(string.ValueOf('/r'))==true){           
                string regExp = string.ValueOf('/r');
                string replacement = '\r\n' ;

                smsText = smsText.replaceAll(regExp, replacement);
                system.debug(smsText);
            }
                else{
                    smsText=smsText;
                } 
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
        return httpResp;

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