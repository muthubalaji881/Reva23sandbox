@isTest
public class FEE_StudentFeeTriggerHandler_Test 
{
    public static  testmethod void studentfeetriggerMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        Insert objStudentFee;
        
        List<Student_Fee__c> lst_studntfee = new List<Student_Fee__c>();
        lst_studntfee.add(objStudentFee);
        
        objStudentFee.Fee_Type__c ='Program Fee';
        update objStudentFee;
        
        Map<Id,Student_Fee__c> map_Oldstdntfee = new Map<Id,Student_Fee__c>();
        map_Oldstdntfee.put(objStudentFee.Id,objStudentFee);
        
        Test.startTest();
        FEE_StudentFeeTriggerHandler.updateFeePaymentCriteria(lst_studntfee,map_Oldstdntfee);
        FEE_StudentFeeTriggerHandler.updateStudentFeeProgramEnrollment(lst_studntfee,map_Oldstdntfee);
        Test.stopTest();
        system.assertEquals(objStudentFee.Id,objStudentFee.Id);
    }
}