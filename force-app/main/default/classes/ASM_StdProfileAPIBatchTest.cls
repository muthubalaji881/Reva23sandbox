@isTest
public class ASM_StdProfileAPIBatchTest {
	@TestSetup
    static void setup() {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
    }
    
    static testMethod void exe(){
        ASM_MockCallout TestMock = new ASM_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","status":"Y"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        Test.startTest();
        Database.executeBatch(new ASM_StdProfileAPIBatch());
        Test.stopTest();
    }

}