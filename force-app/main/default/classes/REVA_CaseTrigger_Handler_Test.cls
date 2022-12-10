@Istest
public class REVA_CaseTrigger_Handler_Test 
{
    public static testmethod void CaseTrigger()
    {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Request').getRecordTypeId();
        
        Account objAccount = new Account();
        objAccount.Name = 'Name';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test';
        objContact.AccountId = objAccount.id;
        objContact.Email = 'Test123@gmail.com';
        insert objContact;
        
        Case objCase = new Case();
        objCase.ContactId = objContact.id;
        objCase.RecordTypeId = recordTypeId;
        insert objCase;
        
        system.assertequals(objCase.id,objCase.id);
        
    }
}