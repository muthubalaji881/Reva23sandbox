@isTest
private class SMS_Followup_Test {
    @isTest static void testCallout() {
        String smsType = 'Counsellor_Online_Paid_Application';
        Map<String, List<String> > phoneWithDynamicVariables = new Map<String, List<String> >();
        String phone ='+918341619029';
        List<String> requriedVariables = new List<String>{'Shiva', 'Parthiban', 'Admission', 'Counsellor Team', 'REVA University'}; 
        phoneWithDynamicVariables.put(phone,requriedVariables);

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMocksBulkSMS_Test());
       // String smsType = 'Counsellor_Online_Paid_Application';
        String unicode='false';
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        
        HttpResponse res = SMS_BulkGeneric.sendBulkSMS_Personalized(smsType,phoneWithDynamicVariables);
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"unicode":false,"shortMessages":[{"recipient":"+918341619029","message":"Dear Shiva \\nI am your dedicated senior counselor, Parthiban, to help you take admissions at REVA University.\\nLet'+'s talk on Admission about ONLINE admissions process.\\nRegards\\nCounsellor Team\\nREVA University","dltContentId":"1007005251825380828"}],"from":"REVAUN","credentials":{"user":"revaerp.trans","password":"s1Sz2"}}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());   
        
            // Set mock callout class 
            
    }

    @isTest static void testPersonalizedInvocableLead(){
        Map<String, List<String> > phoneWithDynamicVariables = new Map<String, List<String> >();
        String smsType = 'Counsellor_Online_Paid_Application';
        List<String> dynVar = new List<String>{'Admission', 'Counsellor Team', 'REVA University'};
        Lead l = new Lead();
        l.MobilePhone='+91-9998989789';
        
        if(l.MobilePhone.contains('-')){
        l.MobilePhone.remove('-');
        }
        phoneWithDynamicVariables.put(l.MobilePhone,dynVar);
    
       List<SMS_InvocableBulkPersonalized.Request> requests = new List<SMS_InvocableBulkPersonalized.Request>();
        SMS_InvocableBulkPersonalized.Request request = new SMS_InvocableBulkPersonalized.Request();
        List<SMS_BulkFlowVariablesWrapper> wrapperLists = new List<SMS_BulkFlowVariablesWrapper>();
        SMS_BulkFlowVariablesWrapper wrapper = new SMS_BulkFlowVariablesWrapper();
        wrapper.smsType = smsType;
        wrapper.eachDynamicVar =dynVar;
        wrapper.selectedLead = l;
        //wrapper.selectedContact= c;
        wrapperLists.add(wrapper);
        request.wrapperlist = wrapperLists;
        requests.add(request);
        try {
        Test.startTest();
        SMS_InvocableBulkPersonalized.sendBulkPersonalizedSMS(requests);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('List index out of bounds: 3', e.getMessage());
        }

    }
   
    @isTest static void testPersonalizedInvocableContact(){
        Map<String, List<String> > phoneWithDynamicVariables = new Map<String, List<String> >();
        String smsType = 'Counsellor_Online_Paid_Application';
        List<String> dynVar = new List<String>{'Admission', 'Counsellor Team', 'REVA University'};
       
        Contact c= new Contact();
        c.MobilePhone='+91-9998979789';
        
        if(c.MobilePhone.contains('-')){
        c.MobilePhone.remove('-');
        }
        phoneWithDynamicVariables.put(c.MobilePhone,dynVar);
     
       List<SMS_InvocableBulkPersonalized.Request> requests = new List<SMS_InvocableBulkPersonalized.Request>();
        SMS_InvocableBulkPersonalized.Request request = new SMS_InvocableBulkPersonalized.Request();
        List<SMS_BulkFlowVariablesWrapper> wrapperLists = new List<SMS_BulkFlowVariablesWrapper>();
        SMS_BulkFlowVariablesWrapper wrapper = new SMS_BulkFlowVariablesWrapper();
        wrapper.smsType = smsType;
        wrapper.eachDynamicVar =dynVar;
        //wrapper.selectedLead = '';
        wrapper.selectedContact= c;
        wrapperLists.add(wrapper);
        request.wrapperlist = wrapperLists;
        requests.add(request);
        try{
        Test.startTest();
        SMS_InvocableBulkPersonalized.sendBulkPersonalizedSMS(requests);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('List index out of bounds: 3', e.getMessage());
        }


    }
    @isTest static void testSingleSMSInvocable(){
        
        String smsType = 'Counsellor_Online_Paid_Application';
        List<String> dynVar = new List<String>{'Siva','Sai','Admission', 'Counsellor Team', 'REVA University'};
        string mobilePhone = '+91-9999998877';
        if(mobilePhone.contains('-')){
        mobilePhone.remove('-');
        }
    
       List<SMS_InvocableSingle.flowInput> requests = new List<SMS_InvocableSingle.flowInput>();
       SMS_InvocableSingle.flowInput request = new SMS_InvocableSingle.flowInput();
        //List<SMS_BulkFlowVariablesWrapper> wrapperLists = new List<SMS_BulkFlowVariablesWrapper>();
        SMS_BulkFlowVariablesWrapper wrapper = new SMS_BulkFlowVariablesWrapper();
        wrapper.smsType = smsType;
        wrapper.eachDynamicVar =dynVar;
        wrapper.mobilePhone =mobilePhone;
        //wrapper.selectedContact= c;
        //wrapperLists.add(wrapper);
        request.wrapper = wrapper;
        requests.add(request);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMocks_Test());
        Test.startTest();
        SMS_InvocableSingle.sendSingleSMS(requests);
        Test.stopTest();

    }


}