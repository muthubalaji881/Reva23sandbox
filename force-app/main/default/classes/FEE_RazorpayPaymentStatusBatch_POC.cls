global class FEE_RazorpayPaymentStatusBatch_POC {
global Database.QueryLocator start(Database.BatchableContext BC){
        return database.getQueryLocator([SELECT Payment_Status__c, Id, Name, Amount__c,Payment_Link_Id__c, Payment_Url__c,
 											Fee_Type__c, Payment_Gateway__c FROM Student_Payment__c Where (Payment_Gateway__c='' or Payment_Gateway__c='RazorPay') and Payment_Status__c ='Payment Link Created' and Fee_Type__c ='Application Fee']); //  id = 'a1E0w000001c07f']); 
    }
}