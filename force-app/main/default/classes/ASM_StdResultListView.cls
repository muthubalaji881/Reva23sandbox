public class ASM_StdResultListView {
	@AuraEnabled
    public static List<hed__Term_Grade__c> fetchData(){
        User cUser = [SELECT Id,ContactId,Contact.Active_Semester__c,Contact.Active_Semester__r.Name FROM User WHERE Id =: UserInfo.getUserId()];       
        return [SELECT Id,Recent_Result_Updated_Date__c,hed__Term__c,hed__Term__r.Name,Total_Maximum_Marks_Semester__c,
                Total_Secured_Marks_Semester__c,Examination_Month_Year__c FROM hed__Term_Grade__c 
                WHERE hed__Contact__c =: cUser.ContactId AND Result_Summary__c = null ORDER BY hed__Term__r.Term_Number__c ASC];
    }
}