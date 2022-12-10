public without sharing class OneToOne_SMS_Invocable_Poc {
    @InvocableMethod(Label='OnetoOne')
    public static void sendOnetoOneSMS(List<Request> fRequests){
        Request req = fRequests[0];
        List<SMSBulk_FlowVariablesWrapper> listWrapper = req.wrapperlist;
        String smsType = listWrapper[0].smsType;
        Map<String, List<String>> phonesDyn = new Map<String, List<String>>();

        for(SMSBulk_FlowVariablesWrapper eachRequest : listWrapper){
            system.debug(eachRequest);
            Lead l =eachRequest.selectedLead;
            Contact c = eachRequest.selectedContact;
            List<String> dynamicVar = eachRequest.eachDynamicVar;
            if(l == null){
                if(c.MobilePhone.contains('-')){
                    c.MobilePhone = c.MobilePhone.remove('-');
                }
                    phonesDyn.put(c.MobilePhone,dynamicVar);
            }else{
                if(l.MobilePhone.contains('-')){
                    l.MobilePhone = l.MobilePhone.remove('-');
                }
                    phonesDyn.put(l.MobilePhone,dynamicVar);
                }
        }
        Bulk_SMS_Generic_POC.sendBulkSMS_Personalized(smsType, phonesDyn);
    }

    public class Request{
        @InvocableVariable
        public List<SMSBulk_FlowVariablesWrapper> wrapperlist;
    }
}