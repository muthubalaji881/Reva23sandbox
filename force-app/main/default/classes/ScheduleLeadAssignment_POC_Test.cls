@isTest
public class ScheduleLeadAssignment_POC_Test {
   public static testMethod void ScheduleLeadAssignment_POC_Test() {
       
       //Fetching Contact recordTypeId 
	RecordType conRecTypeId = [select Id,Name from RecordType where sObjectType='Contact' 
                            AND Name = 'Applicant'];

    //Adding all record into the collection
    List<sObject> testSObjRecs = new List<sObject>();
   
        //New Lead creation
        Lead leRec1 = new Lead();
        leRec1.FirstName = 'Test First Name';
        leRec1.LastName = 'Test Last NAme';
        leRec1.Company = 'Stratos';
        leRec1.MobilePhone = '+91-9535768042';
        leRec1.Assigned__c = False;
        testSObjRecs.add(leRec1);

        Lead leRec2 = new Lead();
        leRec2.FirstName = 'Test First Name';
        leRec2.LastName = 'Test Last NAme';
        leRec2.Company = 'Stratos';
        leRec2.MobilePhone = '+91-9535768042';
        leRec2.Assigned__c = True;
        testSObjRecs.add(leRec2);

        //New Contacr creation
        Contact conRec1 = new Contact();
        conRec1.FirstName = 'Test First Name';
        conRec1.LastName = 'Test Last NAme';
        conRec1.MobilePhone = '+91-9535768042';
        conRec1.Assigned__c = False;
        conRec1.RecordTypeId  = conRecTypeId.Id;
        testSObjRecs.add(conRec1);

        Contact conRec2 = new Contact();
        conRec2.FirstName = 'Test First Name';
        conRec2.LastName = 'Test Last NAme';
        conRec2.MobilePhone = '+91-9535768042';
        conRec2.Assigned__c = True;
        conRec2.RecordTypeId  = conRecTypeId.Id;
        testSObjRecs.add(conRec2);

    insert testSObjRecs;

        //Modifying createdDate to yesterday
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(leRec1.Id, yesterday);
        Test.setCreatedDate(leRec2.Id, yesterday);
        Test.setCreatedDate(conRec1.Id, yesterday);
        Test.setCreatedDate(conRec2.Id, yesterday);
       
        Test.startTest();
			
            String jobId = System.schedule('ScheduleApexClassTest',  '0 0 0 ? * * *', new ScheduleLeadAssignment_POC());
            //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
           
        Test.stopTest();
    }
}