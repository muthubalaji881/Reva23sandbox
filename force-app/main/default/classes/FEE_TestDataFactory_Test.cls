@isTest
public class FEE_TestDataFactory_Test 
{
    @isTest
    public static void testDataMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAccount = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAccount.Id);
        hed__Program_Plan__c objProgplan = FEE_TestDataFactory.createProgramPlan('Program Plan');
        hed__Program_Enrollment__c objProgEnrollment = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,objProgplan.Id);
        Fee_Payment_Criteria__c  objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        Student_Fee__c  objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id,objCon.Id,'Academic Fee');
        Student_Payment__c objStuPay = FEE_TestDataFactory.createStudentPayment(objCon.id);
        Student_Fee_Payment__c objstuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id,objStuPay.id); 
    }

}