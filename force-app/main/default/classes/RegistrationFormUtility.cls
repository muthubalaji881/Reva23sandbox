public without sharing class RegistrationFormUtility {
    public static final String REVA_UNIVERSITY = 'REVA University';
    private static final String FEE_TYPE_APPLICATION = 'Application Fee';
    private static final String ENROLMENT_YEAR_CMDT_NAME = 'Enrolment_Year';
    private static final String APPLICATION_PORTAL_NAME = 'Application_Portal_Name';

    /* One Invocable method that will be called from the flow. 
    Based on the Invocation Type the respective methods are called
    UtilityRequest is the wrapper to receive the inputs from the flow - wherever required
    UtilityResponse is the wrapper to send the output back to the flow -wherever required*/
    @InvocableMethod(label='Registration Form Utility Invocation')
    public static List<UtilityResponse> decideByInvocation(List<UtilityRequest> uRequests){
        UtilityRequest uReq = uRequests[0];
        List<UtilityResponse> uResponses = new List<UtilityResponse>();
        Switch on uReq.invocationType{
            when 'GENERATE_OTP'{
                uResponses = generateOTP();
            }
            When 'SEND_OTP_VIA_SMS'{
                List<String> requiredVariables = new List<String>{uReq.generatedOTP, uReq.purpose, String.valueOf(uReq.otpValidTill)};
                    Boolean countryCode;
                	string mobilePhone;
                
                if(countryCode=uReq.mobilePhone.contains('+91-')){
                     mobilePhone = uReq.mobilePhone.remove('+91-');
                }else{
                    mobilePhone = uReq.mobilePhone;
                }
                 SMS_Generic.sendSMS(uReq.smsType,mobilePhone, requiredVariables);
            }
            When 'LEAD_UPDATION_PRIOR_CONVERSION'{
                uResponses = updateLeadPriorConversion(uReq.leadId);
            }
            When 'LEAD_CONVERSION'{
                uResponses = convertLead(uReq.leadId,uReq.feeMasterId);
            }
/*             When 'SEND_APPLNO_VIA_SMS'{
                List<String> requiredVariables = new List<String>{uReq.applNo};
                SMS_Generic.sendSMS(uReq.smsType,uReq.mobilePhone, requiredVariables);
            } */
            When 'EMAIL_VERIFICATION'{
                uResponses = ValidateInputEmail(uReq.email);
            }            
        }        
        return uResponses;
    }
    @future(Callout=true)
    public static void futureSMS(String smsType, String Phone,List<String> requiredVariables){
        SMS_Generic.sendSMS(smsType,Phone,requiredVariables);
    }

    
    public static List<UtilityResponse> ValidateInputEmail(string email) {
        UtilityResponse uR = new UtilityResponse();
        List<UtilityResponse> uResponses = new List<UtilityResponse>();
        if(Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]{2,8}+.[a-zA-Z]{2,8}', email)
            ||  Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]{2,8}+.[a-zA-Z]{2,8}+.[a-zA-Z]{2,8}', email))
        {                        
            system.debug('valid Email');
            uR.message = 'Success';
        }
        else {
            system.debug('invalid email');
            uR.message = 'Failure';
        }
    
        uResponses.add(uR);
        return uResponses;
    }

    /*This method generates the OTP. Length of the OTP and validity time is determined by the Custom Metadata Type Applicant_Registration_OTP */
    public static List<UtilityResponse> generateOTP(){

        OTP_Config__mdt otpConfig = OTP_Config__mdt.getInstance('Applicant_Registration_OTP');
        Decimal otpLength = (Decimal) otpConfig.OTP_Length__c; //4
        Decimal otpValidityInSec = (Decimal) otpConfig.OTP_Validity__c; //600seconds
        
        UtilityResponse uR = new UtilityResponse();
        List<UtilityResponse> uResponses = new List<UtilityResponse>();
        String randomString = string.valueof(Math.abs(Crypto.getRandomLong()));
        uR.generatedOTP = randomString.substring(0, otpLength.intValue()); 
        DateTime currentDt = system.now();
        uR.otpValidTill = currentDt.addSeconds(otpValidityInSec.intValue());

        uResponses.add(uR);
        return uResponses;
    }
    
    /* Schools and Program picklist on Screen 3. Cannot be done using flow screen component. Hence used an lwc */
    @AuraEnabled(cacheable=true)
    public static List<Fee_Master__c> getSchoolPrograms() {
        String enrolmentYear = getCurrentEnrolmentYear();
        system.debug(enrolmentYear);

        return [select School_Name__c, Program_Name_Display__c 
                from Fee_Master__c
                where Fee_Type__c = :FEE_TYPE_APPLICATION
                and Enrolment_Year__c = :enrolmentYear
                order by School_Name__c, Program_Name_Display__c];
    }

    private static String getCurrentEnrolmentYear() {
         return [select Text_Value__c from General_Setting__mdt where DeveloperName = :ENROLMENT_YEAR_CMDT_NAME limit 1].Text_Value__c;
    }

    private static String getPortalName() {
        return [select Text_Value__c from General_Setting__mdt where DeveloperName = :APPLICATION_PORTAL_NAME limit 1].Text_Value__c;
   }

    @AuraEnabled(cacheable=true)
    public static String getSiteURL() {
        String portalName = getPortalName();
        Site mySite = [select Id from Site where Name =:portalName];
        SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId=:mySite.Id];
        system.debug(mySiteDetail);
        if(mySiteDetail.SecureURL.endswith('/')){
            return mySiteDetail.SecureURL.removeEnd('/');
        }
        return mySiteDetail.SecureUrl;
    }

    /* This methods updates the application number and the program batch on lead prior to its conversion.
        This will enable easy mapping of batch to contact and also short window just create application number in sequence
        and release the record. Later actual conversion happens. Application number is only generated here 
        but an actual application record is not created in this mehtod. it happens post conversion */

    public static List<UtilityResponse> updateLeadPriorConversion(String leadId){

        String feeMasterCategory;
        UtilityResponse uResp = new UtilityResponse();
        List<UtilityResponse> uResponses = new List<UtilityResponse>();
        List<Lead> leads = [Select  School__c, Program_Name_Display__c, Category__c,Assigned_Users__C from lead where id =:leadId];
        if(leads.size()>0){
            Lead leadToBeUpdated = leads[0];
            if(leadToBeUpdated.Category__c =='Karnataka'|| leadToBeUpdated.Category__c=='Non-Karnataka'){
                feeMasterCategory ='Indian (SAARC)';
                }else{
                    feeMasterCategory = leadToBeUpdated.Category__c;
                }
            List<Fee_Master__c> feeMasters = [select Program_Batch__c, Application_Number_Prefix__c 
                                                from Fee_Master__c where Program_Name_Display__c=:leadToBeUpdated.Program_Name_Display__c
                                                and School_Name__c=:leadToBeUpdated.School__c 
                                                and Applicant_Category__c =:feeMasterCategory];
            Site admissionsSite =[Select Id, GuestRecordDefaultOwnerId from Site where Name=:getPortalName()];
            if(feeMasters.size()>0){
                Fee_Master__c feeMaster = feeMasters[0];
                system.debug(feeMaster);
                uResp.feeMasterId = feeMaster.Id;
                leadToBeUpdated.Program_Batch__c = feeMaster.Program_Batch__c;
                leadToBeUpdated.Application_Number__c = feeMaster.Application_Number_Prefix__c+RegistrationProcessUtility.generateApplNoSequence(feeMaster.Application_Number_Prefix__c);
                
                //Lead owner to be updated back to portal owner as the Lead Conversion is failing when the owner is the COunselor


                leadToBeUpdated.OwnerId = admissionsSite.GuestRecordDefaultOwnerId;
                leadToBeUpdated.Assigned__C = false; 

                update leadToBeUpdated;
                system.debug(leadToBeUpdated);
            }else{
                //handle error
            }                                            
        }else{
            //handle error
        }
        uResponses.add(uResp);
        return uResponses;
    }
    
    public static List<UtilityResponse> convertLead(String leadId, String fmID){

        UtilityResponse uResp = new UtilityResponse();
        List<UtilityResponse> uResponses = new List<UtilityResponse>();
        Lead tempLead = [select LastName, Application_Number__c, FirstName,Salutation, middleName,Country_Code__C from Lead where Id=:leadId];
        Id applicantRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Id houseHoldRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Account tempAccount = new Account(Name = tempLead.Application_Number__c+' - '+ tempLead.FirstName+' '+ tempLead.LastName, RecordTypeId = houseHoldRecordTypeId);
        insert tempAccount;

        Contact tempContact = new Contact(LastName = tempLead.LastName, FirstName= tempLead.firstName, 
                                            middleName = tempLead.middleName, Salutation = tempLead.Salutation, RecordTypeId = applicantRecordTypeID, AccountId = tempAccount.Id, Country_Code__c = tempLead.Country_Code__C);
        insert tempContact;

        LeadStatus convertStatus = [Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        Database.LeadConvert leadToBeConverted = new Database.LeadConvert();
        leadToBeConverted.setLeadId(leadId);
        leadToBeConverted.setConvertedStatus(convertStatus.MasterLabel);
        leadToBeConverted.setDoNotCreateOpportunity(true);
        leadToBeConverted.setContactId(tempContact.Id);
        leadToBeConverted.setAccountId(tempAccount.Id);
        Database.LeadConvertResult lcr=Database.convertLead(leadToBeConverted);

        ID contactId = lcr.getContactId(); //Default recordType for Guest User is given as Applicant
        Contact contact = [Select Program_Batch__c, Primary_Academic_Program__c,Program_Batch__r.hed__Account__r.Name, Application_Number__c,FirstName, LastName, 
                            Program_Batch__r.hed__Account__c,Program_Batch__r.hed__Account__r.ParentId, Program_Batch__r.Name, Assigned_Users__c
                             from contact where id =:contactId];
          
        contact.Primary_Academic_Program__c = contact.Program_Batch__r.hed__Account__c;
        contact.School__c = contact.Program_Batch__r.hed__Account__r.ParentId;




         if(contact.Assigned_Users__C != null){
            contact.OwnerId = contact.Assigned_Users__C?.right(18);
            contact.Assigned__c = true; 
        } 
        
        update contact;
        uResp.applicantContactId = contact.Id;

        hed__Application__c app = new hed__Application__c();
        app.hed__Applicant__c = contactId;
        app.hed__Initial_Creation_Date__c = Date.today(); //Date time the application is initially created.
        app.hed__Application_Status__c = 'Started';
        app.hed__Applying_To__c = contact.Primary_Academic_Program__c;
        app.Application_Number__c = contact.Application_Number__C;
        system.debug(app.Application_Number__c);
        insert app;
        Fee_Payment_Criteria__c fpc = new Fee_Payment_Criteria__c();
        List<Fee_payment_Criteria__c> fpcs = [select id from fee_payment_criteria__c where Name ='Application Fee - Full Payment'];
        if(fpcs.size() != 1){
            //handle error
        }else{
            fpc = fpcs[0];
        }

        Fee_Master__c fm =[select Fee_Amount__c,Application_Number_Prefix__c from Fee_Master__C  where id=:fmID];

        //Creation of Student Fee Record -- set description fields also
        Student_Fee__c studentFee = new Student_Fee__c();
        studentFee.Name = 'Application Fee - '+ fm.Application_Number_Prefix__c + ' - '+contact.FirstName;
        studentFee.Fee_Type__c = 'Application Fee';
        studentFee.Contact__c = contactId;
        studentFee.Description__c = 'Application Fee For ' + contact.Program_Batch__r.hed__Account__r.Name;
        studentFee.Fee_Payment_Criteria__c = fpc.id;
        studentFee.Fee_Master__c = fmID;
        studentFee.Number_of_Installments__c =1;
        studentFee.Due_Date__c = Date.Today() +365; //Sreeguru suggested to have it. Few automations are based on this field check inthe exisitng code
        studentFee.Amount__c = fm.Fee_Amount__c;
        studentFee.Amount_Paid__c =0;
        studentFee.Amount_Pending__c = fm.Fee_Amount__c;
        insert studentFee;

        uResponses.add(uResp);
        return uResponses;

    }
    
    public static Id generateReceipt(Id stu, String transactionId, string paymentGateway){
        Student_Payment__c studentPaymentRec = [Select Id, Contact__r.Application_Number__c,OwnerId, contact__r.Name,Amount__C,
                                                Payment_Gateway__c, Payment_Mode_Type__c, Transaction_ID__c, Contact__r.Program_Name__c 
                                                from Student_Payment__c Where Id =:stu];
        
        
        PageReference pdfPage = Page.Receipt_PDF_Generation;
        pdfPage.getParameters().put('id',stu);
        pdfPage.getParameters().put('transactionId',transactionId);
        pdfPage.getParameters().put('paymentGateway',paymentGateway);

        Blob pdfBlob; 
        if(Test.isRunningTest()){
            pdfBlob = Blob.valueOf('Test Content');
        }
        else{
            pdfBlob = pdfPage.getContent();
        }

        ContentVersion cv = new ContentVersion();
        cv.VersionData = pdfBlob;
        cv.Title = createFileName(studentPaymentRec.Contact__r.Application_Number__c,studentPaymentRec.contact__r.Name);
        cv.PathOnClient = 'TestFile.pdf';
        cv.FirstPublishLocationId=studentPaymentRec.Id;
        insert cv;

        return cv.id;
    }

    public static String createFileName(String applNo, String contactName){
        String fileName = applNo+'-'+contactName.deleteWhitespace()+'-'+DateTime.now().format('dd-MMM-yyyy');
        return fileName;
    }
    
    public static void sendReceipt(Id stu, Id cvId){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Student_Payment__c stPay = [ SELECT Id, Contact__c, Contact__r.FirstName,
                                            Contact__r.Application_Number__c, contact__r.Email,
                                            Payment_Gateway__c, Payment_Mode_Type__c, 
                                            Transaction_ID__c 
                                       FROM Student_Payment__c  
                                      Where Id=:stu];
    
        OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress][0];
        email.setOrgWideEmailAddressId(owa.Id);
        email.setToAddresses(new List<String>{stPay.Contact__r.Email});
        email.setTargetObjectId(stPay.Contact__c);//stPay.Contact__c); 
        email.setWhatId(stPay.Id); 
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Send_Receipt_by_Mail_Template'];
        email.setTemplateID(emailTemplate.Id); 
        email.setEntityAttachments(new List<Id>{cvId});
    
        Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }


    public class UtilityResponse{
        @InvocableVariable(label ='Generated OTP')
        public String generatedOTP;

        @InvocableVariable(label ='OTP Valid Till')
        public DateTime otpValidTill;
        
        @InvocableVariable(label = 'Purpose')
        public string purpose;
        
        @InvocableVariable(label = 'SMS Type')
        public string smsType;

        @InvocableVariable(label ='Message')
        public String message;

        @InvocableVariable(label ='Applicant Contact Id')
        public String applicantContactId;

        @InvocableVariable(label ='Fee Master Id')
        public String feeMasterId;

    }

    public class UtilityRequest{
        @InvocableVariable(label ='Email')
        public String email;

        @InvocableVariable(label ='Lead Id')
        public String leadId;

        @InvocableVariable(label ='Fee Master Id')
        public String feeMasterId;

        @InvocableVariable(label ='Invocation Type')
        public String invocationType;

        @InvocableVariable(label ='Generated OTP')
        public String generatedOTP;
        
        @InvocableVariable(label='Purpose of OTP')
        public String purpose;
        
        @InvocableVariable(label='SMS Type')
        public string smsType;

        @InvocableVariable(label ='OTP Valid Till')
        public DateTime otpValidTill;

        @InvocableVariable(label ='Mobile Phone')
        public String mobilePhone;

        @InvocableVariable(label ='Application Number')
        public String applNo;
    }
}