public without sharing class SMS_InvocableSingle {
    @InvocableMethod(label='Single SMS')
   public static void sendSingleSMS(List<flowInput> fRequests){
    flowInput fR = fRequests[0];
    SMS_BulkFlowVariablesWrapper Wrper = fR.wrapper;
        String smsType = Wrper.smsType;
        List<String> dynamicVar = Wrper.eachDynamicVar;
        String MobileNumber = Wrper.mobilePhone;
        SMS_Generic.sendSMS(smsType,MobileNumber,dynamicVar);  
        }
    
    public class flowInput{
        @InvocableVariable
        public SMS_BulkFlowVariablesWrapper wrapper;    
    }
}