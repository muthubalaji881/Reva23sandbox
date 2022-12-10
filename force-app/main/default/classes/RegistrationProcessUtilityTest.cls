@isTest
public class RegistrationProcessUtilityTest {
    
    @isTest
    public static void sequenceNumberMethod(){
        Sequence_Number__c sequenceNo = new Sequence_Number__c();
        sequenceNo.Key_Field__c = '230401';
        sequenceNo.Integer_Five__c = 94;
        insert sequenceNo;
        Test.startTest();
       
   		 //RegistrationProcessUtility.getNextSequence('230401');
       	 RegistrationProcessUtility.generateApplNoSequence('230401');
        Test.stopTest();
    }
}