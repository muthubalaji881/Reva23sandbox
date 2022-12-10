@RestResource(UrlMapping='/BillDeskServerResponse/*')
global without sharing class FEE_BilldeskServerResponseAPI 
{    
    @HttpPost
    global static string ReceivedData()
    {
        Debug_Log__c dblog = new Debug_Log__c();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            dblog.Class_Name__c = 'FEE_BilldeskServerResponseAPI';
            dblog.Method_Name__c = 'ReceivedData';
            dblog.Processing_API_Name__c = 'BillDesk';            
            dblog.Data_Received__c = req.requestBody.toString();
            
            String newStrReq = req.requestBody.toString();
            Integer reqLen = newStrReq.split('\\|').size();
            string referenceId = newStrReq.split('\\|')[reqLen-25];
            dblog.Payment_Reference_Id__c = referenceId;
            dblog.Status__c = 'Success'; 
            insert dblog;
        }
        catch(Exception Ex){
            dblog.Status__c = 'Failure';
            dblog.Error_Message__c = string.valueof(Ex);
            upsert dblog;
        }
         return dblog.Status__c;
    }
}