@isTest
public class FEE_EazyPAY_POC_test {
    
    public class HttpPaytmCalloutMocks_Test implements HttpCalloutMock {
        
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"head":{"responseTimestamp":"1669175092307","version":"v1","signature":"xFrUbEkMOp7YetP40DVK1wy3jqI1ISNSqElLCgFBKZ9hlU9exOsSRnn+j4x/bodIRlU3kETKB5xFW4/6uC9wS/OSTcSNGaA2WNRZQDAFfag="},"body":{"resultInfo":{"resultStatus":"S","resultCode":"0000","resultMsg":"Success"},"txnToken":"1b4ed5536f024edb9a4a63b6a627c5fc1669175091738","isPromoCodeValid":false,"authenticated":false}}');
            res.setStatusCode(200);
            return res;
        }
            
     
            
    }
    public class HttpPaytmFailureCalloutMocks_Test implements HttpCalloutMock {
        
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('Failure');
            res.setStatusCode(101);
            return res;
        }
            
     
            
    }
        
        
        @isTest
        public static void paytmPaymentLinkGenerationTest(){
            
            //Inserting Household Account
            
            string HouseholdRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
            Account testAccount = new Account();
            testAccount.Name = 'paytmTestAccount';
            testAccount.RecordTypeId = HouseholdRecordId;
            insert testAccount; 
            
            // Inserting Applicant Contact Record
            
            string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Contact testContact = new Contact();
            testContact.LastName ='paytmTestContact';
            testContact.RecordTypeId = ApplicantRecordId;
            testContact.AccountId = testAccount.Id;
            testContact.MobilePhone ='9866964824';
            testContact.Aadhar_Card_Number__c ='111122223333';
            testContact.Application_Number__c = '23180100023';
            testContact.SRN_Number__c ='1234567891234567';
            testContact.hed__WorkEmail__c  = 'paytmTestContact@reva.edu.in';
            testContact.Nationality__c ='Indian';
            insert testContact;
            
            // Inserting Application-Fee Fee payment Criteria
            
            Fee_Payment_Criteria__c paytmFeeCriteria = new Fee_Payment_Criteria__c();
            paytmFeeCriteria.Name = 'Application Fee - Full Payment';
            paytmFeeCriteria.Merchant_ID_Paytm__c ='RevaUn85385305140219';
            Insert paytmFeeCriteria;
            
            
            hed__Program_Enrollment__c objProgenroll = 
FEE_TestDataFactory.createProgramEnrollment(testContact.Id,null);
            Insert objProgenroll;
            // Inserting Student Fees
            
            
            Student_Fee__c paytmStudentFee = new Student_Fee__c();
            paytmStudentFee.Name = 'Application Fee - 231801 - paytmTestContact';
            paytmStudentFee.Contact__c = testContact.Id;
            paytmStudentFee.Fee_Type__c ='Application Fee';
            paytmStudentFee.Amount__c = 1500;
            paytmStudentFee.Amount_Pending__c = 1500;
            paytmStudentFee.Amount_Paid__c = 0;
            insert paytmStudentFee;
            // Inserting new StudentFees
            Student_Fee__c paytmStudentFee1 = new Student_Fee__c();
            paytmStudentFee1.Name = 'Application Fee - 231801 - paytmTestContact';
            paytmStudentFee1.Contact__c = testContact.Id;
            paytmStudentFee1.Fee_Type__c ='Application Fee';
            paytmStudentFee1.Amount__c = 1500;
            paytmStudentFee1.Amount_Pending__c = 1500;
            paytmStudentFee1.Amount_Paid__c = 0;
            insert paytmStudentFee1;
            //Adding the Student Fee to a Student Fee list
            list<Student_Fee__c> paytmStudentFeeList = new list<Student_Fee__c>();
            paytmStudentFeeList.add(paytmStudentFee1);
            
            // Inserting Student Payment
            
            Student_Payment__c paytmStudentPayment = new Student_Payment__c();
            paytmStudentPayment.Contact__c = testContact.Id;
            paytmStudentPayment.Payment_Status__c = 'Success';
            paytmStudentPayment.Transaction_ID__c = '123442123432';
            paytmStudentPayment.Payment_Mode_Type__c = 'Online';
            paytmStudentPayment.Payment_Gateway__c = 'Paytm';
            paytmStudentPayment.Amount__c =1500;
            paytmStudentPayment.Reference_Id__c = '1231234';
            insert paytmStudentPayment;
            
            //Inserting Student Fee Payment
            
       
            
            
            FEE_EazyPAY_POC.CheckboxWrapper checkWrap = new FEE_EazyPAY_POC.CheckboxWrapper();
            checkWrap.ObjStuFeeDeatils = paytmStudentFee;
            list<FEE_EazyPAY_POC.CheckboxWrapper> lst_Checkwrap = new list<FEE_EazyPAY_POC.CheckboxWrapper>();
            lst_Checkwrap.add(checkWrap); 
            
            FEE_EazyPAY_POC.StudentFeeWrapper  stuwrap = new FEE_EazyPAY_POC.StudentFeeWrapper(); 
            stuwrap.lst_StuPaidDetails.add(paytmStudentFee1);
            stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
            decimal Amount =1500;
            
            FEE_EazyPAY_POC.razorPayRequestCall reswrap = new FEE_EazyPAY_POC.razorPayRequestCall();
            reswrap.ramount =1500;
            reswrap.callback_method ='get';
            reswrap.callback_url ='https://reva.edu.in';
            //reswrap.short_url ='google.com';
            reswrap.reminder_enable =true;
            //reswrap.statusCode = 200;
            
            String myJSON = JSON.serialize(reswrap); 
           
            
            Paytm_Details__c PayDet = new Paytm_Details__c();
            PayDet.Value__c ='https://reva-university--revadevfx.sandbox.my.salesforce-sites.com/PaytmResponse';
            PayDet.Name ='Applicant_Paytm_CallbackUrl';
            insert PayDet;
            
            Paytm_Details__c PayDet1 = new Paytm_Details__c();
            PayDet1.Value__c ='RevaUn85385305140219';
            PayDet1.Name ='MID';
            insert PayDet1;
            
            Paytm_Details__c PayDet2 = new Paytm_Details__c();
            PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
            PayDet2.Name ='Merchant Key';
            insert PayDet2;
            
            Paytm_Details__c PayDet3 = new Paytm_Details__c();
            PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
            PayDet3.Name ='Endpoint';
            insert PayDet3;
            
            Paytm_Details__c PayDet4 = new Paytm_Details__c();
            PayDet4.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?';
            PayDet4.Name ='PaymentEndPoint';
            insert PayDet4;
            
            FEE_EazyPAY_POC.rezorpayResponseCall rescall = new FEE_EazyPAY_POC.rezorpayResponseCall();
            rescall.reference_id = Utility.generateRandomNumber();
            rescall.short_url = Paytm_Details__c.getValues('PaymentEndPoint').Value__c +'mid='+Paytm_Details__c.getValues('MID').Value__c+'&orderId='+rescall.reference_id;
            //rescall.short_url = 'google.com';
            rescall.status = 'Success'; 
            rescall.statusCode =200;
            
            FEE_EazyPAY_POC.resResultInfoDetails responseInfo = new FEE_EazyPAY_POC.resResultInfoDetails();
            responseInfo.resultCode='0000';
            responseInfo.resultMsg='';
            responseInfo.resultStatus='';
            
            FEE_EazyPAY_POC.resBodyDetails responseDetails = new FEE_EazyPAY_POC.resBodyDetails();
            responseDetails.resultInfo = responseInfo;
            responseDetails.txnToken ='123';
            responseDetails.isPromoCodeValid =false;
            responseDetails.authenticated=false; 
            
            FEE_EazyPAY_POC.resHeadDetails responseHeaderDetails = new FEE_EazyPAY_POC.resHeadDetails();
            responseHeaderDetails.responseTimestamp ='test';
            responseHeaderDetails.version='1.0';
            responseHeaderDetails.signature='test';
            
            FEE_EazyPAY_POC.inisaliseResponse reponseInitialize = new FEE_EazyPAY_POC.inisaliseResponse();
            reponseInitialize.body= responseDetails;
            reponseInitialize.head = responseHeaderDetails;
            
            Test.Starttest();
            Test.setMock(HttpCalloutMock.class, new HttpPaytmCalloutMocks_Test());
            
            date schDate = system.today(); 
            
            Fee_EazyPAY_POC.rezorpayResponseCall reswrap1 = new Fee_EazyPAY_POC.rezorpayResponseCall();
            
            reswrap1 = FEE_EazyPay_POC.PaytmGeneratePaymentLink(paytmStudentFeeList,Amount,'Single',String.ValueOf(testContact.Id));
            
            
            test.stoptest();
            
            // system.assertEquals(200, reswrap.statusCode());
            
        } 
    
    @isTest
    public static void paytmPaymentLinkGenerationTest1(){
            
            //Inserting Household Account
            
            string HouseholdRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
            Account testAccount = new Account();
            testAccount.Name = 'paytmTestAccount';
            testAccount.RecordTypeId = HouseholdRecordId;
            insert testAccount; 
            
            // Inserting Applicant Contact Record
            
            string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Contact testContact = new Contact();
            testContact.LastName ='paytmTestContact';
            testContact.RecordTypeId = ApplicantRecordId;
            testContact.AccountId = testAccount.Id;
            testContact.MobilePhone ='9866964824';
            testContact.Aadhar_Card_Number__c ='111122223333';
            testContact.Application_Number__c = '23180100023';
            testContact.SRN_Number__c ='1234567891234567';
            testContact.hed__WorkEmail__c  = 'paytmTestContact@reva.edu.in';
            testContact.Nationality__c ='Indian';
            insert testContact;
            
            // Inserting Application-Fee Fee payment Criteria
            
            Fee_Payment_Criteria__c paytmFeeCriteria = new Fee_Payment_Criteria__c();
            paytmFeeCriteria.Name = 'Application Fee - Full Payment';
            paytmFeeCriteria.Merchant_ID_Paytm__c ='RevaUn85385305140219';
            Insert paytmFeeCriteria;
            
            
            hed__Program_Enrollment__c objProgenroll = new hed__Program_Enrollment__c();
        	objProgenroll.hed__Contact__c= testContact.Id;
               // FEE_TestDataFactory.createProgramEnrollment(testContact.Id,null);
            Insert objProgenroll;
            // Inserting Student Fees
            
            
            Student_Fee__c paytmStudentFee = new Student_Fee__c();
            paytmStudentFee.Name = 'Application Fee - 231801 - paytmTestContact';
            paytmStudentFee.Contact__c = testContact.Id;
            paytmStudentFee.Fee_Type__c ='Application Fee';
            paytmStudentFee.Amount__c = 1500;
            paytmStudentFee.Amount_Pending__c = 1500;
            paytmStudentFee.Amount_Paid__c = 0;
            insert paytmStudentFee;
            // Inserting new StudentFees
            Student_Fee__c paytmStudentFee1 = new Student_Fee__c();
            paytmStudentFee1.Name = 'Application Fee - 231801 - paytmTestContact';
            paytmStudentFee1.Contact__c = testContact.Id;
            paytmStudentFee1.Fee_Type__c ='Application Fee';
            paytmStudentFee1.Amount__c = 1500;
            paytmStudentFee1.Amount_Pending__c = 1500;
            paytmStudentFee1.Amount_Paid__c = 0;
            insert paytmStudentFee1;
            //Adding the Student Fee to a Student Fee list
            list<Student_Fee__c> paytmStudentFeeList = new list<Student_Fee__c>();
            paytmStudentFeeList.add(paytmStudentFee1);
            
            // Inserting Student Payment
            
            Student_Payment__c paytmStudentPayment = new Student_Payment__c();
            paytmStudentPayment.Contact__c = testContact.Id;
            paytmStudentPayment.Payment_Status__c = 'Success';
            paytmStudentPayment.Transaction_ID__c = '123442123432';
            paytmStudentPayment.Payment_Mode_Type__c = 'Online';
            paytmStudentPayment.Payment_Gateway__c = 'Paytm';
            paytmStudentPayment.Amount__c =1500;
            paytmStudentPayment.Reference_Id__c = '1231234';
            insert paytmStudentPayment;
            
            //Inserting Student Fee Payment
            
            /*   Student_Fee_Payment__c paytmStudentFeePayment = new Student_Fee_Payment__c();
paytmStudentFeePayment.Student_Fee__c = paytmStudentFee.Id;
paytmStudentFeePayment.Student_Payment__c = paytmStudentPayment.Id;
paytmStudentFeePayment.Line_Item_Payment_Gateway__c = 'Paytm';
paytmStudentFeePayment.Line_Item_Payment_Status__c = 'Success';
paytmStudentFeePayment.Amount__c = 1500;
paytmStudentFeePayment.Mode_of_Payment__c='Online';
paytmStudentFeePayment.SF_Transaction_ID__c= '123442123432';
paytmStudentFeePayment.Transaction_Date_Time__c  = system.now();
paytmStudentFeePayment.Reference_Id__c = '1231234';
insert paytmStudentFeePayment; */
            
            
            FEE_EazyPAY_POC.CheckboxWrapper checkWrap = new FEE_EazyPAY_POC.CheckboxWrapper();
            checkWrap.ObjStuFeeDeatils = paytmStudentFee;
            list<FEE_EazyPAY_POC.CheckboxWrapper> lst_Checkwrap = new list<FEE_EazyPAY_POC.CheckboxWrapper>();
            lst_Checkwrap.add(checkWrap); 
            
            FEE_EazyPAY_POC.StudentFeeWrapper  stuwrap = new FEE_EazyPAY_POC.StudentFeeWrapper(); 
            stuwrap.lst_StuPaidDetails.add(paytmStudentFee1);
            stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
            decimal Amount =1500;
            
            FEE_EazyPAY_POC.razorPayRequestCall reswrap = new FEE_EazyPAY_POC.razorPayRequestCall();
            reswrap.ramount =1500;
            reswrap.callback_method ='get';
            reswrap.callback_url ='https://reva.edu.in';
            //reswrap.short_url ='google.com';
            reswrap.reminder_enable =true;
            //reswrap.statusCode = 200;
            
            String myJSON = JSON.serialize(reswrap); 
           
            
            Paytm_Details__c PayDet = new Paytm_Details__c();
            PayDet.Value__c ='https://reva-university--revadevfx.sandbox.my.salesforce-sites.com/PaytmResponse';
            PayDet.Name ='Applicant_Paytm_CallbackUrl';
            insert PayDet;
            
            Paytm_Details__c PayDet1 = new Paytm_Details__c();
            PayDet1.Value__c ='RevaUn85385305140219';
            PayDet1.Name ='MID';
            insert PayDet1;
            
            Paytm_Details__c PayDet2 = new Paytm_Details__c();
            PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
            PayDet2.Name ='Merchant Key';
            insert PayDet2;
            
            Paytm_Details__c PayDet3 = new Paytm_Details__c();
            PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
            PayDet3.Name ='Endpoint';
            insert PayDet3;
            
            Paytm_Details__c PayDet4 = new Paytm_Details__c();
            PayDet4.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?';
            PayDet4.Name ='PaymentEndPoint';
            insert PayDet4;
            
            FEE_EazyPAY_POC.rezorpayResponseCall rescall = new FEE_EazyPAY_POC.rezorpayResponseCall();
           // rescall.reference_id = Utility.generateRandomNumber();
            //rescall.short_url = Paytm_Details__c.getValues('TestPaymentPage').Value__c +'mid='+Paytm_Details__c.getValues('TestMID').Value__c+'&orderId='+rescall.reference_id;
            //rescall.short_url = 'google.com';
            rescall.status = 'Failure'; 
            rescall.statusCode =101;
            
            FEE_EazyPAY_POC.resResultInfoDetails responseInfo = new FEE_EazyPAY_POC.resResultInfoDetails();
            responseInfo.resultCode='0003';
            responseInfo.resultMsg='';
            responseInfo.resultStatus='101';
            
            FEE_EazyPAY_POC.resBodyDetails responseDetails = new FEE_EazyPAY_POC.resBodyDetails();
            responseDetails.resultInfo = responseInfo;
            responseDetails.txnToken ='123';
            responseDetails.isPromoCodeValid =false;
            responseDetails.authenticated=false; 
            
            FEE_EazyPAY_POC.resHeadDetails responseHeaderDetails = new FEE_EazyPAY_POC.resHeadDetails();
            responseHeaderDetails.responseTimestamp ='test';
            responseHeaderDetails.version='1.0';
            responseHeaderDetails.signature='test';
            
            FEE_EazyPAY_POC.inisaliseResponse reponseInitialize = new FEE_EazyPAY_POC.inisaliseResponse();
            reponseInitialize.body= responseDetails;
            reponseInitialize.head = responseHeaderDetails;
            
            Test.Starttest();
            Test.setMock(HttpCalloutMock.Class, new HttpPaytmFailureCalloutMocks_Test());
           // HttpResponse res = FEE_EazyPAY_POC_test.HttpPaytmFailureCalloutMocks_Test();
            date schDate = system.today(); 
            
            Fee_EazyPAY_POC.rezorpayResponseCall reswrap1 = new Fee_EazyPAY_POC.rezorpayResponseCall();
            
            reswrap1 = FEE_EazyPay_POC.PaytmGeneratePaymentLink(paytmStudentFeeList,Amount,'Multiple',String.ValueOf(testContact.Id));
            
             
            test.stoptest();
            
            // system.assertEquals(200, reswrap.statusCode());
            
    }
}