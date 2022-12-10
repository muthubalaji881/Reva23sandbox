trigger Contact_Trigger on Contact (After Insert, After Update) 
{
	if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            MSTR_ContactTrigHndlr.CreateProfessorUser(Trigger.New);
        }
        else if(Trigger.isUpdate)
        {
            MSTR_ContactTrigHndlr.DeactivateUser(Trigger.New, Trigger.oldMap);
            MSTR_ContactTrigHndlr.StudentUserCreation(Trigger.New, Trigger.oldMap);
            ASM_ContactTrgHandler.studentsToLogisys(Trigger.New, Trigger.oldMap);
        }
    }
}