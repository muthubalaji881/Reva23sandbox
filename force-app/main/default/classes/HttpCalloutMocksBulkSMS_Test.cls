@isTest
public with sharing class HttpCalloutMocksBulkSMS_Test implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://api.oot.bz/api/v1/one2One', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{"unicode":false,"shortMessages":[{"recipient":"+918341619029","message":"Dear Shiva \\nI am your dedicated senior counselor, Parthiban, to help you take admissions at REVA University.\\nLet'+'s talk on Admission about ONLINE admissions process.\\nRegards\\nCounsellor Team\\nREVA University","dltContentId":"1007005251825380828"}],"from":"REVAUN","credentials":{"user":"revaerp.trans","password":"s1Sz2"}}');
        //('{"unicode":false,"shortMessages":[{"recipient":"+918341619029","message":"Dear Shiva \\nI am your dedicated senior counselor, Parthiban, to help you take admissions at REVA University.\\nLet's talk on Admission about ONLINE admissions process.\\nRegards\\nCounsellor Team\\nREVA University","dltContentId":"1007005251825380828"}],"from":"REVAUN","credentials":{"user":"revaerp.trans","password":"s1Sz2"}}')';
       //('{"unicode":false,"shortMessages":[{"recipient":"+918341619029","message":"Shiva, Thanks for showing interest. Click REVA University to access your profile & to fill the Application form - REVA University","dltContentId":"1007541446229897491"}],"from":"REVAUN","credentials":{"user":"revaerp.trans","password":"s1Sz2"}}');
        resp.setStatusCode(200);
        return resp;
    }
    
}