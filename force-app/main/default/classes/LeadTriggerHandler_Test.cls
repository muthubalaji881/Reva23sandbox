@isTest
public with sharing class LeadTriggerHandler_Test {

    @TestSetup
    static void createleadData(){
        List<Lead> leads = new List<Lead>();

        Profile p = [select id from profile where name ='Counselor'];
        User counselorOwner = [Select id, name from User where ProfileId=:p.id Limit 1];

        Lead counselorLead = new Lead();
        counselorLead.LastName='Counselor Lead';
        counselorLead.Company='Test Company';
        counselorLead.pi__utm_source__c='Manual';
        counselorLead.MobilePhone = '9876543210';
        counselorLead.Country_Code__c='India (+91)';
        counselorLead.OwnerId = counselorOwner.Id;
        insert counselorLead;

        Lead freshLead = new Lead();
        freshLead.LastName='Fresh Lead';
        freshLead.Company='Test Company';
        freshLead.pi__utm_source__c='Fresh Lead';
        freshLead.MobilePhone = '9876543210';
        freshLead.Country_Code__c='India (+91)';
        insert freshLead;

        Lead piSourceNullLead = new Lead();
        piSourceNullLead.LastName='Fresh Lead';
        piSourceNullLead.Company='Test Company';
        piSourceNullLead.MobilePhone = '9876543210';
        insert piSourceNullLead;

        Lead primaryLead = new Lead();
        primaryLead.LastName='Fresh Lead';
        primaryLead.Company='Test Company';
        primaryLead.pi__utm_source__c='Primary';
        primaryLead.MobilePhone = '9876543210';
        primaryLead.Primary_Source__c= 'Primary';
        insert primaryLead;

        Lead secondaryLead = new Lead();
        secondaryLead.LastName='Fresh Lead';
        secondaryLead.Company='Test Company';
        secondaryLead.pi__utm_source__c='Secondary';
        secondaryLead.MobilePhone = '9876543210';
        secondaryLead.Country_Code__c = 'India (+91)';
        secondaryLead.Primary_Source__c= 'Secondary';
        secondaryLead.Secondary_Source__c= 'Secondary';
        insert secondaryLead;

    }
    @isTest
    public static void updateLeadSourceTest(){

        Lead oldLead = [Select Id, LastName, Company,pi__utm_source__c,
                Primary_Source__c, Secondary_Source__C from Lead where pi__utm_source__c= 'Primary' Limit 1];

        Lead updatedLead = [Select Id, LastName, Company,pi__utm_source__c,
                            Primary_Source__c, Secondary_Source__C from Lead where pi__utm_source__c= 'Primary' Limit 1];
        updatedLead.pi__utm_source__c = 'Updated Primary';
        update updatedLead;

        List<Lead> updatedLeads = new List<Lead>{updatedLead};

        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        oldLeadMap.put(oldLead.Id, oldLead);

        Test.startTest();
        LeadTriggerHandler.updateLeadSource(oldLeadMap, updatedLeads);
        Test.stopTest();

        system.assertEquals('Updated Primary', updatedLead.Secondary_Source__c);

    } 

    @isTest
    public static void updatePiSourceNullTest(){

        Lead oldLead = [Select Id, LastName, Company,pi__utm_source__c,
                Primary_Source__c, Secondary_Source__C from Lead where pi__utm_source__c = null Limit 1];

        Lead updatedLead = [Select Id, LastName, Company,pi__utm_source__c,
                            Primary_Source__c, Secondary_Source__C from Lead where pi__utm_source__c = null Limit 1];
        updatedLead.pi__utm_source__c = 'First Time';
        update updatedLead;

        List<Lead> updatedLeads = new List<Lead>{updatedLead};

        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        oldLeadMap.put(oldLead.Id, oldLead);

        Test.startTest();
        LeadTriggerHandler.updateLeadSource(oldLeadMap, updatedLeads);
        Test.stopTest();

        system.assertEquals('First Time', updatedLead.Primary_Source__C);

    } 

    @isTest
    public static void updateLeadSourceTertiaryTest(){

        Lead oldLead = [Select Id, LastName, Company,pi__utm_source__c,Tertiary_Source__C,Country_Code__c, MobilePhone,
                Primary_Source__c, Secondary_Source__C from Lead where pi__utm_source__c= 'Secondary' Limit 1];

        Lead updatedLead = [Select Id, LastName, Company,pi__utm_source__c, Tertiary_Source__C,Country_Code__c, MobilePhone,
                            Primary_Source__c, Secondary_Source__C from Lead where pi__utm_source__c= 'Secondary' Limit 1];
        updatedLead.pi__utm_source__c = 'Updated Secondary';
        updatedLead.MobilePhone = '+93-1234567890';
        updatedLead.Country_Code__c = 'Afghanistan (+93)';// change this
        update updatedLead;

        List<Lead> updatedLeads = new List<Lead>{updatedLead};

        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        oldLeadMap.put(oldLead.Id, oldLead);

        Test.startTest();
        LeadTriggerHandler.updateLeadSource(oldLeadMap, updatedLeads);
        LeadTriggerHandler.updateCCAndMobilePhone(oldLeadMap, updatedLeads);
        Test.stopTest();

        system.assertEquals('Updated Secondary', updatedLead.Tertiary_Source__C);
        system.assertEquals('+93-1234567890', updatedLeads[0].MobilePhone);

    } 

    @isTest
    public static void updateCCAndMobilePhoneTest(){

        Lead oldLead = [Select Id, LastName, Company,pi__utm_source__c,Tertiary_Source__C, MobilePhone, Country_Code__C,
                Primary_Source__c, Secondary_Source__C from Lead where pi__utm_source__c= 'Secondary' Limit 1];

        Lead updatedLead = [Select Id, LastName, Company,pi__utm_source__c, Tertiary_Source__C, MobilePhone, Country_Code__C,
                            Primary_Source__c, Secondary_Source__C from Lead where pi__utm_source__c= 'Secondary' Limit 1];
        updatedLead.MobilePhone = '1234567890';
        updatedLead.Country_Code__c = 'Afghanistan (+93)';// change this
        update updatedLead;

        List<Lead> updatedLeads = new List<Lead>{updatedLead};

        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        oldLeadMap.put(oldLead.Id, oldLead);

        Test.startTest();
        LeadTriggerHandler.updateCCAndMobilePhone(oldLeadMap, updatedLeads);
        Test.stopTest();

        system.assertEquals(updatedLead.Country_Code__C.substringBetween('(',')')+'-1234567890', updatedLead.MobilePhone);

    } 

    @isTest
    public static void insertLeadSourceTest(){

        Profile p = [select id from profile where name ='Counselor'];
        User counselorOwner = [Select id, name from User where ProfileId=:p.id Limit 1];

        List<Lead> leads = [Select Id, LastName, Company,pi__utm_source__c,Country_Code__c,MobilePhone,OwnerId,Assigned__c from Lead];

        system.runAs(counselorOwner){
            Test.startTest();
            LeadTriggerHandler.insertLeadSource(leads);
            Test.stopTest();
        }

        system.assertEquals(leads[0].Primary_Source__c, leads[0].pi__utm_source__c);
        system.assert(leads[0].MobilePhone.contains('-'));
        system.assertEquals(leads[0].OwnerId, counselorOwner.Id);
        system.assertEquals(leads[0].Assigned__c, true);
        system.assertEquals(leads[0].Company, leads[0].LastName);

    }

}