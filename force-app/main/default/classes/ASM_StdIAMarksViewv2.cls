public without sharing class ASM_StdIAMarksViewv2 {
    @AuraEnabled
    public static dataWpr fetchData(String iaType){
        User cUser = [SELECT Id,ContactId,Contact.Active_Semester__c,Contact.Active_Semester__r.Name FROM User WHERE Id =: UserInfo.getUserId()];
        dataWpr dWpr = new dataWpr();
        if(cUser.ContactId != null && cUser.Contact.Active_Semester__c != null) dWpr.activeSem = cUser.Contact.Active_Semester__r.Name;
        dWpr.list_IAMarks = new List<IA_Marks__c>();
        Map<String,crsWpr> map_Data = new Map<String,crsWpr>();
        if(iaType != ''){
            for(IA_Marks__c iam : [SELECT Id,Total_Secured_Marks__c,
                                   Course_Offering__r.hed__Course__r.Name,
                                   Course_Offering__r.hed__Course__r.Maximum_Internal_Marks__c,
                                   Theory_Secured_Marks__c,Seminar_Secured_Marks__c,Quiz_Secured_marks__c,
                                   Analysis_and_Synthesis_Secured_Marks__c,Continuous_Learning_Secured_Marks__c,
                                   Ethical_Attitude_Secured_Marks__c,Independent_Learning_Secured_Marks__c,
                                   Literature_Survey_Secured_Marks__c,Selection_of_Topic_Secured_Marks__c,
                                   Oral_Presentation_Secured_Marks__c,Report_Writing_Secured_Marks__c,Course_Type__c,
                                   Knowledge_of_Exercise_Secured_Marks__c,Execution_of_Exercise_Secured_Marks__c,
                                   Description_of_Experiment_Secured_Mark__c,Viva_Voce_Practical_Secured_Marks__c,
                                   Punctuality_Secured_Marks__c,Results_Secured_Marks__c,Course_Connection__c,
                                   Course_Offering__r.hed__Course__r.Seminar_Maximum_Marks__c,
                                   Course_Offering__r.hed__Course__r.Quiz_Maximum_Marks__c,
                                   Course_Offering__r.hed__Course__r.Theory_Maximum_Marks__c,
                                   Course_Offering__r.hed__Course__r.Analysis_and_Synthesis_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Literature_Survey_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Ethical_Attitude_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Independent_Learning_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Oral_Presentation_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Report_Writing_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Continuous_Learning_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Selection_of_Topic_Max_marks__c,
                                   Course_Offering__r.hed__Course__r.Knowledge_of_Exercise_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Execution_of_Exercise_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Description_of_Experiment_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Viva_Voce_Practical_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Punctuality_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Results_Max_Marks__c
                                   FROM IA_Marks__c WHERE IA_Type__c =: iaType 
                                   AND Course_Offering__r.hed__Term__r.hed__Parent_Term__r.Active__c = true 
                                   AND Course_Offering__r.Publish_to_Students__c = true
                                   AND Course_Connection__r.hed__Contact__c =: cUser.ContactId //= '0030w00000qjUpX'
                                   AND Course_Connection__r.RecordType.Name = 'Student'])
            {
                dWpr.list_IAMarks.add(iam);
                
                if(map_Data.get(iam.Course_Type__c) != null){
                    map_Data.get(iam.Course_Type__c).list_IAMarks.add(iam);
                }else{
                    crsWpr cWpr = new crsWpr();
                    cWpr.crsType = iam.Course_Type__c;
                    cWpr.list_IAMarks = new List<IA_Marks__c>();
                    cWpr.list_IAMarks.add(iam);
                    map_Data.put(iam.Course_Type__c,cWpr);
                }
            }
        }
        dWpr.list_crsWpr = map_Data.values();
        return dWpr;
    }
    public class dataWpr{
        @AuraEnabled public String activeSem{get;set;}
        @AuraEnabled public List<IA_Marks__c> list_IAMarks{get;set;}
        @AuraEnabled public List<crsWpr> list_crsWpr{get;set;}
    }
    public class crsWpr{
        @AuraEnabled public String crsType{get;set;}
        @AuraEnabled public List<IA_Marks__c> list_IAMarks{get;set;}
    }
}