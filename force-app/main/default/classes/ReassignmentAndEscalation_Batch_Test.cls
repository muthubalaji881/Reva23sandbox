@isTest
public class ReassignmentAndEscalation_Batch_Test {
        @TestSetup
    	static void createTestData(){
        List<GroupMember> counselors = [SELECT GroupId, UserOrGroupId, Group.Name 
                                        FROM GroupMember 
                                        WHERE Group.DeveloperName = 'Admission_Counselor' 
                                        ORDER BY UserOrGroupId ];
        
        id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId(); //Fetching Applicant recordTypeId from Contact
        id accUniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId(); //Fetching University Department recordTypeId from Account
        id accAcademicProgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId(); //Fetching Academic program recordTypeId from account
        id accHouseholdAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
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
        
        //New Lead creation.
        Lead leadRec = new Lead();
        leadRec.FirstName = 'Test';
        leadRec.LastName = 'Lead1';
        leadRec.Company = 'TestCompany';
        leadRec.Program_Name_Display__c = 'MBA';
        leadRec.Category__c = 'Karnataka';
        leadRec.Assigned_Users__c = counselors[0].UserOrGroupId;
        leadRec.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        leadRec.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation+10));
        insert leadRec; 
        
        //reset nextindex value 
        Lead leadRec3 = new Lead();
        leadRec3.OwnerId = counselors[11].UserOrGroupId;
        leadRec3.FirstName = 'Test';
        leadRec3.LastName = 'Lead1';
        leadRec3.Company = 'TestCompany';
        leadRec3.Status = 'Unqualified';
        leadRec3.Program_Name_Display__c = 'MBA';
        leadRec3.Category__c = 'Karnataka';
        leadRec3.School__c = 'REVA Business School';
        leadRec3.Assigned_Users__c = counselors[11].UserOrGroupId;
        leadRec3.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        leadRec3.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation+10));
        insert leadRec3; 
        
        //assigned users count greater then counselors list count
        string allUsersAssigned = counselors[0].UserOrGroupId+','+counselors[1].UserOrGroupId+','+counselors[2].UserOrGroupId+','+counselors[3].UserOrGroupId+','+counselors[4].UserOrGroupId+','+counselors[5].UserOrGroupId+','+counselors[6].UserOrGroupId+','+counselors[7].UserOrGroupId+','+counselors[8].UserOrGroupId+','+counselors[9].UserOrGroupId+','+counselors[10].UserOrGroupId+','+counselors[11].UserOrGroupId;
        Lead leadRec2 = new Lead();
        leadRec2.FirstName = 'Test';
        leadRec2.LastName = 'Lead1';
        leadRec2.Company = 'TestCompany';
        leadRec2.Status = 'Unqualified';
        leadRec2.Program_Name_Display__c = 'MBA';
        leadRec2.Category__c = 'Karnataka';
        leadRec2.School__c = 'REVA Business School';
        leadRec2.Assigned_Users__c = allUsersAssigned;
        leadRec2.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        leadRec2.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation+10));
        insert leadRec2; 
        
        //default user not in public group
        Lead leadRec4 = new Lead();
        leadRec4.FirstName = 'Test';
        leadRec4.LastName = 'Lead1';
        leadRec4.Company = 'TestCompany';
        leadRec4.Status = 'Unqualified';
        leadRec4.Program_Name_Display__c = 'MBA';
        leadRec4.Category__c = 'Karnataka';
        leadRec4.School__c = 'REVA Business School';
        leadRec4.Assigned_Users__c = userinfo.getUserId()+','+counselors[1].UserOrGroupId+','+counselors[2].UserOrGroupId+','+counselors[3].UserOrGroupId+','+counselors[4].UserOrGroupId+','+counselors[5].UserOrGroupId+','+counselors[6].UserOrGroupId+','+counselors[7].UserOrGroupId+','+counselors[8].UserOrGroupId+','+counselors[9].UserOrGroupId+','+counselors[10].UserOrGroupId+','+counselors[11].UserOrGroupId;
        leadRec4.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        leadRec4.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation+10));
        insert leadRec4; 
        
        //last escalation date is null
        Lead leadRec5 = new Lead();
        leadRec5.FirstName = 'Test';
        leadRec5.LastName = 'Lead1';
        leadRec5.Company = 'TestCompany';
        leadRec5.Status = 'Unqualified';
        leadRec5.Program_Name_Display__c = 'MBA';
        leadRec5.Category__c = 'Karnataka';
        leadRec5.School__c = 'REVA Business School';
        leadRec5.Assigned_Users__c = userinfo.getUserId()+','+counselors[1].UserOrGroupId+','+counselors[2].UserOrGroupId+','+counselors[3].UserOrGroupId+','+counselors[4].UserOrGroupId+','+counselors[5].UserOrGroupId+','+counselors[6].UserOrGroupId+','+counselors[7].UserOrGroupId+','+counselors[8].UserOrGroupId+','+counselors[9].UserOrGroupId+','+counselors[10].UserOrGroupId+','+counselors[11].UserOrGroupId;
        leadRec5.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        insert leadRec5; 
        
 //Create Contact
        Contact conWithOwner = new Contact();   
        conWithOwner.FirstName = 'Test First Name';
        conWithOwner.LastName = 'Test Last Name';
        conWithOwner.MobilePhone = '+91-9535768042';
        conWithOwner.RecordTypeId  = conRecTypeId;
        conWithOwner.Assigned__c = False;
        conWithOwner.Accountid = houseHoldAccount.id;
        conWithOwner.Select_Category__c = 'Karnataka';
        conWithOwner.Application_Fee_Paid__c = False;
        conWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        conWithOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        conWithOwner.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation+10));
        insert conWithOwner;
        
        //default owner is not in public group.
        Contact contact1 = new Contact();   
        contact1.FirstName = 'Test First Name';
        contact1.LastName = 'Test Last Name';
        contact1.MobilePhone = '+91-9535768042';
        contact1.RecordTypeId  = conRecTypeId;
        contact1.Assigned__c = False;
        contact1.Accountid = houseHoldAccount.id;
        contact1.Select_Category__c = 'Karnataka';
        contact1.Application_Fee_Paid__c = False;
        contact1.Assigned_Users__c = userinfo.getUserId()+','+counselors[1].UserOrGroupId+','+counselors[2].UserOrGroupId+','+counselors[3].UserOrGroupId+','+counselors[4].UserOrGroupId+','+counselors[5].UserOrGroupId+','+counselors[6].UserOrGroupId+','+counselors[7].UserOrGroupId+','+counselors[8].UserOrGroupId+','+counselors[9].UserOrGroupId+','+counselors[10].UserOrGroupId+','+counselors[11].UserOrGroupId;
        contact1.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        contact1.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation+10));
        insert contact1;
        
        //assigned users count greater then counselors list count
        Contact contact2 = new Contact();   
        contact2.FirstName = 'Test First Name';
        contact2.LastName = 'Test Last Name';
        contact2.MobilePhone = '+91-9535768042';
        contact2.RecordTypeId  = conRecTypeId;
        contact2.Assigned__c = False;
        contact2.Accountid = houseHoldAccount.id;
        contact2.Select_Category__c = 'Karnataka';
        contact2.Application_Fee_Paid__c = False;
        contact2.Assigned_Users__c = counselors[0].UserOrGroupId+','+counselors[1].UserOrGroupId+','+counselors[2].UserOrGroupId+','+counselors[3].UserOrGroupId+','+counselors[4].UserOrGroupId+','+counselors[5].UserOrGroupId+','+counselors[6].UserOrGroupId+','+counselors[7].UserOrGroupId+','+counselors[8].UserOrGroupId+','+counselors[9].UserOrGroupId+','+counselors[10].UserOrGroupId+','+counselors[11].UserOrGroupId;
        contact2.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        contact2.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation+10));
        insert contact2;
        
        //reset nextindex value 
        Contact contact3 = new Contact();   
        contact3.FirstName = 'Test First Name';
        contact3.OwnerId = counselors[11].UserOrGroupId;
        contact3.LastName = 'Test Last Name';
        contact3.MobilePhone = '+91-9535768042';
        contact3.RecordTypeId  = conRecTypeId;
        contact3.Assigned__c = False;
        contact3.Accountid = houseHoldAccount.id;
        contact3.Select_Category__c = 'Karnataka';
        contact3.Application_Fee_Paid__c = False;
        contact3.Assigned_Users__c = counselors[11].UserOrGroupId;
        contact3.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment+10));
        contact3.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation+10));
        insert contact3;
        
        
        //New Chatter Feed creation.
        FeedItem toNotifyUser = new FeedItem();
        toNotifyUser.ParentId = counselors[0].UserOrGroupId;
        toNotifyUser.Body = 'Hello,This post is for testing purpose.';
        insert toNotifyUser;
            
            
    }
    
    @isTest static void test() 
    {
        Test.startTest();
        ReassignmentAndEscalation_Batch batchTest = new ReassignmentAndEscalation_Batch();
        Id batchId = Database.executeBatch(batchTest);
        system.schedule('Reassignment and Escalation', '0 0 0 * * ? *', new ReassignmentAndEscalation_Batch());
        Test.stopTest();
    }

}