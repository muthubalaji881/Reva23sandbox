public class RazorpayResponseClass_POC {
    
    Public static razorpayResponses razorpayPaymentResponses(String Ids){
       	Student_Payment__C studentPayment = [Select Id,Payment_Link_Id__c,Payment_Status__c From Student_Payment__C Where Id=: Ids];
        Http http = new Http();
        HttpRequest httprequest = new HttpRequest();
        HttpResponse httpresponse = new HttpResponse();
        string endpoint1 = 'https://api.razorpay.com/v1/payment_links/'+studentPayment.Payment_Link_Id__c;
        system.debug(endpoint1);
        httprequest.setEndpoint(endpoint1);
        httprequest.setMethod('GET');
        string username = 'rzp_test_JA1KlDGzmvG6Hh';
        string password = 'vdcSuL82zafd9GnXnfyzUIuK';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        httprequest.setHeader('Authorization', authorizationHeader);
        RazorpayResponseClass_POC.razorpayResponses rrpay = new razorpayResponses();
        RazorpayResponseClass_POC.customerwrp rrcustomerwrp = new customerwrp();
        RazorpayResponseClass_POC.noteswrp rrnoteswrp = new noteswrp();
        RazorpayResponseClass_POC.notifywrp rrnotifywrp = new notifywrp();
        RazorpayResponseClass_POC.paymentswrp rrpaymentswrp = new paymentswrp();
        RazorpayResponseClass_POC.reminderswrp rrreminderswrp = new reminderswrp();
        rrpay.customer = rrcustomerwrp;
        rrpay.notes = rrnoteswrp;
        rrpay.notify = rrnotifywrp;
        rrpay.payments = rrpaymentswrp;
        rrpay.reminders = rrreminderswrp;
        httpresponse = http.send(httprequest);
        string responseBody = httpresponse.getBody();
        system.debug(responseBody);
        if(httpresponse.getStatusCode() == 200){
            //String responser = JSON.deserialize(httpresponse.getBody());
              //system.debug(responser);
            if(responseBody.contains('"status":"paid"')){
                studentPayment.Payment_Status__c = 'Success';
                update studentPayment;
                system.debug('accept');
                
            }else{
                system.debug('Not accepts');
            }
            
            try{
                
                rrpay =  (razorpayResponses)System.JSON.deserialize(responseBody, razorpayResponses.class);
            }
            catch (exception ex){
                system.debug(ex);
                system.debug(ex.getLineNumber());
            }
            
            if(rrpay.status == 'paid'){
                system.debug('paid');
            }
            else{
                system.debug('Fees Status'+rrpay.status);
            }
        }else{
            system.debug(httpresponse.getStatusCode());
            rrpay =  (razorpayResponses)System.JSON.deserialize(responseBody, razorpayResponses.class);
        }
        return rrpay;
    } 
    
    
    public class razorpayResponses{
        public boolean accept_partial;
        public Integer amount;
        public Integer amount_paid;
        public String callback_method;
        public string callback_url;
        public Integer cancelled_at;
        public Integer created_at;
        public String rcurrency;
        public customerwrp customer;
        public string description;
        public Integer expire_by;
        public Integer expired_at;
        public Integer first_min_partial_amount;
        public string id;
        public noteswrp notes;
        public notifywrp notify;
        public string order_id;
        public paymentswrp payments;
        public string reference_id;
        public boolean reminder_enable;
        public reminderswrp reminders;
        public string short_url;
        public string status;
        public Integer updated_at;
        public boolean upi_link;
        public string user_id;
    }
    public class customerwrp{
        public string contact;
        public string email;
        public string name;
    }
    public class noteswrp{
        public string paymentType;
    }
    public class notifywrp{
        public boolean email;
        public boolean sms;
        public boolean whatsapp;
    }
    public class paymentswrp{
        public integer amount;
        public integer created_at;
        public string method;
        public string payment_id;
        public string status;
    }
    public class reminderswrp{
        public string status;
    }
    
    
    
}