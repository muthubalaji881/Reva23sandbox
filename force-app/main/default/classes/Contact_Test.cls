@isTest
public class Contact_Test {
	@TestSetup
    static void createData() {
        id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        id accUniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        id accAcademicProgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
		id accHouseholdAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
      //Get user.
              List<GroupMember> counselors = [SELECT GroupId, UserOrGroupId, Group.Name 
                        FROM GroupMember 
                        WHERE Group.DeveloperName = 'Admission_Counselor' 
                        ORDER BY UserOrGroupId ];
        
 //new account  creation
       List<Account> accRecCollection = new List<Account>();

        Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
        accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
    
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        accRecCollection.add(accRecPhd);
        insert accRecCollection;
        
        Account accRec = new Account();
        accRec.Name = 'School of Applied Sciences';
        accRec.RecordTypeId = accAcademicProgRecTypeId;
        accRec.Program_Type__c = 'UG';
        insert accRec;
        
        Account houseHoldAccount = new Account();
        houseHoldAccount.Name = 'houseHoldAccount';
        houseHoldAccount.RecordTypeId = accHouseholdAccountRecTypeId;
    
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c();
        programBatch.Name = 'Ph.D in Commerce-(2023-2031)';
        programBatch.hed__Account__c = accRecPhd.Id;
        insert programBatch;
        
        
    
        Fee_Master__c feeProgramType = new Fee_Master__c();

        feeProgramType.Program_Name_Display__c = 'Ph.D in Management Studies';
        feeProgramType.Fee_Type__c = 'Application Fee';
        feeProgramType.Program_Batch__c = programBatch.Id;
        insert feeProgramType;


        

        //Get required hours for Reassignment and Escalation.
        Integer reqHoursForReassignment = (Integer)[Select Time__c From Batch_Config__mdt Where DeveloperName = 'Lead_Reassignment_Time_in_hours'
                                              Limit 1].Time__c;
        Integer reqHoursForEscalation = (Integer)[Select Time__c From Batch_Config__mdt Where DeveloperName = 'Lead_Escalation_Notification_Time_in_hrs'
                                           Limit 1].Time__c;
        
        List <sObject> recCollection = new List <sObject>();
        
        //New Contact creation
       Contact conWithOwner = new Contact();   
        conWithOwner.FirstName = 'Test First Name';
        conWithOwner.LastName = 'Test Last Name';
        conWithOwner.MobilePhone = '+91-9535768042';
        conWithOwner.RecordTypeId  = conRecTypeId;
        conWithOwner.Assigned__c = False;
       // conWithOwner.School__c = accRec.id;
        conWithOwner.Accountid = houseHoldAccount.id;
        conWithOwner.Select_Category__c = 'Karnataka';
        conWithOwner.Application_Fee_Paid__c = False;
        conWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        conWithOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        conWithOwner.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation+10));
        insert conWithOwner;
        //New Chatter Feed creation.
        FeedItem toNotifyUser = new FeedItem();
        toNotifyUser.ParentId = counselors[0].UserOrGroupId;
        toNotifyUser.Body = 'Hello,This post is for testing purpose.';
        insert toNotifyUser;
    }
    @isTest static void ReassignmentAndEscalation_Batch_TestMethod123() {
        Test.startTest();

        ReassignmentAndEscalation_Batch leadTest = new ReassignmentAndEscalation_Batch();
        Id batchId = Database.executeBatch(leadTest);
        
         system.schedule('Reassignment and Escalation', '0 0 0 * * ? *', new ReassignmentAndEscalation_Batch());
        Test.stopTest();
    }
}