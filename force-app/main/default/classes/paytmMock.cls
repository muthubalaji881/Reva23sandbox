@isTest 
global class paytmMock implements HttpCalloutMock {
    global Integer rspCode;
    global String rspBody;
    global String rspHeaderkey;
    global String rspHeaderValue;
    global paytmMock(Integer rspCode1, String rspBody1,String rspHeaderValue1, String rspHeaderkey1){
        rspCode = rspCode1;
        rspBody = rspBody1;
        rspHeaderkey = rspHeaderkey1;
        rspHeaderValue = rspHeaderValue1;
    }
    
    global HttpResponse respond(HttpRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(rspCode);
        resp.setHeader(rspHeaderkey,rspHeaderValue);
        resp.setBody(rspBody);
        return resp;
    } 
}