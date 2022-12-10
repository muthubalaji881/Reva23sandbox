@isTest
public class FEE_StudentPayment_Ctrl_Test 
{
    public class HttpPaytmCalloutMocks_Test implements HttpCalloutMock {
    
    
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('"head":{"responseTimestamp":"1669094438714","version":"v1","signature":"h5ttgCcmgOrXZiFHhMhEeO0CHsyq6Z4K/AugGnTTn/HyAd+bisGt8Cs4mOJbjo1JB06DlruDW2U06g2yzdMgPzKeobjLHFLonSPyDSdQI7Y="},"body":{"resultInfo":{"resultStatus":"S","resultCode":"0000","resultMsg":"Success"},"txnToken":"b6f462a6d33a45c4be4c4843beea6e111669094438553","isPromoCodeValid":false,"authenticated":false}');
            res.setStatusCode(200);
            return res;
        
    }

}
    public static  testmethod void StudentFeeMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User newUser1 = new user();
        contact objCon = new contact();
        
        system.runAs(adminUser){    
            Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
            objAcc.Recordtypeid = HouseholdRecId;
            Insert objAcc;
            
            string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
            objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = StudentRecId;
            objCon.AccountId = objAcc.Id;
            objcon.Application_Number__c = 'test123';
            objcon.SRN_Number__c ='123';
            objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objcon.Nationality__c ='Indian';
            Insert objCon; 
            
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = objcon.id
                //   UserRoleId = userrole.Id
            );
            insert newUser1;
        }
        system.runAs(newUser1){        
            Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
            Insert objProgenroll;
            
            Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee.Amount__c = 50000;
            objStudentFee.Amount_Pending__c=40000;
            objStudentFee.Amount_Paid__c=10000;
            objStudentFee.Contact__c = objCon.id;
            objStudentFee.Due_Date__c = system.today() - 1;
            Insert objStudentFee;
            
            Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee1.Amount__c = 50000;
            objStudentFee1.Amount_Pending__c=0;
            objStudentFee1.Amount_Paid__c=50000;
            objStudentFee1.Contact__c = objCon.id;
            objStudentFee1.Due_Date__c = system.today() - 1;
            Insert objStudentFee1;
            
            list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
            lst_stufee.add(objStudentFee1);
            
            Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
            objStuPayment.Payment_Status__c ='Success';
            insert objStuPayment;
            
            FEE_StudentPayment_Ctrl.CheckboxWrapper checkWrap = new FEE_StudentPayment_Ctrl.CheckboxWrapper();
            checkWrap.ObjStuFeeDeatils = objStudentFee;
            list<FEE_StudentPayment_Ctrl.CheckboxWrapper> lst_Checkwrap = new list<FEE_StudentPayment_Ctrl.CheckboxWrapper>();
            lst_Checkwrap.add(checkWrap); 
            
            FEE_StudentPayment_Ctrl.StudentFeeWrapper  stuwrap = new FEE_StudentPayment_Ctrl.StudentFeeWrapper(); 
            stuwrap.lst_StuPaidDetails.add(objStudentFee1);
            stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
            decimal Amount =10000;
            
            FEE_StudentPayment_Ctrl.razorPayRequestCall reswrap = new FEE_StudentPayment_Ctrl.razorPayRequestCall();
            reswrap.ramount =10000;
            reswrap.callback_method ='get';
            reswrap.callback_url ='https://revadev-chatbot.cs75.force.com/RazorPayPGResponse';
            reswrap.reminder_enable =true;
            
            String myJSON = JSON.serialize(reswrap); 
            
            Razorpay_Details__c paydetails = new Razorpay_Details__c();
            paydetails.Value__c='https://revadev-chatbot.cs75.force.com/RazorPayPGResponse';
            paydetails.Name='CallbackUrl';
            insert paydetails;
            
            Razorpay_Details__c paydetails1 = new Razorpay_Details__c();
            paydetails1.Value__c='vdcSuL82zafd9GnXnfyzUIuK';
            paydetails1.Name='Password';
            insert paydetails1;
            
            Razorpay_Details__c paydetails2 = new Razorpay_Details__c();
            paydetails2.Value__c='https://api.razorpay.com/v1/payment_links';
            paydetails2.Name='Razorpay Endpoint';
            insert paydetails2;
            
            Razorpay_Details__c paydetails3 = new Razorpay_Details__c();
            paydetails3.Value__c='rzp_test_JA1KlDGzmvG6Hh';
            paydetails3.Name='UserName';
            insert paydetails3;
            
            FEE_StudentPayment_Ctrl.rezorpayResponseCall rescall = new FEE_StudentPayment_Ctrl.rezorpayResponseCall();
            rescall.reference_id = Utility.generateRandomNumber();
            rescall.short_url ='ep';
            rescall.status = 'Success'; 
            rescall.statusCode =200;
            
            Paytm_Details__c PayDet = new Paytm_Details__c();
            PayDet.Value__c ='https://reva-university--revadevfx.sandbox.my.salesforce-sites.com/PaytmResponse';
            PayDet.Name ='CallbackUrl';
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
            
            Test.Starttest();
            Test.setMock(HttpCalloutMock.class, new razorPayMock());
            date schDate = system.today();        
            FEE_StudentPayment_Ctrl.DisplayStudentFeeRecords();
            FEE_StudentPayment_Ctrl.ValidationDate(objStudentFee.id,schDate,objCon.id);
            FEE_StudentPayment_Ctrl.FetchFeeRecords(objStudentFee.id);
            FEE_StudentPayment_Ctrl.MultiStduentFeeRecords(lst_stufee);
            FEE_StudentPayment_Ctrl.razorPayGenratePaymentLink(lst_stufee,Amount,'single');
            FEE_StudentPayment_Ctrl.ValidateMultiPayments(lst_stufee);
            test.stoptest();
        }
    }
    public static  testmethod void StudentFeeMethod1()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Email ='test@gmail.com';
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=0;
        objStudentFee1.Amount_Paid__c=50000;
        Insert objStudentFee1;
        
        list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
        lst_stufee.add(objStudentFee1);
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        insert objStuPayment;
        
        FEE_StudentPayment_Ctrl.CheckboxWrapper checkWrap = new FEE_StudentPayment_Ctrl.CheckboxWrapper();
        checkWrap.ObjStuFeeDeatils = objStudentFee;
        list<FEE_StudentPayment_Ctrl.CheckboxWrapper> lst_Checkwrap = new list<FEE_StudentPayment_Ctrl.CheckboxWrapper>();
        lst_Checkwrap.add(checkWrap); 
        
        FEE_StudentPayment_Ctrl.StudentFeeWrapper  stuwrap = new FEE_StudentPayment_Ctrl.StudentFeeWrapper(); 
        stuwrap.lst_StuPaidDetails.add(objStudentFee1);
        stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
        decimal Amount =10000;
        
        FEE_StudentPayment_Ctrl.razorPayRequestCall reswrap = new FEE_StudentPayment_Ctrl.razorPayRequestCall();
        reswrap.ramount =10000;
        reswrap.callback_method ='get';
        reswrap.callback_url ='https://revadev-chatbot.cs75.force.com/RazorPayPGResponse';
        reswrap.reminder_enable =true;
        
        String myJSON = JSON.serialize(reswrap); 
        
        Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='BD9CHILD1';
        paydetails.Name='Academic Fee';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetails1 = new Billdesk_Merchant_Details__c();
        paydetails1.MerchantId__c='https://revadev-chatbot.cs75.force.com/BillDeskResponse';
        paydetails1.Name='CallbackUrl';
        insert paydetails1;
        
        Billdesk_Merchant_Details__c paydetails2 = new Billdesk_Merchant_Details__c();
        paydetails2.MerchantId__c='uatY7vF4Cx3L';
        paydetails2.Name='Checksum';
        insert paydetails2;
        
        Billdesk_Merchant_Details__c paydetails3 = new Billdesk_Merchant_Details__c();
        paydetails3.MerchantId__c='BD9CHILD2';
        paydetails3.Name='Hostel Fee';
        insert paydetails3;
        
        Billdesk_Merchant_Details__c paydetails4 = new Billdesk_Merchant_Details__c();
        paydetails4.MerchantId__c='BD9MAIN';
        paydetails4.Name='MainMerchant';
        insert paydetails4;
        
        Billdesk_Merchant_Details__c paydetails5 = new Billdesk_Merchant_Details__c();
        paydetails5.MerchantId__c='BD9CHILD3';
        paydetails5.Name='Miscellaneous Fee';
        insert paydetails5;
        
        Billdesk_Merchant_Details__c paydetails6 = new Billdesk_Merchant_Details__c();
        paydetails6.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIMerchantPayment?msg=';
        paydetails6.Name='PaymentEndPoint';
        insert paydetails6;
        
        Billdesk_Merchant_Details__c paydetails7 = new Billdesk_Merchant_Details__c();
        paydetails7.MerchantId__c='https://uat.billdesk.com/ecom/ECOM2ReqHandler';
        paydetails7.Name='PaymentLink';
        insert paydetails7;
        
        Billdesk_Merchant_Details__c paydetails8 = new Billdesk_Merchant_Details__c();
        paydetails8.MerchantId__c='BD9CHILD4';
        paydetails8.Name='Transportation Fee';
        insert paydetails8;
        
        Billdesk_Merchant_Details__c paydetails9 = new Billdesk_Merchant_Details__c();
        paydetails9.MerchantId__c='BD9CHILD4';
        paydetails9.Name='SecurityId';
        insert paydetails9;
                
        EasyPay_Details__c easypaydetails = new EasyPay_Details__c();
        easypaydetails.Value__c ='https://eazypayuat.icicibank.com/EazyPG?';
        easypaydetails.name ='EndPoint';
        insert easypaydetails;
        
        EasyPay_Details__c EDetails = new EasyPay_Details__c();
        EDetails.Value__c ='45?';
        EDetails.name ='Submerchantid';
        insert EDetails;
        
        EasyPay_Details__c EpDetails = new EasyPay_Details__c();
        EpDetails.Value__c ='131966';
        EpDetails.name ='ICID';
        insert EpDetails;
        
        EasyPay_Details__c EAeDetails = new EasyPay_Details__c();
        EAeDetails.Value__c ='1311140119601518';
        EAeDetails.name ='AES key';
        insert EAeDetails;
        
        EasyPay_Details__c EDetailsUrl = new EasyPay_Details__c();
        EDetailsUrl.Value__c ='https://reva-university--revadevfx.sandbox.my.salesforce-sites.com/EasyPayResponse';
        EDetailsUrl.name ='CallbackUrl';
        insert EDetailsUrl;
        
        Paytm_Details__c PayDet = new Paytm_Details__c();
        PayDet.Value__c ='https://reva-university--revadevfx.sandbox.my.salesforce-sites.com/PaytmResponse';
        PayDet.Name ='CallbackUrl';
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
              
        FEE_StudentPayment_Ctrl.paymentDetails wrapdetail = new FEE_StudentPayment_Ctrl.paymentDetails();
        wrapdetail.value =string.valueof(Amount);
        wrapdetail.ccurrency ='INR';
        
        FEE_StudentPayment_Ctrl.UserDetails usrWrap = new FEE_StudentPayment_Ctrl.UserDetails();
        usrWrap.custId = objcon.Application_Number__c; 
        
        FEE_StudentPayment_Ctrl.PaytmParamClass wrappay = new FEE_StudentPayment_Ctrl.PaytmParamClass();
        wrappay.requestType ='Payment';
        wrappay.mid =PayDet1.Value__c;
        wrappay.websiteName ='WEBSTAGING';
        wrappay.callbackUrl =PayDet.Value__c;
        wrappay.txnAmount =wrapdetail;
        wrappay.userInfo =usrWrap;
        
        FEE_StudentPayment_Ctrl.paytmMain payWrap = new FEE_StudentPayment_Ctrl.paytmMain(); 
        payWrap.body =wrappay;
        
        String myJSON1 = JSON.serialize(reswrap); 
        
         Test.Starttest();
        Test.setMock(HttpCalloutMock.class, new billdeskMock()); 
        FEE_StudentPayment_Ctrl.BillDeskPayGenratePaymentLink(lst_stufee,Amount,'single');
        FEE_StudentPayment_Ctrl.easypayGenratePaymentLink(lst_stufee,Amount,'single');
        test.stoptest();
    }  
    public static  testmethod void PaytmMethod()
    {
        try{
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User newUser1 = new user();
        contact objCon = new contact();
        
        system.runAs(adminUser){    
            Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
            objAcc.Recordtypeid = HouseholdRecId;
            Insert objAcc;
            
            string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
            objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = StudentRecId;
            objCon.AccountId = objAcc.Id;
            objcon.Application_Number__c = 'test123';
            objcon.SRN_Number__c ='123';
            objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objcon.Nationality__c ='Indian';
            Insert objCon; 
            
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = objcon.id
                //   UserRoleId = userrole.Id
            );
            insert newUser1;
        }
        system.runAs(newUser1){        
            Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
            Insert objProgenroll;
            
            Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee.Amount__c = 50000;
            objStudentFee.Amount_Pending__c=40000;
            objStudentFee.Amount_Paid__c=10000;
            objStudentFee.Contact__c = objCon.id;
            objStudentFee.Due_Date__c = system.today() - 1;
            Insert objStudentFee;
            
            Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee1.Amount__c = 50000;
            objStudentFee1.Amount_Pending__c=0;
            objStudentFee1.Amount_Paid__c=50000;
            objStudentFee1.Contact__c = objCon.id;
            objStudentFee1.Due_Date__c = system.today() - 1;
            Insert objStudentFee1;
            
            list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
            lst_stufee.add(objStudentFee1);
            
            Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
            objStuPayment.Payment_Status__c ='Success';
            objStuPayment.Reference_Id__c='123';
            insert objStuPayment;
            
            FEE_StudentPayment_Ctrl.CheckboxWrapper checkWrap = new FEE_StudentPayment_Ctrl.CheckboxWrapper();
            checkWrap.ObjStuFeeDeatils = objStudentFee;
            list<FEE_StudentPayment_Ctrl.CheckboxWrapper> lst_Checkwrap = new list<FEE_StudentPayment_Ctrl.CheckboxWrapper>();
            lst_Checkwrap.add(checkWrap); 
            
            FEE_StudentPayment_Ctrl.StudentFeeWrapper  stuwrap = new FEE_StudentPayment_Ctrl.StudentFeeWrapper(); 
            stuwrap.lst_StuPaidDetails.add(objStudentFee1);
            stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
            decimal Amount =10000;
            
            FEE_StudentPayment_Ctrl.razorPayRequestCall reswrap = new FEE_StudentPayment_Ctrl.razorPayRequestCall();
            reswrap.ramount =10000;
            reswrap.callback_method ='get';
            reswrap.callback_url ='https://revadev-chatbot.cs75.force.com/RazorPayPGResponse';
            reswrap.reminder_enable =true;
            
            String myJSON = JSON.serialize(reswrap); 
            
            Paytm_Details__c PayDet = new Paytm_Details__c();
            PayDet.Value__c ='https://reva-university--revadevfx.sandbox.my.salesforce-sites.com/PaytmResponse';
            PayDet.Name ='CallbackUrl';
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
            
            FEE_StudentPayment_Ctrl.resResultInfoDetails rsInfo = new FEE_StudentPayment_Ctrl.resResultInfoDetails();
            rsInfo.resultCode='0002';
            rsInfo.resultMsg='';
            rsInfo.resultStatus='';
            
            FEE_StudentPayment_Ctrl.resBodyDetails resDet = new FEE_StudentPayment_Ctrl.resBodyDetails();
            resDet.resultInfo = rsInfo;
            resDet.txnToken ='123';
            resDet.isPromoCodeValid =false;
            resDet.authenticated=false; 
            
            FEE_StudentPayment_Ctrl.resHeadDetails headres = new FEE_StudentPayment_Ctrl.resHeadDetails();
            headres.responseTimestamp ='test';
            headres.version='1.0';
            headres.signature='test';
            
            FEE_StudentPayment_Ctrl.inisaliseResponse resin = new FEE_StudentPayment_Ctrl.inisaliseResponse();
            resin.body= resDet;
            resin.head = headres;
            
            Test.Starttest();
            Test.setMock(HttpCalloutMock.class, new razorPayMock());
            date schDate = system.today(); 
            FEE_StudentPayment_Ctrl.PaytmGenratePaymentLink(lst_stufee,Amount,'single');
            test.stoptest();
        }
        }catch(exception ex)
        {
            
        }
    }
}