@isTest
public class FEE_StudentPayment_Ms2_Test {
  
    public static final String CONST_APPLICANT_RECTYPE = 'Applicant';
    //public static string mobileValue = '+91-9786010552';
    public static testmethod void displayApplicantFeeRecordsTest1(){
        
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        system.debug('conrecId--->'+conRecId);
        Account objAccount = new account();
        objAccount.Name = 'Stratos';
        objAccount.RecordTypeId = HouseholdRecId;
        insert objAccount;
        
        system.debug('objAccount.id--->'+objAccount);
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.Mobilephone='9876543210';
        //objCon.mobileValue='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objcon.RecordTypeId = conRecId;
        objCon.AccountId = objAccount.id;
        objCon.Applying_For_REVA_CET__c = 'Yes';
        objCon.LeadSource = 'Web';
        objCon.Admission_Mode__c = 'UQ';
        objCon.Country_Code__c = 'India (+91)';
        objCon.Select_Category__c = 'Karnataka';
        objCon.State__c = 'Karnataka';
        objCon.Exam_Type__c = 'Mobile Based';
        objCon.Country__c = 'India';
        insert objCon;
        //string mobileValue=objCon.MobilePhone.remove('+91-');
         //update objCon;
        system.debug('objCon-->'+objCon);  
        
                  
        FEE_StudentPayment_Ms2.StudentFeeWrapper stuWrap = new FEE_StudentPayment_Ms2.StudentFeeWrapper();
        stuWrap.objAppNumber = '7860879';
        stuWrap.objStuName = 'Karthi';
        stuWrap.objSrnNumber = '12345';
        
        
        Fee_Payment_Criteria__c  criteriaObj = new Fee_Payment_Criteria__c();
        criteriaObj.Payment_Type__c='Full Payment';
        criteriaObj.Fee_Type__c='Application Fee';
       /* criteriaObj.Merchant_ID_Billdesk__c ='MIDB232323';
        criteriaObj.Merchant_ID_Eazypay__c ='MIDE121212';
        criteriaObj.Merchant_ID_Paytm__c ='MIDP343434'; */
        criteriaObj.Merchant_ID_Razorpay__c='MIDR4454545'; 
        criteriaObj.Fee_Type__c = 'Application Fee';
        criteriaObj.Name = 'Application Fee - Full Payment';
        criteriaObj.Maximum_Number_of_Installments__c = 1;
        
        Insert criteriaObj;
        
        system.debug('Fee_Payment_Criteria__c--->'+criteriaObj);
             
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=50000;
        objStudentFee.Amount_Paid__c=0;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'karthi';
        objStudentFee.Due_Date__c = system.today() + 1;
        objStudentFee.Fee_Type__c = 'Application Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for Your Interest';
        objStudentFee.Due_Date__c=system.today();  
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=1;
        objStudentFee.Paid_Installments__c=0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        
        Insert objStudentFee;
        
        system.debug('objStudentFee--->'+objStudentFee);
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
         insert objStuPayment;

       
        FEE_StudentPayment_Ms2.StudentFeeRecWrapper stufeerecwrapper = new FEE_StudentPayment_Ms2.StudentFeeRecWrapper();
        stufeerecwrapper.NoOfInstallments = 10.0;
        stufeerecwrapper.PendingAmount = 10.0;
        stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
      
        test.startTest();
        FEE_StudentPayment_Ms2.displayApplicantFeeRecords((string)objcon.id);
        test.stopTest();
    }
    public static testmethod void fetchApplicantFeeRecords1(){
         
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        system.debug('conrecId--->'+conRecId);
        Account objAccount = new account();
        objAccount.Name = 'Stratos';
        objAccount.RecordTypeId = HouseholdRecId;
        insert objAccount;
        
        system.debug('objAccount.id--->'+objAccount);
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.Mobilephone='9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objcon.RecordTypeId = conrecId;
        objCon.AccountId = objAccount.id;
        insert objCon;
       // string mobileValue=objCon.MobilePhone.remove('objCon.MobilePhone');
        // update objCon;
        
        system.debug('objCon-->'+objCon);            
        FEE_StudentPayment_Ms2.StudentFeeWrapper stuWrap = new FEE_StudentPayment_Ms2.StudentFeeWrapper();
        stuWrap.objAppNumber = '7860879';
        stuWrap.objStuName = 'Karthi';
        stuWrap.objSrnNumber = '12345';
        
        
        Fee_Payment_Criteria__c  criteriaObj = new Fee_Payment_Criteria__c();
        criteriaObj.Payment_Type__c='Full Payment';
        criteriaObj.Fee_Type__c='Application Fee';
        criteriaObj.Merchant_ID_Billdesk__c ='MIDB232323';
        /*criteriaObj.Merchant_ID_Eazypay__c ='MIDE121212';
        criteriaObj.Merchant_ID_Paytm__c ='MIDP343434'; */
        criteriaObj.Merchant_ID_Razorpay__c='MIDR4454545'; 
        criteriaObj.Fee_Type__c = 'Application Fee';
        criteriaObj.Name = 'Application Fee - Full Payment';
        criteriaObj.Maximum_Number_of_Installments__c = 1;
        
        Insert criteriaObj;
        
        system.debug('Fee_Payment_Criteria__c--->'+criteriaObj);
        
        hed__Program_Enrollment__c objProgramEn = new hed__Program_Enrollment__c();
        objProgramEn.hed__Contact__c = objcon.id;
        objProgramEn.hed__Account__c = objaccount.id;
        
        insert objProgramEn;
        
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'karthi';
        objStudentFee.Due_Date__c = system.today() + 1;
        objStudentFee.Fee_Type__c = 'Application Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Program_Enrollment__c= objProgramEn.id;
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;
        
        system.debug('objStudentFee--->'+objStudentFee);
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
         insert objStuPayment;

       
        FEE_StudentPayment_Ms2.StudentFeeRecWrapper stufeerecwrapper = new FEE_StudentPayment_Ms2.StudentFeeRecWrapper();
        stufeerecwrapper.NoOfInstallments = 10.0;
        stufeerecwrapper.PendingAmount = 10.0;
        stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
        
      
        
        test.startTest();
        FEE_StudentPayment_Ms2.fetchApplicantFeeRecords(objStudentFee.id,(string)objcon.id);
        system.test.stopTest();
            
        
    }
    public static testmethod void razorPayGenratePaymentLink1(){
       
       
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
      
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.Mobilephone='9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objcon.RecordTypeId = conRecId;
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'karthi';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Application Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        
        Insert objStudentFee;
        
        system.debug('objStudentFee--->'+objStudentFee);
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        
        insert objStuPayment;
        FEE_StudentPayment_Ms2.StudentFeeRecWrapper stufeerecwrapper = new FEE_StudentPayment_Ms2.StudentFeeRecWrapper();
        stufeerecwrapper.NoOfInstallments = 10.0;
        stufeerecwrapper.PendingAmount = 10.0;
        stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
        
        FEE_StudentPayment_Ms2.customerWrp customerObj = new FEE_StudentPayment_Ms2.customerWrp();
        customerObj.Name = 'karthi';
        customerObj.Contact = '9786010552';
        customerObj.Email = 'karthik@gmail.com';
        
        Razorpay_Details__c setting = new Razorpay_Details__c();
        setting.Name = 'Applicant_CallbackUrl';
        setting.Value__c = 'https://revadev-chatbot.cs75.force.com/RazorPayPGResponse';
        insert setting;
        
        list<Razorpay_Details__c> listSetting = new   list<Razorpay_Details__c>();//bulk List of custom setting object for bulk insert
        
        Razorpay_Details__c csRpCallbackUrl=new Razorpay_Details__c(); //Custom Setting for Contact Fields
        csRpCallbackUrl.Name='CallbackUrl';//Static record 1 of custom setting
        csRpCallbackUrl.Value__c='https://revauniversity9--devbackup.sandbox.my.site.com/ApplicantPortalAccelerator/s/';
        listSetting.add(csRpCallbackUrl);
        
        Razorpay_Details__c csRpUserName=new Razorpay_Details__c(); //Custom Setting for Contact Fields
        csRpUserName.Name='UserName';//Static record 1 of custom setting
        csRpUserName.Value__c='rzp_test_JA1KlDGzmvG6Hh';
        listSetting.add(csRpUserName);
        
        Razorpay_Details__c csRpPassword=new Razorpay_Details__c(); //Custom Setting for Contact Fields
        csRpPassword.Name='Password';//Static record 1 of custom setting
        csRpPassword.Value__c='vdcSuL82zafd9GnXnfyzUIuK';
        listSetting.add(csRpPassword);
        
        
        Razorpay_Details__c csRpEndpoinUrl=new Razorpay_Details__c(); //Custom Setting for Con
        csRpEndpoinUrl.Name='Razorpay Endpoint';
        csRpEndpoinUrl.Value__c='https://api.razorpay.com/v1/payment_links';
        listSetting.add(csRpEndpoinUrl);
        
        insert listSetting;
        
        
        FEE_StudentPayment_Ms2.notifyWrp notifyObj = new FEE_StudentPayment_Ms2.notifyWrp();
        notifyObj.SMS = True;
        notifyObj.Email = True;
        
        FEE_StudentPayment_Ms2.notesWrp notesObj = new FEE_StudentPayment_Ms2.notesWrp();
        notesObj.paymentType = 'FeePayment';
        
        FEE_StudentPayment_Ms2.razorPayRequestCall razorpayobj= new FEE_StudentPayment_Ms2.razorPayRequestCall();
        razorpayobj.ramount =10000;
        razorpayobj.callback_method = 'get';
        razorpayobj.callback_url ='https://revadev-chatbot.cs75.force.com/RazorPayPGResponse';
        razorpayobj.reminder_enable =true;
        razorpayobj.customer = customerObj;
        razorpayobj.notify = notifyObj;
        razorpayobj.notes = notesObj;
        
        
        FEE_StudentPayment_Ms2.rezorpayResponseCall razorPayResponseObj = new FEE_StudentPayment_Ms2.rezorpayResponseCall();
        razorPayResponseObj.id = '123456';
        razorPayResponseObj.reference_id = Utility.generateRandomNumber();
        razorPayResponseObj.short_url = 'google.com';
        razorPayResponseObj.status = 'Success';
        razorPayResponseObj.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, new razorPayMock());
        String myJSON = JSON.serialize(razorpayobj); 
        list<Student_Fee__c> listStuFee = new list<Student_Fee__c>();
        listStuFee.add(objStudentFee);
       // stuWrap.lst_StuPaidDetails.add(objStudentFee);
        //stuWrap.lst_StuPaymentDetails.add(objStuPayment);
        
