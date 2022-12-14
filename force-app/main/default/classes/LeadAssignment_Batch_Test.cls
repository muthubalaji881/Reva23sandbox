@isTest
public class LeadAssignment_Batch_Test {
    private static final String SPECIFIC_CATEGORY = 'Foreign Nationals'; //Lead/Contact Category 
    private static final String SPECIFIC_SCHOOL = 'School of Performing Arts and Indic Studies'; //Lead/Contact School 
    private static final String SPECIFIC_PROGRAM_TYPE = 'Ph.D'; //Lead/Contact Program type
    @TestSetup
    static void createTestData(){ 
        //Fetching recordTypeId 
        id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        id accUniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        id accAcademicProgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        List<GroupMember> counselors = [SELECT GroupId, UserOrGroupId, Group.Name FROM GroupMember 
                                            WHERE Group.DeveloperName = 'Admission_Counselor' 
                                            ORDER BY UserOrGroupId ];
        
        Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
        accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;

        Account mbaAcc = new Account();
        mbaAcc.Name = 'Master of Business Administration';
        mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
        mbaAcc.Program_Type__c = 'PG';
        insert mbaAcc;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c();
        programBatch.Name = 'Ph.D in Commerce-(2023-2031)';
        programBatch.hed__Account__c = accRecPhd.Id;
        insert programBatch;

        hed__Program_Plan__c programMBABatch = new hed__Program_Plan__c();
        programMBABatch.Name = 'MBA-(2021-2023)';
        programMBABatch.hed__Account__c = mbaAcc.Id;
        insert programMBABatch;

        Fee_Master__c feeProgramType = new Fee_Master__c();
        feeProgramType.Program_Name_Display__c = 'Ph.D in Management Studies';
        feeProgramType.Fee_Type__c = 'Application Fee';
        feeProgramType.Program_Batch__c = programBatch.Id;
        insert feeProgramType;

        Fee_Master__c feeProgramTypeMBA = new Fee_Master__c();
        feeProgramTypeMBA.Fee_Type__c = 'Application Fee';
        feeProgramTypeMBA.Program_Batch__c = programMBABatch.Id;
        insert feeProgramTypeMBA;
        
        //Adding all record into the collection
        List<sObject> recCollection = new List<sObject>();
        //Lead without assigned users
        Lead leadRec = new Lead();
        leadRec.FirstName = 'Test First Name';
        leadRec.LastName = 'Test Last Name';
        leadRec.Company = 'Stratos';
        leadRec.MobilePhone = '9535768042';
        leadRec.Assigned__c = False;
        recCollection.add(leadRec);
        //Lead with assigned users != null 
        Lead leadRecWithOwner = new Lead();
        leadRecWithOwner.FirstName = 'TestOwner First Name';
        leadRecWithOwner.LastName = 'TestOwner Last Name';
        leadRecWithOwner.Company = 'Stratos';
        leadRecWithOwner.MobilePhone = '+91-9535768042';
        leadRecWithOwner.Assigned__c = False;
        leadRecWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(leadRecWithOwner);
        //Lead with Category = Foreign Nationals
        Lead leadRecForeigner = new Lead();
        leadRecForeigner.FirstName = 'Foreigner First Name';
        leadRecForeigner.LastName = 'Foreigner Last Name';
        leadRecForeigner.Company = 'Foreigner';
        leadRecForeigner.MobilePhone = '+91-9535768042';
        leadRecForeigner.Assigned__c = False;
        leadRecForeigner.Category__c = 'Foreign Nationals';
        recCollection.add(leadRecForeigner);
        //Lead with Category = Foreign Nationals and assigned users != null
        Lead leadRecForeignerWithOwner = new Lead();
        leadRecForeignerWithOwner.FirstName = 'Foreigner First Name';
        leadRecForeignerWithOwner.LastName = 'Foreigner With Owner Last Name';
        leadRecForeignerWithOwner.Company = 'Foreigner With Owner';
        leadRecForeignerWithOwner.MobilePhone = '+91-9535768042';
        leadRecForeignerWithOwner.Assigned__c = False;
        leadRecForeignerWithOwner.Category__c = 'Foreign Nationals';
        leadRecForeignerWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(leadRecForeignerWithOwner); 
        //Lead with School = School of Performing Arts and Indic Studies
        Lead leadRecPerformingArts = new Lead();
        leadRecPerformingArts.FirstName = 'PerformingArts First Name';
        leadRecPerformingArts.LastName = 'PerformingArts Last Name';
        leadRecPerformingArts.Company = 'PerformingArts';
        leadRecPerformingArts.MobilePhone = '+91-9535768042';
        leadRecPerformingArts.Assigned__c = False;
        leadRecPerformingArts.School__c = 'School of Performing Arts and Indic Studies';
        recCollection.add(leadRecPerformingArts);
        //Lead with School = School of Performing Arts and Indic Studies and assigned users != null
        Lead leadRecPerformingArtsWithOwner = new Lead();
        leadRecPerformingArtsWithOwner.FirstName = 'PerformingArts First Name';
        leadRecPerformingArtsWithOwner.LastName = 'PerformingArts Last Name';
        leadRecPerformingArtsWithOwner.Company = 'PerformingArts';
        leadRecPerformingArtsWithOwner.MobilePhone = '+91-9535768042';
        leadRecPerformingArtsWithOwner.Assigned__c = False;
        leadRecPerformingArtsWithOwner.School__c = 'School of Performing Arts and Indic Studies';
        leadRecPerformingArtsWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(leadRecPerformingArtsWithOwner);
        //Lead with Program type = Ph.D
        Lead leadPhd = new Lead();
        leadPhd.FirstName = 'Ph.D First Name';
        leadPhd.LastName = 'Ph.D Last Name';
        leadPhd.Company = 'Phd';
        leadPhd.MobilePhone = '+91-9535768042';
        leadPhd.Assigned__c = False;
        leadPhd.Program_Name_Display__c = 'Ph.D in Management Studies';
        recCollection.add(leadPhd);
        //Lead with Program type = Ph.D and assigned users != null
        Lead leadPhdWithOwner = new Lead();
        leadPhdWithOwner.FirstName = 'Ph.D First Name';
        leadPhdWithOwner.LastName = 'Ph.D Last Name';
        leadPhdWithOwner.Company = 'Phd';
        leadPhdWithOwner.MobilePhone = '+91-9535768042';
        leadPhdWithOwner.Assigned__c = False;
        leadPhdWithOwner.Program_Name_Display__c = 'Ph.D in Management Studies';
        leadPhdWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(leadPhdWithOwner); 
        
        //Contact with assigned users != null
        Contact conWithOwner = new Contact();   
        conWithOwner.FirstName = 'Test First Name';
        conWithOwner.LastName = 'Test Last Name';
        conWithOwner.MobilePhone = '+91-9535768042';
        conWithOwner.RecordTypeId  = conRecTypeId;
        conWithOwner.Assigned__c = False;
        conWithOwner.Select_Category__c = 'Karnataka';
        conWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(conWithOwner);
        //Contact with Category = Foreogn Nationals
        Contact conForeigner = new Contact();   
        conForeigner.FirstName = 'Foreigner First Name';
        conForeigner.LastName = 'Foreigner Last Name';
        conForeigner.MobilePhone = '+91-9535768042';
        conForeigner.RecordTypeId  = conRecTypeId;
        conForeigner.Assigned__c = False;
        conForeigner.Select_Category__c = 'Foreign Nationals';
        recCollection.add(conForeigner);
        //Contact with Category = Foreogn Nationals and assigned users != null
        Contact conForeignerWithOwner = new Contact();   
        conForeignerWithOwner.FirstName = 'Foreigner With Owner First Name';
        conForeignerWithOwner.LastName = 'Foreigner With Owner Last Name';
        conForeignerWithOwner.MobilePhone = '+91-9535768042';
        conForeignerWithOwner.RecordTypeId  = conRecTypeId;
        conForeignerWithOwner.Assigned__c = False;
        conForeignerWithOwner.Select_Category__c = 'Foreign Nationals';
        conForeignerWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(conForeignerWithOwner);
        //Contact with school = School of Performing Arts and Indic Studies 
        Contact conPerformingArts = new Contact();   
        conPerformingArts.FirstName = 'Performing Arts First Name';
        conPerformingArts.LastName = 'Performing Arts Last Name';
        conPerformingArts.MobilePhone = '+91-9535768042';
        conPerformingArts.RecordTypeId  = conRecTypeId;
        conPerformingArts.Assigned__c = False;
        conPerformingArts.School__c = accRecPerformingArts.Id;
        recCollection.add(conPerformingArts);
        //Contact with school = School of Performing Arts and Indic Studies and Assigned users != null
        Contact conPerformingArtsWithOwner = new Contact();   
        conPerformingArtsWithOwner.FirstName = 'Performing Arts First Name';
        conPerformingArtsWithOwner.LastName = 'Performing Arts Last Name';
        conPerformingArtsWithOwner.MobilePhone = '+91-9535768042';
        conPerformingArtsWithOwner.RecordTypeId  = conRecTypeId;
        conPerformingArtsWithOwner.Assigned__c = False;
        conPerformingArtsWithOwner.School__c = accRecPerformingArts.Id;
        conPerformingArtsWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(conPerformingArtsWithOwner);
        //Contact with Program type = Ph.D
        Contact conPhd = new Contact();   
        conPhd.FirstName = 'Ph.d First Name';
        conPhd.LastName = 'Ph.d Last Name';
        conPhd.MobilePhone = '+91-9535768042';
        conPhd.RecordTypeId  = conRecTypeId;
        conPhd.Assigned__c = False;
        conPhd.Primary_Academic_Program__c = accRecPhd.Id;
        recCollection.add(conPhd);
        //Contact with Program type = Ph.D and Assigned users != null
        Contact conPhdwithOwner = new Contact();   
        conPhdwithOwner.FirstName = 'Ph.d First Name';
        conPhdwithOwner.LastName = 'Ph.d Last Name';
        conPhdwithOwner.MobilePhone = '+91-9535768042';
        conPhdwithOwner.RecordTypeId  = conRecTypeId;
        conPhdwithOwner.Assigned__c = False;
        conPhdwithOwner.Primary_Academic_Program__c = accRecPhd.Id;
        conPhdwithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(conPhdwithOwner);  
        //Contact without Assigned users
        Contact con = new Contact();
        con.FirstName = 'Test First Name WO Assinged Users';
        con.LastName = 'Test Last Name WO Assinged Users';
        con.MobilePhone = '+91-9535768042';
        con.Assigned__c = False;
        con.RecordTypeId  = conRecTypeId;
        con.Program_Batch__c = programMBABatch.Id;
        recCollection.add(con);
        
        insert recCollection;
        
        //Modifying createdDate from today to yesterday
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(leadRec.Id, yesterday);
        Test.setCreatedDate(con.Id, yesterday);
    }
    //Start test
    @isTest static void test() 
    {
        Id foreignerCounselorId;
        Id performingArtsCounselorId;
        Test.startTest();
        LeadAssignment_Batch leadTest = new LeadAssignment_Batch();
        Id batchId = Database.executeBatch(leadTest);
        Test.stopTest();
        Lead newlead = [select id, assigned__c from lead Limit 1];
		System.assertEquals(True, newlead.assigned__c);

        Contact cont = [select id, assigned__c from Contact Limit 1];
		System.assertEquals(true, cont.assigned__c);

        String foreignerCounselorFedId = (String) General_Setting__mdt.getInstance('FOREIGNER_COUNSELOR').Text_Value__c;
        List<User> foreignerCounselor = [SELECT Id, FederationIdentifier FROM User 
                                    Where FederationIdentifier = :foreignerCounselorFedId Limit 1];
        if(!foreignerCounselor.isEmpty()){
            foreignerCounselorId = foreignerCounselor[0].Id;
        }
        Contact contForeignerRec = [select id, assigned__c, OwnerId from Contact Where Select_Category__c = :SPECIFIC_CATEGORY Limit 1];
		System.assertEquals(foreignerCounselorId, contForeignerRec.OwnerId);

        String perArtsCounselorFedId = (String) General_Setting__mdt.getInstance('PERFORMING_ARTS_COUNSELOR').Text_Value__c;
        List<User> perArtsCounselor = [SELECT Id, FederationIdentifier FROM User 
                                    Where FederationIdentifier = :perArtsCounselorFedId Limit 1];
        
        if (!perArtsCounselor.isEmpty()){
            performingArtsCounselorId = perArtsCounselor[0].Id;
        }
        Lead leadPerformingArtsRec = [select id, assigned__c, OwnerId, School__c from Lead Where School__c = :SPECIFIC_SCHOOL Limit 1];
		System.assertEquals(performingArtsCounselorId, leadPerformingArtsRec.OwnerId);
    }
}