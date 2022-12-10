public class TT_ViewSchedule_ProfCls {
    @AuraEnabled
    public static List<Wrp>  getSchedule(Date i_SelectedDate) {
        List<String> lst_Elec = new List<String>{'Open Elective', 'Professional Elective'};
            List<Wrp> wr = new List<Wrp>();
        Date loopingdate ;
        List<ScheduleWrp> schList = new List<ScheduleWrp>();
        Set<String> set_OfferingIds = new Set<String>();
        Set<Id> set_GroupId = new Set<Id>();
        Set<Id> set_ProgId = new Set<Id>();
        Integer count = 0;
        Set<String> slots = new Set<String>();
        if(i_SelectedDate == null) i_SelectedDate = system.today();
        
        Contact contactRec = [SELECT Id FROM Contact WHERE OwnerId =: UserInfo.getUserId() limit 1]; 
        
        for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,Section__c FROM hed__Course_Enrollment__c WHERE Active_Connection__c = true and hed__Contact__c =: contactRec.Id ]) {
            set_OfferingIds.add(eachConn.hed__Course_Offering__c); 
            set_GroupId.add(eachConn.Section__c);
        }
        system.debug(set_OfferingIds);
        set_GroupId.add(null);
        if(set_OfferingIds.size() > 0 ) {
            List<hed__Course_Offering_Schedule__c> cosList =  [SELECT Id,hed__Start_Time__c,hed__End_Time__c,Section__r.hed__Parent_Term__r.hed__Account__r.Name,hed__Course_Offering__r.hed__Course__r.Category__c,Slot__c,
                                                               Date__c,Section__r.Name,Status__c,Section__r.hed__Parent_Term__r.Term_Number__c,Batch_Group__r.Name, hed__Course_Offering__r.hed__Course__r.Name,hed__Time_Block__r.hed__Educational_Institution__c                                                          
                                                               FROM hed__Course_Offering_Schedule__c 
                                                               WHERE hed__Course_Offering__c in: set_OfferingIds and Date__c = THIS_WEEK
                                                               and Batch_Group__c in: set_GroupId
                                                               Order by Date__c,hed__Start_Time__c];
            for(hed__Course_Offering_Schedule__c eachCOS : cosList)
            {
                count++;
                if(loopingdate == null) loopingdate = eachCOS.Date__c;
                if( loopingdate != eachCOS.Date__c )
                {
                    
                    Integer d = loopingdate.day();
                    Integer mo = loopingdate.month();
                    Integer yr = loopingdate.year();                        
                    DateTime DT = DateTime.newInstance(yr, mo, d);
                    wr.add(new Wrp(schList,DT.format('EEEE'), schList.size()));
                    schList = new List<ScheduleWrp>();
                    loopingdate = eachCOS.Date__c;
                    set_ProgId = new Set<Id>();
                    slots = new Set<String>();
                } 
                if(!lst_Elec.contains(eachCos.hed__Course_Offering__r.hed__Course__r.Category__c) || 
                   !slots.contains(String.valueOf(eachCOS.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachCOS.hed__End_Time__c).substringBeforeLast(':')) ||
                   !set_ProgId.contains(eachCOS.hed__Time_Block__r.hed__Educational_Institution__c)) 
                {  
                    ScheduleWrp wrp = new ScheduleWrp();
                  
                    
                    wrp.schDate = eachCOS.Date__c;
                    wrp.schId = eachCOS.Id;
                    wrp.slotNum = Integer.valueof(eachCOS.Slot__c);
                    wrp.timeSlot = String.valueOf(eachCOS.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachCOS.hed__End_Time__c).substringBeforeLast(':');
                     if(!slots.contains(wrp.timeSlot)) set_ProgId = new Set<Id>();
                    slots.add(wrp.timeSlot);
                    
                    wrp.programName = eachCOS.Section__r.hed__Parent_Term__r.hed__Account__r.Name;
                     wrp.semNumber = Integer.valueof(eachCOS.Section__r.hed__Parent_Term__r.Term_Number__c);
                    wrp.courseName = eachCOS.hed__Course_Offering__r.hed__Course__r.Name;  
                    wrp.schstatus = eachCOS.Status__c;
                    wrp.groupName = eachCOS.Batch_Group__r.Name;
                    if(!lst_Elec.contains(eachCos.hed__Course_Offering__r.hed__Course__r.Category__c)) wrp.secName = eachCOS.Section__r.Name;
                    schList.add(wrp);
                    set_ProgId.add(eachCOS.hed__Time_Block__r.hed__Educational_Institution__c);
                    if(count == cosList.size()){
                        Integer d = loopingdate.day();
                    Integer mo = loopingdate.month();
                    Integer yr = loopingdate.year();                        
                    DateTime DT = DateTime.newInstance(yr, mo, d);
                    wr.add(new Wrp(schList,DT.format('EEEE'), schList.size()));
                    }
                }
            }
        }
        
        return wr;
    }
    
    public class Wrp{
        @AuraEnabled public List<ScheduleWrp> schWrp  {get;set;} 
        @AuraEnabled public String sDay  {get;set;} 
         @AuraEnabled public Integer rowspa {get;set;} 
        public Wrp(List<ScheduleWrp> schWrp,String sDay, Integer rowspa) {
            this.schWrp = schWrp;
            this.sDay = sDay;
            this.rowspa = rowspa;
        }
    }
    
    public class ScheduleWrp{
        @AuraEnabled public Date schDate {get;set;} 
        @AuraEnabled public String schId {get;set;} 
        @AuraEnabled public Integer slotNum {get;set;} 
        @AuraEnabled public String timeSlot {get;set;} 
        @AuraEnabled public String programName {get;set;} 
        @AuraEnabled public Integer semNumber {get;set;} 
         @AuraEnabled public String secName {get;set;} 
        @AuraEnabled public String groupName {get;set;} 
        @AuraEnabled public String courseName {get;set;} 
        @AuraEnabled public String schstatus {get;set;}        
    }
}