Global with sharing class ScheduleLeadAssignment_POC implements Schedulable
{
    Global void execute(SchedulableContext sc) 
    {
        //  Instantiate batch class 
        LeadAssignment_POC leadAssign = new LeadAssignment_POC();
        Database.Executebatch(leadAssign,200);
    }
}