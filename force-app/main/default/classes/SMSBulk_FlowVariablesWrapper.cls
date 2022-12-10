public without sharing class SMSBulk_FlowVariablesWrapper {

    @AuraEnabled    public String smsType;

    @AuraEnabled   public list<string> eachDynamicVar;

    @AuraEnabled   public Lead selectedLead;

    @AuraEnabled    public Contact selectedContact;

    @AuraEnabled    public string mobilePhone;
}