public class ReassignmentAndEscalation_Batch implements Database.Batchable < sObject > , Schedulable {

    //Post deployment steps
    /*ReassignmentAndEscalation_Batch escalationSchedule = new ReassignmentAndEscalation_Batch();
    String cronExpression = '0 0 0 * * ? *'; //Every day 12 O'Clock.
    system.schedule('Reassignment and Escalation', cronExpression, escalationSchedule); */

    //Get required configuration information
    //1. Counselors - Public Grroup.
    //2. Escalation Recipients - Public Group.
    //3. Required Hours for Reassignemnt - MetaData.
    //4. Required Hours for Escalation - MetaData.

    private Integer reqHoursForReassignment = (Integer)[Select Time__c From Batch_Config__mdt Where DeveloperName = 'Lead_Reassignment_Time_in_hours'
        Limit 1].Time__c;
    private Integer reqHoursForEscalation = (Integer)[Select Time__c From Batch_Config__mdt Where DeveloperName = 'Lead_Escalation_Notification_Time_in_hrs'
        Limit 1].Time__c;
    Datetime reassignedDateBefore = datetime.now().addhours(-(reqHoursForReassignment));
    Datetime escalationDateBefore = datetime.now().addhours(-(reqHoursForEscalation));

    private List < User > escalationRecipients = [SELECT id, Name from User Where id in (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Escalation_Notification_Recipient')];
    private List < GroupMember > counselors = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Admission_Counselor'
        ORDER BY UserOrGroupId
    ]; //Admission Counselors;
    private list < sObject > recordsToBeReassigned = new list < sObject > (); // List for Reassigned Records
    private list < sObject > recordsToBeEscalated = new list < sObject > (); // List for Escalatied Records
    private List < FeedItem > feedItemList = new list < FeedItem > ();
    private String contactRecordType = 'Applicant'; //Contact Record Type.
    private List < String > counselorsList = new List < String > ();
    private final String SPECIFIC_CATEGORY = 'Foreign Nationals'; //Lead/Contact Category 
    private final String SPECIFIC_SCHOOL = 'School of Performing Arts and Indic Studies'; //Lead/Contact School 
    private final String SPECIFIC_PROGRAM = 'Ph.D'; //Lead/Contact Program type
    private Map < String, String > leadProgramMap = New Map < String, String > ();
    private Map < String, String > contactProgramMap = New Map < String, String > ();
    private static Integer MAX_ASSIGNED_USERS = 13;

    //start testing
    private Integer reassignedRecordsCount = 0;
    private Integer escalatedRecordsCount = 0;
    private Integer unModifiedRecordsCount = 0;
    //end testing

    //To find the hours between two days.
    public Long HoursBetweenTwoDays(Long endDateInMilliseconds) {
        Long startDateInMilliseconds = DateTime.now().getTime();
        Long diffInMilliseconds = startDateInMilliseconds - endDateInMilliseconds;
        Long totalHours = diffInMilliseconds / 3600000; //convert milliseconds in to Hours
        return totalHours;
    }

    //Start Method
    public Iterable < sObject > start(Database.BatchableContext bc) {
        System.debug('Inside Start');

        List < Fee_Master__c > feeMasterProgramList = [SELECT Program_Name_Display__c, Program_Name__c, Program_Type__c
            FROM Fee_Master__c
            WHERE Program_Type__c =: SPECIFIC_PROGRAM
        ];

        for (Fee_Master__c feeMasterProgram: feeMasterProgramList) {
            leadProgramMap.put(feeMasterProgram.Program_Name_Display__c, feeMasterProgram.Program_Type__c);
            contactProgramMap.put(feeMasterProgram.Program_Name__c, feeMasterProgram.Program_Type__c);
        }

        //Get Lead and Contact Data 
        List < sObject > unModifiedRecords = new List < sObject > ();
        unModifiedRecords.addAll([SELECT Id, Program_Name_Display__c, Name, Assigned_Users__c, CreatedDate, OwnerId, Last_Assigned_Date__c, Last_Escalation_Date__c ,School_Name__c, Select_Category__c
                                        FROM Lead
                                        WHERE LastActivityDate = Null
                                        AND Assigned_Users__c != Null
                                        AND (Status != 'Unqualified'
                                        OR Status != 'Payment Pending') 
                                        AND (Last_Assigned_Date__c <=: reassignedDateBefore
                                        OR Last_Escalation_Date__c <=: escalationDateBefore)
                                ]); //Lead Data 
        unModifiedRecords.addAll([SELECT Id, Program_Name__c,Select_Category__c, School_Name__C,	Name, Assigned_Users__c, CreatedDate, OwnerId, Last_Assigned_Date__c, Last_Escalation_Date__c
              FROM Contact
             WHERE Assigned_Users__c != Null
              AND LastActivityDate = Null
              AND Record_Type_Name__c =: contactRecordType
              AND Application_Fee_Paid__c = False
              AND (Last_Assigned_Date__c <=: reassignedDateBefore
              OR Last_Escalation_Date__c <=: escalationDateBefore) 
        ]); //Contact Data  
        unModifiedRecordsCount = unModifiedRecords.size();
        system.debug(unModifiedRecords);
        return unModifiedRecords;
    }

    //Execute Method
    public void execute(Database.BatchableContext BC, List < sObject > unModifiedRecords) {

        System.debug('Inside Execute');
        for (GroupMember counselor: counselors) {
            counselorsList.add(counselor.UserOrGroupId);
        }
        System.debug('Total number of counselors' + counselors.size());
        System.debug('Total number of counselors List' + counselorsList.size());
        System.debug('Total number of Escalation Recipients' + escalationRecipients.size());

        for (sObject eachUnmodifiedRec: unModifiedRecords) {
            String newOwnerId;
            String assignedUsers;
            DateTime lastEscalatedDate;
            Long endDateInMilliSeconds;
            Long hoursAfterLastEscalation;
            String programType;


            if (string.valueOf(eachUnmodifiedRec.getSObjectType()) == 'Lead') {
                programType = leadProgramMap.get(String.valueOf(eachUnmodifiedRec.get('Program_Name_Display__c')));

            } else {
                programType = contactProgramMap.get(String.valueOf(eachUnmodifiedRec.get('Program_Name__c')));
            }

            if (eachUnmodifiedRec.get('School_Name__c') != SPECIFIC_SCHOOL &&
                eachUnmodifiedRec.get('Select_Category__c') != SPECIFIC_CATEGORY &&
                programType != SPECIFIC_PROGRAM) { //exclude the special cases from re-assignment
                // Get hours in last assigned date from today.
                Datetime lastAssignedDate = Datetime.valueOf(eachUnmodifiedRec.get('Last_Assigned_Date__c'));
                Long hoursAfterLastAssignment = HoursBetweenTwoDays(lastAssignedDate.getTime());

                //start Reassignment. 
                if (hoursAfterLastAssignment >= reqHoursForReassignment) {
                    reassignedRecordsCount++; //Testing
                    assignedUsers = String.valueOf(eachUnmodifiedRec.get('Assigned_Users__C'));
                    String[] assignedUsersList = assignedUsers.split(',');
                    Integer counsIndex = counselorsList.indexOf(String.valueOf(eachUnmodifiedRec.get('OwnerId')));
                    Integer nextIndex = counsIndex + 1;
                    if (assignedUsersList.size() < counselorsList.size()) {
                        if (assignedUsersList.size() <= MAX_ASSIGNED_USERS) { //check assigned users count is less then 13 or not - field limitation(255 chr). 
                            if (nextIndex > counselorsList.size() - 1) {
                                nextIndex = 0;
                            }
                            newOwnerId = counselorsList.get(nextIndex); // else set the owner to the next counselor in the list
                            assignedUsers = assignedUsers + ',' + newOwnerId;
                        } else {
                            newOwnerId = escalationRecipients[0].Id; // Default Owner (first id of the assignedUsers field )
                        }
                    } else {
                        if (!assignedUsersList.isEmpty()) {
                            if (new Set < string > (counselorsList).contains(assignedUsersList[0])) { //check default owner is available in the public group.
                                newOwnerId = assignedUsersList[0]; // Default Owner (first id of the assignedUsers field )
                            } else {
                                if (!escalationRecipients.isEmpty()) {
                                    newOwnerId = escalationRecipients[0].Id; // Default Owner (first id of the assignedUsers field )
                                }
                            }
                        }
                    }

                    /* if (assignedUsersList.size() < counselorsList.size()) {
                        Integer counselorPosition = 1;
                        for (Integer i = 0; i < counselorsList.size(); i++) { //remove for loop
                            if ((counsIndex + counselorPosition) == counselorsList.size()) {
                                //counsIndex = 0;
                                counselorPosition = -(counselorsList.size()-1);
                            }
                            if (!assignedUsers.Contains(counselorsList.get(counsIndex + counselorPosition))) { //if doesn't contain
                                newOwnerId = counselorsList.get(counsIndex + counselorPosition); // else set the owner to the next counselor in the list
                                assignedUsers = assignedUsers + ',' + newOwnerId;
                                system.debug('New Owner : ' + newOwnerId);
                                //counselorPosition++;
                                break;
                            } else {
                                counselorPosition++;
                            }
                            
                        }
                    } else {
                        //set the owner to the first person in the list only if not already  the same user. 
                        if (assignedUsersList[0] != eachUnmodifiedRec.get('OwnerId')) {
                            newOwnerId = assignedUsersList[0]; 
                        }
                        
                    } */
                    if (newOwnerId != null) {
                        if (string.valueOf(eachUnmodifiedRec.getSObjectType()) == 'Lead') {
                            eachUnmodifiedRec.put(Lead.Assigned_Users__c, assignedUsers);
                            eachUnmodifiedRec.put(Lead.OwnerId, newOwnerId);
                            eachUnmodifiedRec.put(Lead.Last_Assigned_Date__c, DateTime.now());
                            recordsToBeReassigned.add(eachUnmodifiedRec);
                        } else {
                            eachUnmodifiedRec.put(Contact.Assigned_Users__c, assignedUsers);
                            eachUnmodifiedRec.put(Contact.OwnerId, newOwnerId);
                            eachUnmodifiedRec.put(Contact.Last_Assigned_Date__c, DateTime.now());
                            recordsToBeReassigned.add(eachUnmodifiedRec);
                        }
                    }
                }
            }
            //End Reassignment.

            /*Send notification to admin if there is no changes in Records */
            //Start Escalation.
            if (eachUnmodifiedRec.get('Last_Escalation_Date__c') != Null) {
                lastEscalatedDate = DateTime.valueOf(eachUnmodifiedRec.get('Last_Escalation_Date__c'));
                hoursAfterLastEscalation = HoursBetweenTwoDays(lastEscalatedDate.getTime());
            } else {
                lastEscalatedDate = Date.valueOf(eachUnmodifiedRec.get('CreatedDate')); //If not escalated previosuly it will fetch based on the created Date
                hoursAfterLastEscalation = HoursBetweenTwoDays(lastEscalatedDate.getTime());
            }

            if (hoursAfterLastEscalation >= reqHoursForEscalation || (eachUnmodifiedRec.get('Last_Escalation_Date__c') == Null && hoursAfterLastEscalation >= reqHoursForEscalation)) {
                escalatedRecordsCount++; //Testing
                for (User recipient: escalationRecipients) {
                    FeedItem chatterPost = new FeedItem();
                    chatterPost.ParentId = recipient.id;
                    String recordPageUrl = system.URL.getSalesforceBaseUrl().toExternalForm() +
                        '/lightning/r/' + string.valueof(eachUnmodifiedRec.getSObjectType()) +
                        '/' + string.valueof(eachUnmodifiedRec.id) + '/view';
                    chatterPost.Body = 'Hi ' + recipient.Name +
                        '\nThis is to notify you that there has been no activity on the Applicant -' + String.ValueOf(eachUnmodifiedRec.get('Name')) +
                        ' in the last ' + reqHoursForEscalation +
                        ' hours. Please click on the following link to navigate to the record: ' + recordPageUrl;
                    feedItemList.add(chatterPost);
                }
                if (string.valueOf(eachUnmodifiedRec.getSObjectType()) == 'Lead') {
                    eachUnmodifiedRec.put(Lead.Last_Escalation_Date__c, DateTime.now());
                    recordsToBeEscalated.add(eachUnmodifiedRec);
                } else {
                    eachUnmodifiedRec.put(Contact.Last_Escalation_Date__c, DateTime.now());
                    recordsToBeEscalated.add(eachUnmodifiedRec);
                }
            }
        }
        //End Escalation.
        //Update recordsToBeReassigned;
        //Update recordsToBeEscalated;
        //insert feedItemList;
        system.debug(recordsToBeReassigned.size() + 'after update');

    }

    //Finish Method
    Public void finish(Database.BatchableContext BC) {
        System.debug(' Inside Finish');
        System.debug(' Unmodified Records Count : ' + unModifiedRecordsCount);
        System.debug(' Modified Records : ' + (reassignedRecordsCount + escalatedRecordsCount));
        System.debug(' Reassigned Records Count : ' + reassignedRecordsCount);
        System.debug(' Escalated Records Count : ' + escalatedRecordsCount);
        System.debug(' Required Hours for Reassignment : ' + reqHoursForReassignment);
        System.debug(' Required Hours for Escalation : ' + reqHoursForEscalation);
        System.debug(' Completed ');
    }

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new ReassignmentAndEscalation_Batch());
    }
}