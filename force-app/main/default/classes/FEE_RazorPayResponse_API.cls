//@RestResource(urlMapping='/RazorPayResponse/*')
//https://revauniversity9--revadev.my.salesforce.com/services/apexrest/RazorPayResponse
global class FEE_RazorPayResponse_API {
    global string PaymentId {get;set;}
    global string PaymentLinkId {get;set;}
    global string Status {get;set;}
    global string StatusMsg {get;set;}
    global string razorPay_Sign {get;set;}
    global Decimal Amount {get;set;}
    global string homeUrl{get;set;}
    global string PaymentMode{get;set;}
    global String PurposeofPayment{get;set;}
    global DateTime TransactionDateTime{get;set;}
    global string Applicant_HomeUrl{get;set;}
    global string ISTTransactionDateTime{get;set;}
    global final String SMS_TYPE ='Application_Number';
   

    
     global void updateStudentFee(){
    
        homeUrl = Razorpay_Details__c.getValues('HomeUrl').Value__c;  
        PaymentId = apexpages.currentpage().getparameters().get('razorpay_payment_id');
        PaymentLinkId = apexpages.currentpage().getparameters().get('razorpay_payment_link_id');
        Status = apexpages.currentpage().getparameters().get('razorpay_payment_link_status');
        razorPay_Sign = apexpages.currentpage().getparameters().get('razorpay_signature');
       
        Student_Payment__c stu = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,
                                  Amount__c ,Razorpay_Signature__c FROM Student_Payment__c WHERE Payment_Link_Id__c =: PaymentLinkId];
        
        Amount = stu.Amount__c;
        if(Status =='paid')
        {
            stu.Payment_Status__c = 'Success';
            PaymentMode = 'Online';
            StatusMsg = 'Transaction Success..!!';
        }      
        else
        {
            stu.Payment_Status__c = 'Failed';  
            PaymentMode = 'Online';
            StatusMsg = 'Transaction Failed..!!';
        }    
        stu.Transaction_ID__c = PaymentId;
        stu.Mode_of_Payment__c = 'Online';
        stu.Payment_Date_Time__c = system.now();
        stu.Razorpay_Signature__c = razorPay_Sign;
        stu.Payment_Gateway__c = 'Razorpay';
         PurposeofPayment = stu.Fee_Type__c;
         TransactionDateTime = stu.Payment_Date_Time__c;
       // update stu;
        list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
        for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                       Student_Payment__c,Transaction_Date_Time__c from Student_Fee_Payment__c  where
                                                       Payment_Link_Id__c =: PaymentLinkId])
        {
            if(Status =='paid')
                objStuFeePayment.Line_Item_Payment_Status__c = 'Success';
            else 
                objStuFeePayment.Line_Item_Payment_Status__c = 'Failed';
            
            objStuFeePayment.SF_Transaction_ID__c = PaymentId;
            objStuFeePayment.Transaction_Date_Time__c = system.now();
            lst_Studentfee.add(objStuFeePayment);
        }
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_RazorPayResponse_API';
        dblog.Method_Name__c = 'updateStudentFee';
        dblog.Processing_API_Name__c = 'RazorPay';            
        dblog.Data_Received__c = 'PaymentId='+PaymentId+'&PaymentLinkId='+PaymentLinkId+'&Status='+Status+'&razorPay_Sign='+razorPay_Sign;
        if(Status =='paid'){
            dblog.Status__c = 'Success';
        }
        else{
            dblog.Status__c = 'Failure';
        }
        insert dblog;
       // dblog.Response__c = res.getBody();
       // dblog.User_Id__c = UserInfo.getUserId(); 
        if(lst_Studentfee.size()>0){
           // update lst_Studentfee; 
        }
        if(string.isNotBlank(PaymentId) && string.isNotBlank(PaymentLinkId)){
            FEE_RazorpayGetPaymentApi.ReceivedData(PaymentLinkId,PaymentId);
        }    
    }
    
    //Redirecting Applicants after successful Application Fee Payment
    global void updateApplicantFee(){
        
        Applicant_HomeUrl = Razorpay_Details__c.getValues('Applicant_HomeUrl').Value__c; 
        system.debug('-->'+Applicant_HomeUrl) ;
        PaymentId = apexpages.currentpage().getparameters().get('razorpay_payment_id');
        PaymentLinkId = apexpages.currentpage().getparameters().get('razorpay_payment_link_id');
        Status = apexpages.currentpage().getparameters().get('razorpay_payment_link_status');
        razorPay_Sign = apexpages.currentpage().getparameters().get('razorpay_signature');
        
        Student_Payment__c varStudentPayment = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,Contact__r.Country_Code__c,
                                                Amount__c ,Razorpay_Signature__c,Contact__r.Application_Number__c,contact__r.Name,
                                                Contact__r.FirstName,Contact__r.Program_Name__c,Contact__r.School_Name__c,contact__r.Email ,Contact__r.Application_Fee_Paid__c, Contact__r.MobilePhone
                                                FROM Student_Payment__c WHERE Payment_Link_Id__c =: PaymentLinkId limit 1]; 
        if(varStudentPayment!=null)
        {
            Amount = varStudentPayment.Amount__c;
            if(Status =='paid')
            {
                varStudentPayment.Payment_Status__c = 'Success';
                PaymentMode = 'Online';
                StatusMsg = 'Transaction Success..!!';
                varStudentPayment.Contact__r.Application_Fee_Paid__c = True;  
                update varStudentPayment.Contact__r;
                System.debug('varStudentPayment-->' + varStudentPayment.Contact__r);
                System.debug('varStudentPayment.Contact__r.Application_Fee_Paid__c-->' + varStudentPayment.Contact__r.Application_Fee_Paid__c); 
            }      
            else
            {
                varStudentPayment.Payment_Status__c = 'Failed';  
                PaymentMode = 'Online';
                StatusMsg = 'Transaction Failed..!!';
            }    
            varStudentPayment.Transaction_ID__c = PaymentId;
            varStudentPayment.Mode_of_Payment__c = 'Online';
            varStudentPayment.Payment_Date_Time__c = system.now();
            varStudentPayment.Razorpay_Signature__c = razorPay_Sign;
            varStudentPayment.Payment_Gateway__c = 'Razorpay';
            PurposeofPayment = varStudentPayment.Fee_Type__c;
            TransactionDateTime = varStudentPayment.Payment_Date_Time__c;
            ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');
            //String dtIST = dt.format('dd-MM-yyyy HH:mm:ss', 'IST');
            update varStudentPayment;
        }
        
        //Invoke the methods to Generate and send the attachment
       
        if(varStudentPayment.Payment_Status__c == 'Success'){
            //need to call the sms as future method to send the application number to the user
            string mobile = varStudentPayment.Contact__r.MobilePhone;
            mobile = mobile.remove('+91-');
            List<String> requiredVariables =  new List<String>();
            If(varStudentPayment.Contact__r.Country_Code__c == 'India (+91)'){
                requiredVariables.add(varStudentPayment.Contact__r.Application_Number__C);
                RegistrationFormUtility.futureSMS(SMS_TYPE,mobile,requiredVariables);
            }
            
            //Passing the paymentId(Transaction_ID__C) - as the VisualFOrce is not able to retrieve the fields updated in this class.
            //Hence we are passing them as parameters and using the values in the VF Controller (StudentPaymentController)
            Id cvId = RegistrationFormUtility.generateReceipt(varStudentPayment.Id, PaymentId,varStudentPayment.Payment_Gateway__c);
            RegistrationFormUtility.sendReceipt(varStudentPayment.Id, cvId); 
        }  
   

   

        
        list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
        for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                       Student_Payment__c,Transaction_Date_Time__c from Student_Fee_Payment__c  where
                                                       Payment_Link_Id__c =: PaymentLinkId])
        {
            if(Status =='paid')
                objStuFeePayment.Line_Item_Payment_Status__c = 'Success';
            else 
                objStuFeePayment.Line_Item_Payment_Status__c = 'Failed';
            
            objStuFeePayment.SF_Transaction_ID__c = PaymentId;
            objStuFeePayment.Transaction_Date_Time__c = system.now();
            lst_Studentfee.add(objStuFeePayment);
        }
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_RazorPayResponse_API';
        dblog.Method_Name__c = 'updateStudentFee';
        dblog.Processing_API_Name__c = 'RazorPay';            
        dblog.Data_Received__c = 'PaymentId='+PaymentId+'&PaymentLinkId='+PaymentLinkId+'&Status='+Status+'&razorPay_Sign='+razorPay_Sign;
        if(Status =='paid'){
            dblog.Status__c = 'Success';
        }
        else{
            dblog.Status__c = 'Failure';
        }
        insert dblog;
        // dblog.Response__c = res.getBody();
        // dblog.User_Id__c = UserInfo.getUserId(); 
        if(lst_Studentfee.size()>0){
            update lst_Studentfee; 
        }
        if(string.isNotBlank(PaymentId) && string.isNotBlank(PaymentLinkId)){
            FEE_RazorpayGetPaymentApi.ReceivedData(PaymentLinkId,PaymentId);
        }
        
        
    }
    
}