public with Sharing class TT_ViewSchedule_StudentCls {
   
    @AuraEnabled
    public static ResponseWrp getTimeTableRecords(){
        List<SlotTimeWrp> lst_Slot = new List<SlotTimeWrp>();
        Set<Time> uTime = new Set<Time>(); 
        Set<Id> set_Ids = new Set<Id>();
        Set<String> set_OfferingIds = new Set<String>();
        String tempHold = '';
        Integer count ;
        Map<String, list<SlotWrp>> tempWrp = new Map<String, List<SlotWrp>>();
        Map<String,List<hed__Course_Offering_Schedule__c>> dayAndCOSMap = new Map<String,List<hed__Course_Offering_Schedule__c>>();
        List<String> daysList = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday', 'Saturday', 'Sunday'};
            ResponseWrp wrp = new ResponseWrp();
        User usr =[select Id,Name,ContactId from User where Id =:UserInfo.getUserId()];
        Contact contactRec = new Contact();
        if(usr.ContactId != null)
        contactRec = [SELECT Id FROM Contact WHERE id =: usr.ContactId];
        String sectionId = '';
        for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,hed__Course_Offering__r.Category__c,Section__c FROM hed__Course_Enrollment__c 
                                                  WHERE Active_Connection__c = true and hed__Contact__c =: contactRec.Id]) {
            set_OfferingIds.add(eachConn.hed__Course_Offering__c);
            if(eachConn.Section__c != null && eachConn.hed__Course_Offering__r.Category__c =='Hardcore Course') sectionId = eachConn.Section__c;
            set_Ids.add(eachConn.Section__c);
        }
        set_Ids.add(null);
        //set_OfferingIds.add(null);
        hed__Term__c term =[SELECT hed__Account__r.Name,hed__Parent_Term__r.Academic_Year__c,hed__Account__r.Parent.name,Section_Name__c,hed__Parent_Term__r.Term_Number__c from hed__Term__c where Id =: sectionId];
        wrp.programName = term.hed__Account__r.Name;
        wrp.schoolName = term.hed__Account__r.Parent.name;
        wrp.semesterName = string.valueof(term.hed__Parent_Term__r.Term_Number__c);
        wrp.secName = term.Section_Name__c;
        wrp.acdYear = term.hed__Parent_Term__r.Academic_Year__c;
        wrp.lst_Faculties = getFaculties(sectionId, set_OfferingIds);       
        
        //System.debug('====set_OfferingIds===='+set_OfferingIds);
        if(set_OfferingIds.size() > 0 ) {
            for(hed__Course_Offering_Schedule__c cosObj : [SELECT Id,hed__Start_Time__c,hed__End_Time__c,Section__r.hed__Parent_Term__r.hed__Account__r.Name,hed__Course_Offering__c,
                                                           Status__c,Section__r.hed__Parent_Term__r.Term_Number__c,Batch_Group__r.Batch_Short_Name__c, hed__Course_Offering__r.hed__Course__r.Name ,
                                                           Break__c,hed__Monday__c,hed__Tuesday__c,hed__Wednesday__c,hed__Thursday__c,hed__Friday__c,hed__Saturday__c,hed__Sunday__c,
                                                           hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,Display_Name__c,Free_Slot__c
                                                          FROM hed__Course_Offering_Schedule__c 
                                                          WHERE Date__c = null and Batch_Group__c in: set_Ids and 
                                                                (hed__Course_Offering__c in: set_OfferingIds or 
                                                                 (Section__c =: sectionId and hed__Course_Offering__c = null and 
                                                                  (hed__Saturday__c = true or hed__Sunday__c = true or Break__c = true or Free_Slot__c = true or Display_Name__c != null)))
                                                          Order by hed__Start_Time__c])
            {
                if(!uTime.contains(cosObj.hed__Start_Time__c)) {
                    lst_Slot.add(new SlotTimeWrp(String.valueOf(cosObj.hed__Start_Time__c).substringBeforeLast(':'),String.valueOf(cosObj.hed__End_Time__c).substringBeforeLast(':')));
                    uTime.add(cosObj.hed__Start_Time__c);
                }
                
                String keyStr = cosObj.hed__Monday__c ? 'Monday' :
                cosObj.hed__Tuesday__c ? 'Tuesday' :
                cosObj.hed__Wednesday__c ? 'Wednesday' :
                cosObj.hed__Thursday__c ? 'Thursday' :
                cosObj.hed__Friday__c ? 'Friday' : 
                cosObj.hed__Saturday__c ? 'Saturday' :
                cosObj.hed__Sunday__c ? 'Sunday' : '';
                if(dayAndCOSMap.get(keyStr) == null)
                    dayAndCOSMap.put(keyStr, new List<hed__Course_Offering_Schedule__c>{cosObj});           
                else
                    dayAndCOSMap.get(keyStr).add(cosObj);
                
            }
        }
        List<SlotWrp> s;
        for(String dayName : daysList) { 
            s = new List<SlotWrp>();
            for(Time t : uTime) {
                s.add(new SlotWrp(t + '','', 1)); 
            }
            tempWrp.put(dayName, s);
        }        
        
        if(dayAndCOSMap.size() == 0) {
            wrp.resStatus  = 'Error';
            wrp.resMessage = 'No Schedule found for the given Student.';
            return wrp;
        }        
        else{
            wrp.resStatus  = 'Success';
        }
        wrp.lst_TimeSlot = lst_Slot;
        wrp.lst_Sch = new List<ScheduleWrp>();
        Map<String,String> slotAndCSMap ;
        
        for(String day:daysList){
            List<SlotWrp> lst_Slots = new List<SlotWrp>();
            slotAndCSMap = new Map<String,String>();
            if(dayAndCOSMap.get(day) != null) {
                for(hed__Course_Offering_Schedule__c cos: dayAndCOSMap.get(day)){ 
                    String cs = slotAndCSMap.get(String.valueof(cos.hed__Start_Time__c));
                    if(String.isBlank(cs)) cs = '' ;
                    else cs = '';
                    if(cos.Break__c && !(cos.hed__Saturday__c  || cos.hed__Sunday__c)) cs = 'Break';
                    else if(cos.Free_Slot__c) cs = '';
                    else if(!cos.Break__c && !(cos.hed__Saturday__c  || cos.hed__Sunday__c) && cos.hed__Course_Offering__c == null){
                        cs = cos.Display_Name__c == null ? '' : cos.Display_Name__c;
                    }
                    cs +=  cos.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c == null ? '' : cos.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c ;
                    if(cos.Batch_Group__r.Batch_Short_Name__c != null) cs += '(' + cos.Batch_Group__r.Batch_Short_Name__c + ')';
                    slotAndCSMap.put(String.valueof(cos.hed__Start_Time__c), cs);         
                   
                }
                List<SlotWrp> temp = tempWrp.get(day);
                for(SlotWrp slot : temp) {
                    if(slotAndCSMap.containskey(slot.slotname)){
                        lst_Slots.add(new SlotWrp(slot.slotname + '',slotAndCSMap.get(slot.slotname), 1));
                    }
                    else lst_Slots.add(slot);
                }
               /* for(Time t: slotAndCSMap.keySet()){                   
                     lst_Slots.add(new SlotWrp(t + '',slotAndCSMap.get(t), 1));                                   
                }*/
                wrp.lst_Sch.add(new ScheduleWrp( day, lst_Slots));
            }
        }
        
        
        return wrp;
    }
    
    public static List<FacultyWrp> getFaculties(String i_SectionId, Set<String> set_OfferingIds ) {
        Id facRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        List<FacultyWrp> o_Faculties = new List<FacultyWrp>();
        map<String, String> mp_Fac = new Map<String, String>();
        map<String, String> mp_CourseName = new Map<String, String>();
        
        
        for(hed__Course_Enrollment__c eachConn : [SELECT Id,Course_Code__c,hed__Course_Offering__r.Name,hed__Contact__r.Name 
                                                  FROM hed__Course_Enrollment__c where RecordTypeId =: facRecordTypeId and hed__Course_Offering__c in: set_OfferingIds ]) {
            mp_CourseName.put(eachConn.Course_Code__c, eachConn.hed__Course_Offering__r.Name);
            if(mp_Fac.get(eachConn.Course_Code__c) == null){
               mp_Fac.put(eachConn.Course_Code__c, eachConn.hed__Contact__r.Name);
            }
            else{
                mp_Fac.put(eachConn.Course_Code__c, mp_Fac.get(eachConn.Course_Code__c) + '/ '  + eachConn.hed__Contact__r.Name);
            }            
        }
        
        for(string eachConn : mp_Fac.keyset()) {
            o_Faculties.add(new FacultyWrp(null,eachConn,mp_CourseName.get(eachConn),mp_Fac.get(eachConn)));
        }
        return o_Faculties;
    }
    
    public class ResponseWrp{
        @AuraEnabled public String resStatus {get;set;}
        @AuraEnabled public String resMessage {get;set;}
        @AuraEnabled public String schoolName {get;set;}
        @AuraEnabled public String programName {get;set;}
        @AuraEnabled public String semesterName {get;set;}
        @AuraEnabled public String secName {get;set;}
        @AuraEnabled public String acdYear  {get;set;}
        @AuraEnabled public List<ScheduleWrp> lst_Sch {get;set;}  
        @AuraEnabled public List<SlotTimeWrp> lst_TimeSlot {get;set;}  
        @AuraEnabled public List<FacultyWrp> lst_Faculties {get;set;}  
        
    }
    
    public class ScheduleWrp {
        // @AuraEnabled public String recId {get;set;}
        @AuraEnabled public String dayName {get;set;}
        @AuraEnabled public List<SlotWrp> lst_Slots {get;set;}        
        public ScheduleWrp(/* String recId,*/ String dayName, List<SlotWrp> lst_Slots) {
            //  this.recId = recId;
            this.dayName = dayName;
            this.lst_Slots = lst_Slots;
        }        
    }
    
    public class SlotWrp{
        @AuraEnabled public String slotname {get;set;}
        @AuraEnabled public String  courseNames {get;set;}
        @AuraEnabled public Integer  colLen {get;set;}
        public SlotWrp( String slotname, String  courseNames,Integer  colLen) {
            this.slotname = slotname;
            this.courseNames = courseNames;
            this.colLen = colLen;
        }      
    }
    
    public class SlotTimeWrp{
        @AuraEnabled public String sTime {get;set;}
        @AuraEnabled public String eTime {get;set;}        
        public SlotTimeWrp(String sTime, String eTime){
            this.sTime = sTime;
            this.eTime = eTime;
        }
    }
    
    public class FacultyWrp{
        @AuraEnabled public String connectionId {get;set;}
        @AuraEnabled public String  courseCode {get;set;}
        @AuraEnabled public String  coursename {get;set;}
        @AuraEnabled public String  facultyName {get;set;}
        public FacultyWrp( String connectionId, String  courseCode,String  coursename ,String  facultyName ) {
            this.connectionId = connectionId;
            this.courseCode = courseCode;
            this.coursename = coursename;
            this.facultyName = facultyName;
        }      
    }
    
}