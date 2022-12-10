trigger ProgramPlanTrigger on hed__Program_Plan__c (before insert,before update) 
{
    if(trigger.isbefore)
    {
        if(trigger.isinsert)
        {
            ProgramPlanHandler.updateProgramPlanName(Trigger.new,null);
        }
        else if(trigger.isupdate)
        {
            ProgramPlanHandler.updateProgramPlanName(Trigger.new,trigger.oldmap);
        }
    }       
}