        test.startTest();
        FEE_StudentPayment_Ms2.razorPayGenratePaymentLink(listStuFee,10.0,'Application Fee',(string)objcon.id);
        test.stopTest();
    }
    @isTest
    public static void BillDeskPayGenratePaymentLink(){
        
        
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objcon.RecordTypeId = conRecId;
        insert objCon;
        
       //string mobileValue=objCon.MobilePhone.remove('+91-');
        // update objCon;
        
        
        

        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'karthi';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Application Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        
        Insert objStudentFee;
        
        system.debug('objStudentFee--->'+objStudentFee);
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        
        insert objStuPayment;
        FEE_StudentPayment_Ms2.StudentFeeRecWrapper stufeerecwrapper = new FEE_StudentPayment_Ms2.StudentFeeRecWrapper();
        stufeerecwrapper.NoOfInstallments = 10.0;
        stufeerecwrapper.PendingAmount = 10.0;
        stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
        
        FEE_StudentPayment_Ms2.customerWrp customerObj = new FEE_StudentPayment_Ms2.customerWrp();
        customerObj.Name = 'karthi';
        customerObj.Contact ='9786010552';
        customerObj.Email = 'karthik@gmail.com';
        
       Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.Name = 'Applicant_BillDesk_CallbackUrl';
        paydetails.MerchantId__c = 'https://strtsdev23-billdeskresponse.cs31.force.com/BillDeskResponse';
        insert paydetails;
        
        list<Billdesk_Merchant_Details__c> listSetting = new   list<Billdesk_Merchant_Details__c>();
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        paydetails1.MerchantId__c='uatY7vF4Cx3L';
        paydetails1.Name='Checksum';
        listSetting.add(payDetails1);
        
        
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='BD9CHILD2';
        payDetails2.Name='Hostel Fee';
        listSetting.add(payDetails2);
        
        Billdesk_Merchant_Details__c payDetails3 = new Billdesk_Merchant_Details__c();
        payDetails3.MerchantId__c='BD9MAIN';
        payDetails3.Name='MainMerchant';
        listSetting.add(payDetails3);
        
        Billdesk_Merchant_Details__c payDetails4 = new Billdesk_Merchant_Details__c();
        payDetails4.MerchantId__c='BD9CHILD3';
        payDetails4.Name='Miscellaneous Fee';
        listSetting.add(payDetails4);
        
        Billdesk_Merchant_Details__c payDetails5 = new Billdesk_Merchant_Details__c();
        payDetails5.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIMerchantPayment?msg=';
        payDetails5.Name='PaymentEndPoint';
        listSetting.add(payDetails5);
        
        Billdesk_Merchant_Details__c payDetails6 = new Billdesk_Merchant_Details__c();
        payDetails6.MerchantId__c='https://uat.billdesk.com/ecom/ECOM2ReqHandler';
        payDetails6.Name='PaymentLink';
        listSetting.add(payDetails6);
        
        Billdesk_Merchant_Details__c payDetails7 = new Billdesk_Merchant_Details__c();
        payDetails7.MerchantId__c='BD9CHILD4';
        payDetails7.Name='Transportation Fee';
        listSetting.add(payDetails7);
        
        Billdesk_Merchant_Details__c payDetails8 = new Billdesk_Merchant_Details__c();
        payDetails8.MerchantId__c='BD9CHILD4';
        payDetails8.Name='SecurityId';
        listSetting.add(payDetails8);
        
        Billdesk_Merchant_Details__c payDetails9 = new Billdesk_Merchant_Details__c();
        payDetails9.MerchantId__c='REVACOMSF';
        payDetails9.Name=objStudentFee.Fee_Type__c;
        listSetting.add(payDetails9);
        
        
        insert listSetting;
        
                
        
        FEE_StudentPayment_Ms2.notifyWrp notifyObj = new FEE_StudentPayment_Ms2.notifyWrp();
        notifyObj.SMS = True;
        notifyObj.Email = True;
        
        FEE_StudentPayment_Ms2.notesWrp notesObj = new FEE_StudentPayment_Ms2.notesWrp();
        notesObj.paymentType = 'FeePayment';
        
        FEE_StudentPayment_Ms2.razorPayRequestCall razorpayobj= new FEE_StudentPayment_Ms2.razorPayRequestCall();
        razorpayobj.ramount =10000;
        razorpayobj.callback_method = 'get';
        razorpayobj.callback_url ='https://strtsdev23-billdeskresponse.cs31.force.com/BillDeskResponse';
        razorpayobj.reminder_enable =true;
        razorpayobj.customer = customerObj;
        razorpayobj.notify = notifyObj;
        razorpayobj.notes = notesObj;
        
        
        FEE_StudentPayment_Ms2.rezorpayResponseCall razorPayResponseObj = new FEE_StudentPayment_Ms2.rezorpayResponseCall();
        razorPayResponseObj.id = '123456';
        razorPayResponseObj.reference_id = Utility.generateRandomNumber();
        razorPayResponseObj.short_url = 'google.com';
        razorPayResponseObj.status = 'Success';
        razorPayResponseObj.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, new razorPayMock());
        String myJSON = JSON.serialize(razorpayobj); 
        list<Student_Fee__c> listStuFee = new list<Student_Fee__c>();
        listStuFee.add(objStudentFee);
       // Dom.Document doc = new Dom.Document(); 
       
       // stuWrap.lst_StuPaidDetails.add(objStudentFee);
        //stuWrap.lst_StuPaymentDetails.add(objStuPayment);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new billdeskMock());
        FEE_StudentPayment_Ms2.BillDeskPayGenratePaymentLink(listStuFee,10.0,'Single',(string)objcon.id);
        test.stopTest();
    }




}