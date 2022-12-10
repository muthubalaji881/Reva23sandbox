global class ASM_StdProfileAPIBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	global Database.QueryLocator start(Database.BatchableContext BC){
        return database.getQueryLocator([SELECT Id,Name FROM Contact WHERE SRN_Number__c != '' AND Logisys_Integration__c != 'Yes']);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        Set<Id> set_StdIds = new Set<Id>();
        Map<Id,String> map_DataChanges = new Map<Id,String>();
        for(Contact con : scope){
            set_StdIds.add(con.Id);
            map_DataChanges.put(con.Id, 'No-No-No');
        }
        Debug_Log__c dLog = ASM_StdProfileAPI.sendStdProfiles(set_StdIds,map_DataChanges,true);
        Insert dLog;
    }
    global void finish(Database.BatchableContext BC){       
    }
}