public class LeadAssignment_Batch implements Database.Batchable<sObject>, Database.Stateful {
    //Post deployment steps
    /*LeadAssignment_Scheduler sch = new LeadAssignment_Scheduler();
    System.schedule('Lead assignment schedule - I', '0 00 * * * ? ' , sch);
    System.schedule('Lead assignment schedule - II', '0 15 * * * ? ' , sch);
    System.schedule('Lead assignment schedule - III', '0 30 * * * ? ' , sch);
    System.schedule('Lead assignment schedule - IV', '0 45 * * * ? ' , sch);*/

    private Integer initialIndex;
    private Integer finalIndex;
    private Integer noOfRecordsProcessed = 0;
    private Integer timeDelay = (Integer) Batch_Config__mdt.getInstance('Lead_Assignment_Time_Delay_in_minutes').Time__c; //Get delay time 
    private dateTime presentTime = System.now();  //Get present time 
    private List<GroupMember> counselors;
    private List<Fee_Master__c> feeMasterProgramList;
    private static final String SPECIFIC_CATEGORY = 'Foreign Nationals'; //Lead/Contact Category 
    private static final String SPECIFIC_SCHOOL = 'School of Performing Arts and Indic Studies'; //Lead/Contact School 
    private static final String SPECIFIC_PROGRAM_TYPE = 'Ph.D'; //Lead/Contact Program type
    private static String foreignerCounselorFedId = (String) General_Setting__mdt.getInstance('FOREIGNER_COUNSELOR').Text_Value__c; //Get Foreign nationals counselor mail Id
    private static String perArtsCounselorFedId = (String) General_Setting__mdt.getInstance('PERFORMING_ARTS_COUNSELOR').Text_Value__c; //Get Performing arts counselor maild Id
    private static String phdProgramCounselorFedId = (String) General_Setting__mdt.getInstance('PHD_COUNSELOR').Text_Value__c; //Get Ph.d counselor maild Id
    private Id foreignerCounselorId;
    private Id performingArtsCounselorId;
    private Id PhdCounselorId;
    private Map<String, String> leadProgramTypeMap = New Map<String, String>();
    private Map<String, String> contactProgramTypeMap = New Map<String, String>();

    private  void getSpecificCounselor() {
        //Get User Id from users by matching FederationIdentifier
        List<User> foreignerCounselor = [SELECT Id, FederationIdentifier FROM User 
                                    Where FederationIdentifier = :foreignerCounselorFedId Limit 1];
        List<User> perArtsCounselor = [SELECT Id, FederationIdentifier FROM User 
                                    Where FederationIdentifier = :perArtsCounselorFedId Limit 1];
        List<User> phdProgramCounselor = [SELECT Id, FederationIdentifier FROM User 
                                    Where FederationIdentifier = :phdProgramCounselorFedId Limit 1];
        if(!foreignerCounselor.isEmpty()){
            foreignerCounselorId = foreignerCounselor[0].Id;
        } 
        if (!perArtsCounselor.isEmpty()){
            performingArtsCounselorId = perArtsCounselor[0].Id;
        } 
        if (!phdProgramCounselor.isEmpty()){
            PhdCounselorId = phdProgramCounselor[0].Id;
        }
    }

    //Start method
    public Iterable<SObject> Start(Database.BatchableContext bc) {
        System.debug('****** Inside Start ******');
        getSpecificCounselor(); //Method to get Dedicated counselore user Ids
        initialIndex = RegistrationProcessUtility.getCounselorIndex();
        //Get Counselors from public group
        counselors = [SELECT GroupId, UserOrGroupId, Group.Name 
                        FROM GroupMember 
                        WHERE Group.DeveloperName = 'Admission_Counselor' 
                        ORDER BY UserOrGroupId ];
        feeMasterProgramList =  [SELECT Program_Name_Display__c, Program_Name__c, Program_Type__c
                                    FROM Fee_Master__c
                                    WHERE Program_Type__c = :SPECIFIC_PROGRAM_TYPE];
        for(Fee_Master__c feeMasterProgram : feeMasterProgramList) {
            leadProgramTypeMap.put(feeMasterProgram.Program_Name_Display__c, feeMasterProgram.Program_Type__c);
            contactProgramTypeMap.put(feeMasterProgram.Program_Name__c, feeMasterProgram.Program_Type__c);
        }
        //Get Leads and Contacts to be assigned to counselors
        List<sObject> unassignedRecs = new List<sObject>();
        unassignedRecs.addAll([Select id, Name, Phone, Assigned__c, OwnerId, CreatedDate, Select_Category__c, 
                                School_Name__c, Program_Name_Display__c, Assigned_Users__c, 
                                Program_Name__c, Status From Lead 
                                Where Assigned__c = False And ((Status != 'Unqualified') Or (Status != 'Payment Pending'))]);
        unassignedRecs.addAll([Select id, Name, Phone, Assigned__c, OwnerId, CreatedDate, Select_Category__c, School_Name__c, 
                                Program_Name__c, Assigned_Users__c 
                                From Contact 
                                Where Assigned__c= False AND Record_Type_Name__c = 'Applicant']);
        return unassignedRecs;  
    }

