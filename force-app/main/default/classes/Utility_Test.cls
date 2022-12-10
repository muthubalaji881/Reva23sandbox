@isTest
public class Utility_Test 
{
    public static testMethod Void UtilityMethod()
    {        
        test.starttest();
        Utility.Acc_RecType_University_Department = 'University Department';
        Utility.Acc_RecType_Academic_Program = 'Academic Program';
        Utility.Acc_RecType_Educational_Institution = 'Educational Institution';
        Utility.Acc_RecType_Household = 'Household Account';
        Utility.Contact_RecType_Professor = 'Professor';
        Utility.Contact_RecType_Student = 'Student';
        Utility.Contact_RecType_Parent = 'Parent';
        Utility.Term_Object_RecType_Term = 'Term';
        Utility.Term_Object_RecType_Sections = 'Sections';
        Utility.Educ_History_Object_RecType_Edu_Details = 'Education Details';
        Utility.Educ_History_Object_RecType_Edu_Docu = 'Education Documents';
        Utility.STM_RecType_Section = 'Student Section';
        Utility.STM_RecType_Batch = 'Student Batch';
        Utility.Term_RecType_Group = 'Group Allocation';
        Utility.STM_RecType_Group = 'Student Group Allocation';
        Utility.CC_Stud_RecType =  'Student';
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = STOB_TestDataFactory.CreateAccount('str_accName');
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = STOB_TestDataFactory.createContact('str_lastName');
        ObjCon.AccountId = objAcc.Id;
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;      
        
        Test.setMock(HttpCalloutMock.class, new razorPayMock());  
        
        Utility.FileCreation('https://97-s16.nopaperforms.in/uploads/student/document/97/2228/2022/05/28/62919d4d9737f211514290_IMG_30011.JPG',ObjCon.id,'test');
        Utility.generateRandomNumber();
        Utility.generateIdentifier('test1');
        test.stoptest();
    }
}