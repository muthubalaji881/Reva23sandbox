public without sharing class programTableController {
    @AuraEnabled(cacheable=true)
    public static List<Fee_Master__c> programTable() {
        system.debug('Inside programTable');
        return [SELECT School_Name__c, Program_Type__c	,Program_Name_Display__c FROM Fee_Master__c where Enrolment_Year__c = '2023' ];
    }
}