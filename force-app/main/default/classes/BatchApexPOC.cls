global class BatchApexPOC implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Inside Start');
      return Database.getQueryLocator('Select Id, Name from Lead');
   }

   global void execute(Database.BatchableContext BC, List<sObject> leads){
       system.debug('Inside execute');
       for(sObject lead : leads){
           system.debug('Inside each Lead');
       }
    }

   global void finish(Database.BatchableContext BC){
       System.debug('Inside Finish');
   }
}