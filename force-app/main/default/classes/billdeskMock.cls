@isTest
global class billdeskMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('<?xml version="1.0" encoding="UTF-8"?><RESPONSE><TXNDATA><TXNSUMMARY><PGMERCID>BD9MAIN</PGMERCID><PGCUSTOMERID>1858861564</PGCUSTOMERID><RECORDS>1</RECORDS><AMOUNT>65000.00</AMOUNT><STATUSCODE>0</STATUSCODE><STATUSDESC>SUCCESS</STATUSDESC><FILLER1>NA</FILLER1><FILLER2>NA</FILLER2><FILLER3>NA</FILLER3></TXNSUMMARY><RECORD ID="1"><CUSTOMERID>18588615641</CUSTOMERID><ECOMTXNID>EC01135067</ECOMTXNID></RECORD></TXNDATA><CHECKSUM>B3857D00FE8E4BC5A971F7C2EF9F7FEF23D25923EB600DB53B580264937F472C</CHECKSUM></RESPONSE>');
        response.setStatusCode(200);
        return response; 
    }
}