    //Execute method
    public void Execute(Database.BatchableContext bContext, List<sObject> unassignedRecs) {
        System.debug('****** Inside Execute ******');
        System.debug('Total unassign records size:'+ unassignedRecs.size());
        Integer index = initialIndex;  //Set next counselor index to initial index
        List<sObject> recsToBeAssigned = new List<sObject>(); //Collection of all comon records         
        for (sObject unassignedRec : unassignedRecs) {
            string objectType= string.ValueOf(unassignedRec.getsObjectType()); //Get Object type from current record
            DateTime createDate = (dateTime)unassignedRec.get('CreatedDate'); //Get created date from current record
            String selectCategory = (String)unassignedRec.get('Select_Category__c'); //Get Category from current record 
            String schoolName = (String)unassignedRec.get('School_Name__c'); //Get school name from current record
            String programNameDisplay;
            String  programName;
            if (objectType=='Lead') {
                programNameDisplay = (String)unassignedRec.get('Program_Name_Display__c'); //Get program name from current lead record
            } else {
                programName= (String)unassignedRec.get('Program_Name__c'); //Get Program name from current contact record
            }
            String assignedUsers = (String)unassignedRec.get('Assigned_Users__c'); //Get assigned users for the current record
            DateTime comparisonDate = createDate.addMinutes(timeDelay); //Adding delay time to the CreatDate field
            
            if (selectCategory == SPECIFIC_CATEGORY || schoolName == SPECIFIC_SCHOOL || 
                   ( leadProgramTypeMap.get(programNameDisplay)==SPECIFIC_PROGRAM_TYPE || 
                   contactProgramTypeMap.get(programName)==SPECIFIC_PROGRAM_TYPE ) || assignedUsers != null) {
                String newOwner;
                if ((objectType=='Contact' || objectType=='Lead') && selectCategory == SPECIFIC_CATEGORY) {
                    newOwner = foreignerCounselorId;
                     assignedUsers = assignedUsers == null ? newOwner : assignedUsers + ',' + newOwner;
                } else if ((objectType=='Contact' || objectType=='Lead') && schoolName == SPECIFIC_SCHOOL) {
                    newOwner = performingArtsCounselorId;
                     assignedUsers = assignedUsers == null ? newOwner : assignedUsers + ',' + newOwner;
                } else if ((objectType=='Lead' && leadProgramTypeMap.get(programNameDisplay)==SPECIFIC_PROGRAM_TYPE) ||
                            (objectType =='Contact' && contactProgramTypeMap.get(programName)==SPECIFIC_PROGRAM_TYPE)) {
                    newOwner = PhdCounselorId;
                     assignedUsers = assignedUsers == null ? newOwner : assignedUsers + ',' + newOwner;
                } else if ((objectType=='Contact' || objectType=='Lead') && assignedUsers != null) {
                    newOwner = assignedUsers?.left(18);
                }
                    if (objectType=='Lead') {
                        unassignedRec.put(Lead.Assigned__c, True);
                        unassignedRec.put(Lead.Last_Assigned_Date__c, presentTime);
                        unassignedRec.put(Lead.ownerId, newOwner);
                        unassignedRec.put(Lead.Assigned_Users__c, assignedUsers);
                        recsToBeAssigned.add(unassignedRec); 
                    } else {
                        unassignedRec.put(Contact.Assigned__c, True);
                        unassignedRec.put(Contact.Last_Assigned_Date__c, presentTime);
                        unassignedRec.put(Contact.ownerId, newOwner);
                        unassignedRec.put(Contact.Assigned_Users__c, assignedUsers);
                        recsToBeAssigned.add(unassignedRec);
                    }
            } else {
                    //Check if index needs to be reset 
                    if (index >= counselors.Size() || index == -1) {
                        index = 0;
                    } 
                    if (comparisonDate < presentTime) {
                        if (objectType=='Lead') {
                            unassignedRec.put(Lead.Assigned__c, True);
                            unassignedRec.put(Lead.Last_Assigned_Date__c, presentTime);
                            unassignedRec.put(Lead.ownerId, counselors[index].UserOrGroupId);
                            unassignedRec.put(Lead.Assigned_Users__c, counselors[index].UserOrGroupId);
                            recsToBeAssigned.add(unassignedRec); 
                        } else {
                            unassignedRec.put(Contact.Assigned__c, True);
                            unassignedRec.put(Contact.Last_Assigned_Date__c, presentTime);
                            unassignedRec.put(Contact.ownerId, counselors[index].UserOrGroupId);
                            unassignedRec.put(Contact.Assigned_Users__c, counselors[index].UserOrGroupId);
                            recsToBeAssigned.add(unassignedRec);
                        }
                        index++;
                    } 
                }
        }
        finalIndex = index; 
        if (!recsToBeAssigned.isEmpty()) {
            update recsToBeAssigned;
            noOfRecordsProcessed += recsToBeAssigned.size();
        }
    }
    //Finish method
    public void Finish(Database.BatchableContext leadContext) {
        System.debug('****** Inside Finish ******');
        System.debug('Intial index is: ' + initialIndex);
        System.debug('Final index is: ' + finalIndex);
        System.debug('Total records processed are: ' + noOfRecordsProcessed);
        if (noOfRecordsProcessed > 0) {
            RegistrationProcessUtility.setCounselorIndex(finalIndex);
        }
    }
}