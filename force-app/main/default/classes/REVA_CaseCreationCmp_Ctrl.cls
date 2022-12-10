public with sharing class REVA_CaseCreationCmp_Ctrl 
{
    @AuraEnabled
    public static map<string,Case_Management__c> fetchSubCatDetails()
    {
        map<string,Case_Management__c> map_CaseManagement=new map<string,Case_Management__c>();
        for(Case_Management__c objCase:Case_Management__c.getAll().Values())
        {
            map_CaseManagement.put(objCase.Sub_Category__c,objCase);
        }
        return map_CaseManagement;
    }
    @AuraEnabled
    public static responeWrapper CreateCaseWithFile(string file, string fileName, case objCase)
    {
        responeWrapper objresp=new responeWrapper();
        try
        {
            Id CaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Utility.Case_SupportRequest_RecType).getRecordTypeId();          
            Case obCase=new Case();
            obCase.Category__c= objCase.Category__c;
            obCase.Sub_Category__c=objCase.Sub_Category__c;
            obCase.Subject=objCase.Subject;
            obCase.Description=objCase.Description;
            obCase.Case_Status__c=objCase.Case_Status__c;
            obCase.RecordTypeId=CaseRecTypeId;
            obCase.Old_Case_Number__c=(objCase.Old_Case_Number__c != null) ? objCase.Old_Case_Number__c : null;
            insert obCase;
            
            if(!String.isBlank(file))
            {
                ContentVersion contentVersionRec = new ContentVersion();
                contentVersionRec.Title = fileName;  
                contentVersionRec.PathOnClient = '/' + fileName;  
                contentVersionRec.FirstPublishLocationId = obCase.Id;  
                contentVersionRec.VersionData = EncodingUtil.base64Decode(file);  
                contentVersionRec.IsMajorVersion = true;  
                Insert contentVersionRec;
            }
            objresp.strMessage='Success';
            objresp.CaseId=obCase.id;
        }
        catch(Exception ex)
        {
            objresp.strMessage='Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
        }
        return objresp;
    }
    public class responeWrapper
    {
        @AuraEnabled public string strMessage{get;set;}
        @AuraEnabled public string CaseId{get;set;}
    }
}