public without sharing class FEE_EazyPAY_POC {
    public static final String CONST_APPLICATION_FEE = 'Application Fee';
    public static final String CONST_APPLICANTPORTAL_NAME = 'Application_Portal_Name';
    public static final String CONST_ADMIN_PROFILE = 'System Administrator';
    
    public static String getPortalName() {
        return [select Text_Value__c from General_Setting__mdt where DeveloperName =:CONST_APPLICANTPORTAL_NAME limit 1].Text_Value__c;
   }
    //This method displays only the 'Application Fee' for the Contact
    @AuraEnabled
    public static StudentFeeWrapper displayApplicantFeeRecords(string flowConId)
    {
        String profileId = userInfo.getProfileId();
		profile guestName = [Select Name from profile where id=: profileId];
		string guestUserProfileName=(guestName.Name);
        StudentFeeWrapper stuWrap = new StudentFeeWrapper();
        List<Profile> idGuestProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = idGuestProfile[0].Name;
        System.debug('profileName-->' + profileName);
      //  String varApplicationFee = 'Application Fee';
        System.debug('PName-->' + profileName);
        System.debug('flowConId-->' + flowConId);
        System.debug('guestUserProfileName-->' + guestUserProfileName);
        if(profileName == guestUserProfileName || profileName == CONST_ADMIN_PROFILE )
        {   
            System.debug('InsideIf-->');  
            //Query Fee record of the contact where Fee Type is 'Application fee'                          
            for(Student_Fee__c objStuFee : [select id,Name,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Application_Number__c,
                                            Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                            Course_Name_Course_Code__c,Program_Enrollment__c,Description__c,Due_Date__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,
                                            Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,
                                            Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c
                                            from Student_Fee__c where Contact__c =:flowConId AND Fee_Type__c =:CONST_APPLICATION_FEE order by Due_Date__c asc]) 
            {
                System.debug('InsideFor-->');
                system.debug('student fee---'+objStuFee);
                CheckboxWrapper checkWrap = new CheckboxWrapper();
                if(objStuFee.Name != null)
                    stuWrap.objStuname =objStuFee.Name;
                if(objStuFee.Contact__r.Application_Number__c != null)
                    stuWrap.objAppNumber=objStuFee.Contact__r.Application_Number__c;
                if(objStuFee.Contact__r.SRN_Number__c != null)
                    stuWrap.objSrnNumber=objStuFee.Contact__r.SRN_Number__c;                 
                if(objStuFee.Amount_Pending__c != null && objStuFee.Amount_Pending__c > 0)
                {
                    checkWrap.ObjStuFeeDeatils = objStuFee;                    
                    stuWrap.lst_CheckboxWrap.add(checkWrap);
                }
                if(objStuFee.Amount_Pending__c == 0)
                {
                    stuWrap.lst_StuPaidDetails.add(objStuFee);
                }
                system.debug('Student details----'+objStuFee);
            }
            
            for(Student_Payment__c objStuPay : [select Id,Name,Amount__c,Contact__c,Description__c,Fee_Type__c,Mode_of_Payment__c,Offline_Receipt_Number__c,Online_Receipt_Number1__c,
                                                Payment_Date_Time__c,Payment_Link_Id__c,Payment_Url__c,Payment_Gateway__c,Program_Enrollment__c,Razorpay_Signature__c,Payment_Status__c,
                                                Transaction_ID__c from Student_Payment__c where Payment_Status__c !=: 'Payment Link Created' AND Contact__c =: flowConId Order by Createddate DESC]) 
            {
                stuWrap.lst_StuPaymentDetails.add(objStuPay);
            }
        }
        
        return stuWrap;
    }
    //This method fetches the Application Fee record details on click of 'Make Payment' button
    @AuraEnabled
    public static StudentFeeRecWrapper fetchApplicantFeeRecords(Id strSelId, string flowConId)
    {
        system.debug('++++++++++'+strSelId);
        StudentFeeRecWrapper stuWrap = new StudentFeeRecWrapper();
        
       // String varApplicationFee = 'Application Fee';
        if(flowConId != null)
        {   
            for(Student_Fee__c objStuFee : [select id,Name,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Application_Number__c,
                                            Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                            Course_Name_Course_Code__c,Description__c,Due_Date__c,Program_Enrollment__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,
                                            Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,
                                            Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c
                                            from Student_Fee__c where id=:strSelId and Contact__c =: flowConId AND Fee_Type__c =: CONST_APPLICATION_FEE order by Due_Date__c asc])
            {
                 
                if(objStuFee.Fee_Type__c == objStuFee.Fee_Payment_Criteria__r.Fee_Type__c)
                {
                    stuWrap.StuFeeType = objStuFee.Fee_Type__c;
                    if(objStuFee.Number_of_Installments__c  != null && objStuFee.Paid_Installments__c != null)
                        stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c;
                    stuWrap.PendingAmount = objStuFee.Amount_Pending__c;
                    
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Full Payment')  stuWrap.lst_StuFeePayment.add(objStuFee);
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Partial Payment') stuWrap.lst_StuFeePayment.add(objStuFee);
                    
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('RazorPay','RazorPay');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Paytm__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('PayTM','PayTM');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('EazyPay','EazyPay');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('BillDesk','BillDesk');
                    }
                }            
            }
        }
        return stuWrap; 
    }   
    
     @Auraenabled
      public static rezorpayResponseCall easypayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType, string flowConId)
    {
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        string Name = '';
        decimal totAmt = PartialAmount;
        string email = '';
        string mobile = '';
        string contactId = '';
        string ProgEnrollId='';
        string discription = '';
        string RefId = Utility.generateRandomNumber();
        list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        string baseUrl = EasyPay_Details__c.getValues('EndPoint').Value__c+'merchantid='+EasyPay_Details__c.getValues('ICID').Value__c+'&mandatory fields=';
        
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            Name = fee.Contact__r.Name;
            email = fee.Contact__r.Email;
            mobile = fee.Contact__r.MobilePhone;
            contactId = fee.Contact__c;
            ProgEnrollId = fee.Program_Enrollment__c;  
            discription = discription + fee.Fee_Type__c+',';       
        }
        
        Student_Payment__c objStuFeePay = new Student_Payment__c();
        objStuFeePay.Amount__c = totAmt;
        objStuFeePay.Contact__c = contactId;
        objStuFeePay.Fee_Type__c = discription; 
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        lstStuPayment.add(objStuFeePay);
        
        if(lstStuPayment.size() > 0){
            
            string para1 = RefId+'|'+EasyPay_Details__c.getValues('Submerchantid').Value__c+'|'+PartialAmount;
            para1 += '|'+Name+'|'+email+'|'+mobile+'|'+RefId;  
            
            string plainUrl = baseUrl + para1 + '&optional fields=xyz|xyz&returnurl='+EasyPay_Details__c.getValues('CallbackUrl').Value__c;
            plainUrl += '&Reference No='+RefId+'&submerchantid='+EasyPay_Details__c.getValues('Submerchantid').Value__c;
            plainUrl += '&transaction amount='+string.valueof(PartialAmount)+'&paymode=9';
            system.debug('PlainUrl+++++++'+plainUrl); 
            string str;
            if(!test.isRunningTest()){
             str = calculateAes(para1);
            
            str += '&optional fields='+calculateAes('xyz|xyz');
            str += '&returnurl='+calculateAes(EasyPay_Details__c.getValues('CallbackUrl').Value__c)+'&Reference No='+calculateAes(RefId)+'&submerchantid=';
            str += calculateAes(EasyPay_Details__c.getValues('Submerchantid').Value__c)+'&transaction amount='+calculateAes(string.valueof(PartialAmount))+'&paymode='+calculateAes('9');
            }
            else{
                str = 'test';
            }
            system.debug('++++++++'+str);
            baseUrl = baseUrl + str;
            system.debug('++++++++'+baseUrl);
            
/*Debug_Log__c dblog = new Debug_Log__c();
dblog.Class_Name__c = 'FEE_EazyPAY_POC';
dblog.Method_Name__c = 'easypayGenratePaymentLink';
dblog.Processing_API_Name__c = 'EasyPay';
HttpRequest req = new HttpRequest(); 
HttpResponse res = new HttpResponse();
dblog.Request__c = req.getBody();
dblog.Response__c =res.getBody();
dblog.User_Id__c = UserInfo.getUserId(); */

            
            objStuFeePay.Reference_Id__c = RefId;
            objStuFeePay.Billdesk_Url__c = baseUrl;
            objStuFeePay.Payment_Status__c = 'Payment Link Created';
            objStuFeePay.Payment_Gateway__c = 'Eazypay';
            objStuFeePay.Mode_of_Payment__c = 'Online';
            insert objStuFeePay;
            
            list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
            for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                if(feeType == 'single'){
                    sfp.Amount__c = totAmt;
                }
                else{
                    sfp.Amount__c = objstuFee.Amount_Pending__c;
                }
                sfp.Mode_of_Payment__c = 'Online';
                sfp.Reference_Id__c = RefId;
                sfp.Student_Fee__c =  objstuFee.id;                       
                sfp.Student_Payment__c = objStuFeePay.id;
                sfp.Line_Item_Payment_Gateway__c = 'Eazypay';                   
                lstSfp.add(sfp);
            }           
            if(lstSfp.size() > 0){
                insert lstSfp;
            }
            reswrap.short_url = baseUrl;
            reswrap.statusCode = 200;
            
        }
        else{
            reswrap.statusCode = 101;
            // dblog.Status__c = 'Failure';
        }
        system.debug('+++++++++++'+reswrap);
        return reswrap;
    }
    @Auraenabled
     public static rezorpayResponseCall PaytmGeneratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType, string flowConId)
    {
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        decimal totAmt = PartialAmount;
        string applicationNo = '';
        string contactId = flowConId;
        string ProgEnrollId='';
        string discription = '';
        string RefId = Utility.generateRandomNumber();  
        
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            applicationNo = fee.Contact__r.Application_Number__c;
           // contactId = fee.Contact__c;
            ProgEnrollId = fee.Program_Enrollment__c;  
            discription = discription + fee.Fee_Type__c;
        }
        
        Student_Payment__c objStuFeePay = new Student_Payment__c();
        objStuFeePay.Amount__c = totAmt;
        objStuFeePay.Contact__c = contactId;
        objStuFeePay.Fee_Type__c = discription; 
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
          
        Map<string, string> parammap = new Map<string,string>();
        parammap.put('MID',Paytm_Details__c.getValues('MID').Value__c);
        //parammap.put('MID',Paytm_Details__c.getValues('TestMID').Value__c);
        
        parammap.put('ORDER_ID',RefId);
        
        paytmMain ptm = new paytmMain();
        ptm.body = new PaytmParamClass();
        ptm.body.requestType = 'Payment';
        ptm.body.mid = Paytm_Details__c.getValues('MID').Value__c;
         //ptm.body.mid = Paytm_Details__c.getValues('TestMID').Value__c;
        
        ptm.body.orderId = RefId;
        ptm.body.websiteName = 'WEBSTAGING';
        ptm.body.callbackUrl = Paytm_Details__c.getValues('Applicant_Paytm_CallbackUrl').Value__c;
        system.debug('callbackUrl'+ptm.body.callbackUrl);
      //  ptm.body.callbackUrl = Paytm_Details__c.getValues('CallbackUrl').Value__c;
        ptm.body.txnAmount = new paymentDetails();
        ptm.body.txnAmount.value = string.valueof(PartialAmount);
        ptm.body.txnAmount.ccurrency = 'INR';
        ptm.body.userInfo = new UserDetails();
        ptm.body.userInfo.custId = applicationNo;
                 
        string jsonStr = JSON.serialize(ptm.body);
       // jsonStr = jsonStr.replaceAll('"ccurrency":', '"currency":');
        system.debug('jsonStr+++++++++'+jsonStr);
        //system.debug('Key+++++++++'+Paytm_Details__c.getValues('TestMerchantKey').Value__c);
        string checksumstring = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Details__c.getValues('Merchant Key').Value__c, jsonStr);
        //string checksumstring = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Details__c.getValues('TestMerchantKey').Value__c, jsonStr);
        system.debug('checksumstring+++++++++'+checksumstring);
        ptm.head = new headDetails();
        ptm.head.signature = checksumstring;
         
        system.debug('Ptm++++++++'+ptm);
       string baseUrl = Paytm_Details__c.getValues('Endpoint').Value__c + 'mid=' +Paytm_Details__c.getValues('MID').Value__c+'&' ;
       //string baseUrl = Paytm_Details__c.getValues('TestEndpointURL').Value__c + 'mid=' +Paytm_Details__c.getValues('TestMID').Value__c+'&' ;
       baseUrl += 'orderId='+RefId;
        System.debug('+++ '+baseUrl);
        
        string str = JSON.serialize(ptm);
         system.debug('HttpBody++++++++'+str); 
         Http h = new Http();
         HttpRequest req = new HttpRequest();
        req.setEndpoint(baseUrl);
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        req.setBody(str);
        req.setTimeout(120000);
        HttpResponse res = h.send(req);
        
        system.debug('++++++++'+res); 
        System.debug('++++resBody++++++++'+res.getBody());
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_StudentPayment_Ctrl';
        dblog.Method_Name__c = 'paytmGenratePaymentLink';
        dblog.Processing_API_Name__c = 'Paytm';            
        dblog.Request__c = req.getBody();
        dblog.Response__c = res.getBody();
        dblog.User_Id__c = UserInfo.getUserId();
        
        
        objStuFeePay.Reference_Id__c = RefId;
       objStuFeePay.Payment_Url__c = baseUrl;
        objStuFeePay.Payment_Status__c = 'Payment Link Created';
        objStuFeePay.Payment_Gateway__c = 'Paytm';
        objStuFeePay.Mode_of_Payment__c = 'Online';
        insert objStuFeePay;
        
        list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
            for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                if(feeType == 'single'){
                    sfp.Amount__c = totAmt;
                }
                else{
                    sfp.Amount__c = objstuFee.Amount_Pending__c;
                }
                sfp.Mode_of_Payment__c = 'Online';
                sfp.Reference_Id__c = RefId;
                sfp.Student_Fee__c =  objstuFee.id;                       
                sfp.Student_Payment__c = objStuFeePay.id;
                sfp.Line_Item_Payment_Gateway__c = 'Paytm';                   
                lstSfp.add(sfp);
            }           
            if(lstSfp.size() > 0){
                insert lstSfp;
            }
        
        inisaliseResponse response1 = new inisaliseResponse();
        
        if(res.getStatusCode() == 200){
            response1 = (inisaliseResponse)System.JSON.deserialize(res.getBody(), inisaliseResponse.class);
            
            if(response1.body.resultInfo.resultCode == '0000' || response1.body.resultInfo.resultCode == '0002'){
                reswrap.reference_id = response1.body.txnToken;
                system.debug(reswrap.reference_id);
                reswrap.statusCode = 200;
                reswrap.id = Paytm_Details__c.getValues('MID').Value__c;
                 //reswrap.id = Paytm_Details__c.getValues('TestMID').Value__c;
                reswrap.status = RefId;
                reswrap.short_url = Paytm_Details__c.getValues('PaymentEndPoint').Value__c +'mid='+Paytm_Details__c.getValues('MID').Value__c+'&orderId='+RefId;
                 //reswrap.short_url = Paytm_Details__c.getValues('TestPaymentPage').Value__c +'mid='+Paytm_Details__c.getValues('TestMID').Value__c+'&orderId='+RefId;
                system.debug(reswrap.short_url);
                dblog.Status__c = 'Success';
                
            }
            else{
                reswrap.statusCode = 101;
                dblog.Status__c = 'Failure';
            }
        }
        
        insert dblog;
        return reswrap;
    }
    
    public static string calculateAes(string mainStr){
        String Key = EasyPay_Details__c.getValues('AES key').Value__c;
        system.debug(mainStr);
        functions.Function accountFunction = functions.Function.get(label.FEE_Easypay_Function_Name);
        functions.FunctionInvocation invocation = accountFunction.invoke('{ "input" : "' +mainStr +'", "key" : "'+ key + '"}');
        Map<String, Object> mp_out = (Map<String, Object>) JSON.deserializeUntyped(invocation.getResponse()) ;
        System.debug('Got response ' + mp_out);
        string decode  = String.valueof(mp_out.get('encodedStr')).unescapeHtml4();
        system.debug('Decoded+'+decode);
        return decode;     
    }
      public class StudentFeeWrapper
    {
        @AuraEnabled public list<CheckboxWrapper> lst_CheckboxWrap {get;set;}
        @AuraEnabled public list<Student_Fee__c> lst_StuPaidDetails {get;set;}
        @AuraEnabled public list<Student_Payment__c> lst_StuPaymentDetails {get;set;}
        @AuraEnabled public string objStuname {get;set;}
        @AuraEnabled public string objAppNumber {get;set;}
        @AuraEnabled public string objSrnNumber {get;set;}
    //    @AuraEnabled public decimal TotalAmount {get;set;}
    //    @AuraEnabled public decimal TotalPendingAmount {get;set;}
    //    @AuraEnabled public decimal TotalPaidAmount {get;set;}
        
        public StudentFeeWrapper()
        {
            lst_StuPaidDetails = new list<Student_Fee__c>();
            lst_StuPaymentDetails = new list<Student_Payment__c>();
            lst_CheckboxWrap = new list<CheckboxWrapper>();
        //    TotalAmount = 0;
        //    TotalPendingAmount = 0;
        //    TotalPaidAmount = 0;
        }
    } 
    public class StudentFeeRecWrapper
    {
        @AuraEnabled public list<Student_Fee__c> lst_StuFeePayment {get;set;}
        @AuraEnabled public string StuFeeType {get;set;}
        @AuraEnabled public Decimal NoOfInstallments {get;set;}
        @AuraEnabled public Decimal PendingAmount {get;set;}
        @AuraEnabled public Map<string,string> map_PaymentGateway {get;set;}
        @AuraEnabled public string Errmsg {get;set;}
        public StudentFeeRecWrapper()
        {
            lst_StuFeePayment = new list<Student_Fee__c>();
            map_PaymentGateway = new map<string,string>();
        }
    }
    public class CheckboxWrapper
    {
        @AuraEnabled public Student_Fee__c ObjStuFeeDeatils {get;set;}
        @AuraEnabled public boolean isChecked {get;set;}
        public CheckboxWrapper()
        {
            ObjStuFeeDeatils = new Student_Fee__c();
            isChecked = false;
        }    
    }
    // public class ErrorWrapper
    // {
    //     @AuraEnabled public string DateError {get;set;}
    // }  
    public class razorPayRequestCall{
        @AuraEnabled public decimal ramount {get;set;}
        @AuraEnabled public string rcurrency {get;set;}
        @AuraEnabled public boolean accept_partial {get;set;}
        //@AuraEnabled public decimal first_min_partial_amount {get;set;}
        @AuraEnabled public decimal expire_by {get;set;}
        @AuraEnabled public string reference_id {get;set;}
        @AuraEnabled public string description {get;set;}
        @AuraEnabled public boolean reminder_enable {get;set;}
        @AuraEnabled public string callback_url {get;set;}
        @AuraEnabled public string callback_method {get;set;}
        @AuraEnabled public customerWrp customer {get;set;}
        @AuraEnabled public notifyWrp notify {get;set;}
        @AuraEnabled public notesWrp notes {get;set;}
    }
    public class customerWrp{
        @AuraEnabled public string name {get;set;}
        @AuraEnabled public string contact {get;set;}
        @AuraEnabled public string email {get;set;}
    }
    public class notifyWrp{
        @AuraEnabled public boolean sms {get;set;}
        @AuraEnabled public boolean email {get;set;}
    }
    public class notesWrp{
        @AuraEnabled public string paymentType {get;set;}
    }
    
    public class rezorpayResponseCall{
        @AuraEnabled public string id {get;set;}
        @AuraEnabled public string reference_id {get;set;}
        @AuraEnabled public string short_url {get;set;}
        @AuraEnabled public string status  {get;set;}
        @AuraEnabled public integer statusCode  {get;set;}
    }
     public class paytmMain{
        @AuraEnabled public PaytmParamClass body {get;set;}
        @AuraEnabled public headDetails head {get;set;}
    }
    public class PaytmParamClass{
        @AuraEnabled public string requestType {get;set;}
        @AuraEnabled public string mid {get;set;}
        @AuraEnabled public string orderId {get;set;}
        @AuraEnabled public string websiteName {get;set;}
        @AuraEnabled public string callbackUrl {get;set;}  
        @AuraEnabled public paymentDetails txnAmount {get;set;}  
        @AuraEnabled public UserDetails userInfo {get;set;}    
            
    }
    
    public class paymentDetails{
        @AuraEnabled public string value {get;set;}
        @AuraEnabled public string ccurrency {get;set;}
    }
    
    public class UserDetails{
        @AuraEnabled public string custId {get;set;}
    }
    
    public class headDetails{
        @AuraEnabled public string signature {get;set;}
    }
    
    
    public class inisaliseResponse{
        @AuraEnabled public resBodyDetails body {get;set;}
        @AuraEnabled public resHeadDetails head {get;set;}
    }
    public class resHeadDetails{
        @AuraEnabled public string responseTimestamp {get;set;}
        @AuraEnabled public string version {get;set;}
        @AuraEnabled public string signature {get;set;}
    }
    public class resResultInfoDetails{
        @AuraEnabled public string resultStatus {get;set;}
        @AuraEnabled public string resultCode {get;set;}
        @AuraEnabled public string resultMsg {get;set;}
    }
    public class resBodyDetails{
        @AuraEnabled public resResultInfoDetails resultInfo {get;set;}
        @AuraEnabled public string txnToken {get;set;}
        @AuraEnabled public boolean isPromoCodeValid {get;set;}
        @AuraEnabled public boolean authenticated {get;set;}
    }


}