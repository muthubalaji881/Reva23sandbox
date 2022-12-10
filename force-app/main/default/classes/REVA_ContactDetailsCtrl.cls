public with Sharing class REVA_ContactDetailsCtrl 
{
    @AuraEnabled
    public static Contact fetchContact()
    {
        User u = [SELECT id,ContactId FROM User WHERE id=:userInfo.getUserId()];
        return [Select Name,Id,File_Passport_Size_Photo__c,MobilePhone,Application_Number__c,hed__WorkEmail__c,
                Student_Image__c,Primary_Academic_Program__r.name,Program_Batch__r.Name,Account.name,SRN_Number__c,
                School__r.Name
                from Contact where id=:u.ContactId];
    }
}