trigger LeadTrigger on Lead (before insert, before update) {

  switch on Trigger.OperationType{
    when BEFORE_INSERT{
        system.debug('Inside Before insert');
        LeadTriggerHandler.insertLeadSource(Trigger.new);
        LeadTriggerHandler.handleSpecifiLeads(Trigger.new);
    }
    when BEFORE_UPDATE{
        system.debug('Inside Before Update');
        LeadTriggerHandler.updateLeadSource(Trigger.oldMap, Trigger.new);
        LeadTriggerHandler.updateCCAndMobilePhone(Trigger.oldMap,Trigger.new);
    }
}
  
}