public class Bulk_SMS_Invocable_Poc {

    @InvocableMethod(Label='Onetomany')
    public static void sendOnetoManySMS(List<flowInput> fRequests){
        flowInput fR =  fRequests[0];

        Switch on fR.smsType{
            When 'Counsellor_Online_Paid_Application'{
                List<String> requiredVariables = new List<String>{fR.leadName,fR.counselorName, fR.Admission, fR.RevaName, fR.universityName};
                Bulk_SMS_Generic_POC.sendBulkSMS_Common(fR.smsType, fR.mobileNumbers,requiredVariables);
            }
        }
    }

    public class flowInput{

            @InvocableVariable(Label ='Sms Type')
            public String smsType;

            @InvocableVariable(Label ='Mobile Number')
            public List<String> mobileNumbers;  
            
            @InvocableVariable(Label ='Lead Name')
            public String leadName;
    
            @InvocableVariable(Label ='Counselor Name')
            public String counselorName;  
            
            @InvocableVariable(Label ='Admission')
            public String Admission; 
    
            @InvocableVariable(Label ='REVA')
            public String RevaName; 
    
            @InvocableVariable(Label ='University')
            public String universityName; 
    
            @InvocableVariable(label ='Invocation Type')
            public String invocationType;
            
            
        }
}