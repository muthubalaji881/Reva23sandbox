public without sharing class LeadTriggerHandler {

    public static void updateLeadSource(Map<Id,Lead> oldLeadMap, List<Lead> newLeads){

/*         for (Lead l : Trigger.new) {
            if (l.Primary_Source__c == null || l.Primary_Source__c == '') {
              l.Primary_Source__c = l.pi__utm_source__c;
            } else if (l.Secondary_Source__c == null || l.Secondary_Source__c == '') {
              l.Secondary_Source__c = l.pi__utm_source__c;
            } else if (l.Tertiary_Source__c == null || l.Tertiary_Source__c == '') {
              l.Tertiary_Source__c = l.pi__utm_source__c;
            }
          } */
        //Logic to filter out the leads with only chnage in source field
        for(Lead eachLead: newLeads){
            String incomingSource = eachLead.pi__utm_source__c;
            String existingSource = oldLeadMap.get(eachLead.id).pi__utm_source__c;
            if(incomingSource != existingSource){

                if(existingSource == null){ //First time entry
                    eachLead.Primary_Source__c =  eachLead.pi__utm_source__c;
                    break;
                }
                if(eachLead.Primary_Source__c != null && oldLeadMap.get(eachLead.id).Secondary_Source__c== null ){
                    eachLead.Secondary_Source__c = eachLead.pi__utm_source__c;
                    break;
                }
                if( eachLead.Primary_Source__c != null && eachLead.Secondary_Source__c != null 
                             && oldLeadMap.get(eachLead.id).Tertiary_Source__c== null ){
                    eachLead.Tertiary_Source__c = eachLead.pi__utm_source__c; 
                    break;
                }
            }
        }
    }

    public static void updateCCAndMobilePhone(Map<Id,Lead> oldLeadMap, List<Lead> newLeads){
        for(Lead eachLead: newLeads){
            if(eachLead.MobilePhone != null){
                if((eachLead.Country_Code__C != oldLeadMap.get(eachLead.id).Country_Code__C
                        || eachLead.MobilePhone != oldLeadMap.get(eachLead.id).MobilePhone)){
                            if(!eachLead.MobilePhone.contains('-')){
                                eachLead.MobilePhone = eachLead.Country_Code__c.substringBetween('(',')')+'-'+eachLead.MobilePhone;
                            }
                            else{
                                eachLead.MobilePhone = eachLead.Country_Code__c.substringBetween('(',')')+'-'+eachLead.MobilePhone.substringAfter('-');
                            }
                }
            }
        }
    }


    public static void insertLeadSource(List<Lead> incomingLeads){

        for(Lead l : incomingLeads){
            l.Company = l.LastName;  //no matter what Counselors enter in the Company Field let company = last name
            if(l.pi__utm_source__c != null){
                l.Primary_Source__c = l.pi__utm_source__c;
            }
            if(l.Country_Code__c != null && l.MobilePhone !=null){
                l.MobilePhone = l.Country_Code__c.substringBetween('(',')')+'-'+l.MobilePhone;

            }
        }
    }

    /* When a Lead is created manually by a Counselor*/
    public static void handleSpecifiLeads(List<Lead> newLeads){
        Profile counselorProfile = [Select Id, Name from Profile where Name = 'Counselor'];
        List<User> counselors = [Select Id, Name from User where ProfileId =:counselorProfile.Id and isActive = true];
        system.debug('No of Users in Counselor Profile : '+counselors.size());
        Set<Id> counselorIds = new Set<Id>();
        for(User counselor: counselors){
            counselorIds.add(counselor.Id);
            system.debug('Counselor Id : '+counselor.Id);
        }
        for(Lead eachLead : newLeads){
            if(counselorIds.contains(eachLead.OwnerId)){
                system.debug('Lead Owner Id : '+eachLead.OwnerId);
                eachLead.Assigned__C = true;
                eachLead.Assigned_Users__C = eachLead.OwnerId;
                eachLead.Last_Assigned_Date__c = system.today();
            }
        }
    }

}