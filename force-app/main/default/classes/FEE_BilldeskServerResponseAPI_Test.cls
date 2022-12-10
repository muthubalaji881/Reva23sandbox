@isTest
public class FEE_BilldeskServerResponseAPI_Test 
{
    public static testMethod Void BilldeskMethod()
    {
       String jsonBody = 'BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|01|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/BillDeskServerResponse/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        FEE_BilldeskServerResponseAPI.ReceivedData();
        Test.stopTest();        
     }
     public static testMethod Void BilldeskMethod1()
    {
       String jsonBody = '';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/BillDeskServerResponse/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        FEE_BilldeskServerResponseAPI.ReceivedData();
        Test.stopTest();        
     }
}