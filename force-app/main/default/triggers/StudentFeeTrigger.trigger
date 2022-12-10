trigger StudentFeeTrigger on Student_Fee__c (before insert,before update, After update) 
{
    if(trigger.IsBefore)
    {
        if(trigger.IsInsert)
        {
            FEE_StudentFeeTriggerHandler.updateFeePaymentCriteria(trigger.new,null);
            FEE_StudentFeeTriggerHandler.updateStudentFeeProgramEnrollment(trigger.new,null);
            FEE_StudentFeeTriggerHandler.displayOrderNoMapping(trigger.new);
        }
        if(trigger.IsUpdate)
        {
            FEE_StudentFeeTriggerHandler.updateFeePaymentCriteria(trigger.new,trigger.oldmap);
            FEE_StudentFeeTriggerHandler.updateStudentFeeProgramEnrollment(trigger.new,trigger.oldmap);
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isUpdate)
        {
          //  FEE_StudentPaymentEmail_TriggerHandler.StudentPaymentEmail(trigger.new, trigger.oldMap);
        }
    }
    
}