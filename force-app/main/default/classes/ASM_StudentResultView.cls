public class ASM_StudentResultView {
    @AuraEnabled
    public static dataWpr fetchData(String summaryId){
        User cUser = [SELECT Id,ContactId,Contact.Active_Semester__c,Contact.Active_Semester__r.Name FROM User WHERE Id =: UserInfo.getUserId()];
        dataWpr dWpr = new dataWpr();
        dWpr.summaryRec = [SELECT Id,Remarks__c,CGPA__c,SGPA__c,Passing_Criteria__c,Examination_Month_Year__c FROM hed__Term_Grade__c WHERE Id =: summaryId];
        dWpr.list_Results = new List<hed__Term_Grade__c>();
        for(hed__Term_Grade__c tg : [SELECT Id,Secured_External_Marks__c,Secured_Internal_Marks__c,Examination_Month_Year__c,
                                     Recent_Result_Updated_Date__c,hed__Result__c,No_of_Credits__c,Course__r.hed__Course_ID__c,
                                     Maximum_Marks_Course_Level__c,Total_Secured_Marks_Course_Level__c,Grade_Points__c,Grade__c, 
                                     Credit_Points__c,CGPA__c,Course__c,Course__r.Name,Course__r.Course_Type_Logisys__c, 
                                     Course__r.Total_Maximum_Marks_IA_External__c,Total_Secured_Marks_Course__c FROM hed__Term_Grade__c
                                     WHERE Result_Summary__c =: summaryId ORDER BY Course__r.Course_Type_Logisys__c DESC
                                    ])
        {
            dWpr.list_Results.add(tg);
        }
        return dWpr;
    }
    
    public class dataWpr{
        //@AuraEnabled public String selectedSem{get;set;}
        @AuraEnabled public hed__Term_Grade__c summaryRec{get;set;}
        @AuraEnabled public List<hed__Term_Grade__c> list_Results{get;set;}
    }
}