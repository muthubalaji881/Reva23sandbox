public without sharing class SMS_InvocableBulkPersonalized {
    @InvocableMethod(Label='Bulk SMS Personalized')
    public static void sendBulkPersonalizedSMS(List<Request> fRequests){
        Request req = fRequests[0];
        system.debug(req);
        List<SMS_BulkFlowVariablesWrapper> listWrapper = req.wrapperlist;
        String smsType = listWrapper[0].smsType;
        Map<String, List<String>> phonesDyn = new Map<String, List<String>>();
        system.debug(listWrapper);
        for(SMS_BulkFlowVariablesWrapper eachRequest : listWrapper){
            system.debug(eachRequest);
            Lead l =eachRequest.selectedLead;
            system.debug('after lead' + l);
            Contact c = eachRequest.selectedContact;
            system.debug('after contact' + c + eachRequest.selectedContact);
            List<String> dynamicVar = eachRequest.eachDynamicVar;
            if(l == null){
                system.debug('inside l == null');
                //contact should get sms
                if(c.MobilePhone.contains('-')){
                    c.MobilePhone = c.MobilePhone.remove('-');
                }
                    phonesDyn.put(c.MobilePhone,dynamicVar);
            }else if(c == null){
                system.debug('inside c == null');
                //Lead should get sms
                if(l.MobilePhone.contains('-')){
                    l.MobilePhone = l.MobilePhone.remove('-');
                }
                    phonesDyn.put(l.MobilePhone,dynamicVar);
                }
                system.debug(phonesDyn);
        }
        SMS_BulkGeneric.sendBulkSMS_Personalized(smsType, phonesDyn);
    }

    public class Request{
        @InvocableVariable
        public List<SMS_BulkFlowVariablesWrapper> wrapperlist;
    }
}