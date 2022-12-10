public with sharing class SMS_BulkFlowVariablesWrapper {
    @AuraEnabled    public String smsType;

    @AuraEnabled   public list<string> eachDynamicVar;

    @AuraEnabled   public Lead selectedLead;

    @AuraEnabled    public Contact selectedContact;
    
    @AuraEnabled  public String mobilePhone;
}