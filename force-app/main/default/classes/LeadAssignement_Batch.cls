Global class LeadAssignement_Batch implements Database.Batchable<sObject>, Database.Stateful
{

    /*LeadAssignement_Schedular sch = new LeadAssignement_Schedular();
    System.schedule('Lead assignment schedule - I', '0 00 * * * ? ' , sch);
    System.schedule('Lead assignment schedule - II', '0 15 * * * ? ' , sch);
    System.schedule('Lead assignment schedule - III', '0 30 * * * ? ' , sch);
    System.schedule('Lead assignment schedule - IV', '0 45 * * * ? ' , sch);*/

    Global Integer initialIndex;
    Global Integer finalIndex;
    Global Integer noOfRecordsProcessed;

    //Start method
    Global Iterable<SObject> Start(Database.BatchableContext bc)
    {
        initialIndex = RegistrationProcessUtility.getCounselorIndex();
        System.debug('Inside Start');
        List<sObject> unassignRecs = new List<sObject>();
        unassignRecs.addAll([Select id, Name, Phone, Assigned__c, OwnerId, CreatedDate  From Lead 
                                Where Assigned__c = False ]);
        unassignRecs.addAll([Select id, Name, Phone, Assigned__c, OwnerId, CreatedDate From Contact 
                                Where Assigned__c= False AND Record_Type_Name__c = 'Applicant']);
       
        System.debug(unassignRecs);
        System.debug('Total unassign records size is :'+ unassignRecs.size());
        return unassignRecs;  
    }
    //Execute method
    Global void Execute(Database.BatchableContext bContext, List<sObject> unassignRecs)
    {
        System.debug('Inside Execute');
        System.debug('Total unassign records size is in Execute :'+ unassignRecs.size());

        //Get present time
        dateTime presentTime = System.now();
        
        //Get delay time from custom metadata
        Batch_Config__mdt batchConfig = Batch_Config__mdt.getInstance('Lead_Assignment_Time_Delay_in_minutes');
        Integer timeDelay = (Integer) batchConfig.Time__c;
        
        //get index value from RegistrationProcessUtility
        Integer index = initialIndex;
        
        //Get group members
        list<GroupMember> members = [SELECT GroupId, UserOrGroupId, Group.Name FROM GroupMember 
                                    Where Group.DeveloperName = 'Admission_Counselor' ORDER BY UserOrGroupId ];
        
        List<sObject> assignedRec = new List<sObject>();
        
        for (sObject unassignRec : unassignRecs)
        {
            //If index equal to members.Size()-1 reset the index positon to -1
            if (index >= members.Size() || index == -1)
            {
                index = 0;
            }   

            //Adding delay time to the CreatDate field
            DateTime createDate = (dateTime)unassignRec.get('CreatedDate');
            DateTime comparisonDate = createDate.addMinutes(timeDelay);
    
            if (comparisonDate < presentTime)
            {
                string objectType= string.ValueOf(unassignRec.getsObjectType());
                if (objectType=='Lead')
                {
                    unassignRec.put(Lead.Assigned__c, True);
                    unassignRec.put(Lead.ownerId, members[index].UserOrGroupId);
                    unassignRec.put(Lead.Assigned_Users__c, members[index].UserOrGroupId);
                    unassignRec.put(Lead.Last_Assigned_Date__c, presentTime);
                    assignedRec.add(unassignRec);  
                }
                 else
                 {
                    unassignRec.put(Contact.Assigned__c, True);
                    unassignRec.put(Contact.ownerId, members[index].UserOrGroupId);
                    unassignRec.put(Contact.Assigned_Users__c, members[index].UserOrGroupId);
                    unassignRec.put(Contact.Last_Assigned_Date__c, presentTime);
                    assignedRec.add(unassignRec);
                 }

                index++;
            } 
        }
        
        finalIndex = index;  

        system.debug('Records to be updated size is : '+ assignedRec.size());
        if (!assignedRec.isEmpty())
        {
            Update assignedRec;
            noOfRecordsProcessed = assignedRec.size();
            system.debug('Updated records size is : '+ assignedRec.size());
        }
        
    }
    //Finish method
    Global void Finish(Database.BatchableContext leadContext)
    {
        System.debug('Inside Finish');
        RegistrationProcessUtility.setCounselorIndex(finalIndex);
        System.debug('Batch Job Id is....: '+ leadContext.getJobId());
        
        AsyncApexJob jobDetails = [Select id, status, totaljobItems, jobitemsprocessed, 
                                  			numberoferrors, createdby.email
                                  					from AsyncApexJob
                                  							Where id =: leadContext.getJobId()];
        
        System.debug('Intial index is: ' + initialIndex);
        System.debug('Final index is: ' + finalIndex);
        System.debug('Total records processed are: ' + noOfRecordsProcessed);
    }
}