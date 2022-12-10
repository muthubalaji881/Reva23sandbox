global class FEE_BilldeskPendingPaymentUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return database.getQueryLocator([SELECT id,Transaction_ID__c,Reference_Id__c,Payment_Status__c,Payment_Date_Time__c,Payment_Mode_Type__c,
                                      Amount__c,BillDesk_Auth_Code__c,BillDesk_Refund_Code__c FROM Student_Payment__c WHERE Payment_Status__c = 'Pending' AND Payment_Gateway__c = 'Billdesk']); //  id = 'a1E0w000001c07f']); 
    }
    global void execute(Database.BatchableContext BC, List<Student_Payment__c> scope){
    
        list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
        dateTime dt = system.now();
        string strDt =string.valueof(dt);
        String newStrDt = strDt.replaceAll('[^0-9]', '');
        for(Student_Payment__c sp : scope){
            string baseReq = '0122|'+Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'|'+sp.Reference_Id__c;
            baseReq += '|'+ newStrDt;
            String genertedcheckSum = FEE_StudentPayment_Ctrl.calculateCheckSum(baseReq);
            genertedcheckSum = genertedcheckSum.toUppercase();
            baseReq = baseReq+'|'+genertedcheckSum;
            system.debug('+++++++++'+baseReq);
            
            string endPoint = Billdesk_Merchant_Details__c.getValues('QueryApiEndpoint').MerchantId__c;
            system.debug('====>>>'+endPoint);
            Http http1 = new Http();
            HttpRequest httpReq1 = new HttpRequest();
            HttpResponse httpRes1 = new HttpResponse();
            httpReq1.setEndpoint(endPoint);
            httpReq1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            string payload = 'msg='+baseReq;
            httpReq1.setbody(payload);
            httpReq1.setMethod('POST');
            httpReq1.setTimeout(120000);
            httpRes1 = http1.send(httpReq1);
            
            System.debug('Request Body====>'+httpReq1.getBody());
            System.debug('response Body====>'+httpRes1.getBody());
            system.debug('====status code===='+httpRes1.getStatusCode());
            
            string response = httpRes1.getBody();  
            system.debug('response+++++++'+response);          
            Integer reqLen = response.split('\\|').size();
            system.debug('reqLen+++++++'+reqLen);
            String refundCode = response.split('\\|')[reqLen-6];
            String authCode = response.split('\\|')[reqLen-18];
            system.debug('+++++'+authCode);

            if(authCode == '0300'){
                sp.Payment_Status__c = 'Success';
            }
            else if(authCode == '0002'){
                sp.Payment_Status__c = 'Pending';
            }
            else{
                sp.Payment_Status__c = 'Failed';
            }
            sp.BillDesk_Refund_Code__c = refundCode;
            sp.BillDesk_Auth_Code__c = authCode;
            update sp;
            
           for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                                   Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                                   Reference_Id__c =: sp.Reference_Id__c]){
               objStuFeePayment.Line_Item_Payment_Status__c = sp.Payment_Status__c;                                                    
               lstSfp.add(objStuFeePayment);                                                        
           }
        }
        
        if(lstSfp.size() > 0){
            update lstSfp;
        }
    }
    global void finish(Database.BatchableContext BC){       
    }
}