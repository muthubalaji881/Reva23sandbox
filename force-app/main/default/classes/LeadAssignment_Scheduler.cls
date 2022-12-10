public with sharing class LeadAssignment_Scheduler implements Schedulable{
    public void execute(SchedulableContext sc){
        //  Instantiate batch class 
        system.debug('LeadAssignment_Scheduler : Inside execute');
        LeadAssignment_Batch leadAssignmentBatch = new LeadAssignment_Batch();
        Database.executebatch(leadAssignmentBatch,200);
    }
}