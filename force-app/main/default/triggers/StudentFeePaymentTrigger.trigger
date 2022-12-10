trigger StudentFeePaymentTrigger on Student_Fee_Payment__c (After Insert,After Update,after delete,after undelete) 
{
    if(trigger.isafter)
    {
        if(trigger.isInsert)
        {
            // This method we are stopping to execute when records are created from NPF integration
            if(Utility.NPF_API_To_Stop_Rollup == false) 
            {
                FEE_StudentFeePaymentTriggerHandler.RollupAmount(trigger.new,Null);
                FEE_StudentFeePaymentTriggerHandler.InstallmentRollup(trigger.new,null);
            }
            
            // This method we are execute when records are created from NPF integration to update the installments
            if(Utility.NPF_API_To_Stop_Rollup == true) FEE_StudentFeePaymentTriggerHandler.InstallmentRollup(trigger.new,null);
        }
        else if(trigger.isupdate)
        {
            FEE_StudentFeePaymentTriggerHandler.RollupAmount(trigger.new,trigger.oldmap);
            FEE_StudentFeePaymentTriggerHandler.InstallmentRollup(trigger.new,trigger.oldmap);
            if(utility.LogisysAPI == true) FEE_StudentFeePaymentTriggerHandler.PushExamFeeToLogisys(Trigger.New, Trigger.Oldmap);
        }
        else if(trigger.isdelete)
        {
            FEE_StudentFeePaymentTriggerHandler.RollupAmount(trigger.old,null);
        }
        else if(trigger.isundelete)
        {
            FEE_StudentFeePaymentTriggerHandler.RollupAmount(trigger.new,null);
        }
    }
}