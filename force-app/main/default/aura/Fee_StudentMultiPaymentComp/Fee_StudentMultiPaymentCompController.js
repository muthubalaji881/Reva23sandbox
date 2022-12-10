({
    doInit : function(component, event, helper) 
    {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);        
        helper.doInitHelper(component, event, helper);	
    },
    selectAllCheckbox: function(component, event, helper)
    {       
        var selectedHeaderCheck = event.getSource().get("v.value");
        var listStuPendingFee = component.get("v.lstPendingFee");
        var updatedStuRecords = [];
        for (var i = 0; i < listStuPendingFee.length; i++)
        {
            if(selectedHeaderCheck == true)
            {
                listStuPendingFee[i].isChecked = true;
                component.set("v.selectedCount", listStuPendingFee.length);
            }
            else
            {
                listStuPendingFee[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedStuRecords.push(listStuPendingFee[i]);
        }
        component.set("v.lstPendingFee", updatedStuRecords);
    },
    checkboxSelect: function(component, event, helper)
    {
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        if (getSelectedNumber == component.get("v.totalRecordsCount")) 
        {
            component.find("selectAllId").set("v.value", true);            
        }
    },
    MultipleFeeSelect:function(component, event, helper)
    {
        var checkCmp = component.find("tglListviewbtn").get("v.checked");
        component.set("v.ChangeFeePayment",checkCmp);
    },
    closeModel: function(component, event, helper) 
    {      
        component.set("v.openModel", false);
        component.set("v.paytmConfirm",false);
        component.set("v.DisablePayNow",true);
    },
    onPayNow : function(component, event, helper)
    {
        component.set("v.Spinner", true); 
        var index = event.getSource().get("v.name");
        var selectLstFee =[];
        var lstFeePending = component.get("v.lstPendingFee");
        selectLstFee.push(lstFeePending);
        
        var selid = lstFeePending[index].ObjStuFeeDeatils.Id;
        var seldate =lstFeePending[index].ObjStuFeeDeatils.Due_Date__c;
        var selContactid =lstFeePending[index].ObjStuFeeDeatils.Contact__c;
        component.set("v.SelectedRecId",selid);
        component.set("v.SelectedDueDate",seldate);
        component.set("v.SelectedConId",selContactid);
        helper.VlaidationHlpr(component, event, helper);
    },
    onMultiplePayNow : function(component, event, helper)
    {   
        component.set("v.Spinner", true); 
        var updatedStuRecords = [];
        var selectedRecords = [];
        var lstFeePending = component.get("v.lstPendingFee");
        for (var i = 0; i < lstFeePending.length; i++)
        {
            if(lstFeePending[i].isChecked == true)
            {
                updatedStuRecords.push(lstFeePending[i]);
                selectedRecords.push(lstFeePending[i]);
            }
        }
        if(selectedRecords == 0)
        {
            helper.showToast(component,'dismissible','Failed','Please Select Atleast One Record..!','error');
            component.set("v.Spinner",false);
        }
        else
        {  
            component.set("v.MultiSelectList",updatedStuRecords);
            helper.VlaidationMultiHlpr(component, event, helper);
        }
    }, 
    closeMultiModel: function(component, event, helper) 
    {      
        component.set("v.openMultiModel", false);
        component.set("v.paytmConfirm",false);
        component.set("v.DisablePayNow",true);
    },
    ChangeAmount : function(component, event, helper) 
    {
        var tamount = component.get("v.EnteredAmount");
        var TotalPayamount ;
        var feepayment = component.get("v.lstStuFeePayment");
        for(var i=0;i<feepayment.length;i++)
        {
            TotalPayamount = feepayment[i].Amount_Pending__c;
            if(tamount >feepayment[i].Amount_Pending__c)
            {
                helper.showToast(component,'dismissible','Failed','Please Enter Correct Amount','error'); 
                component.set("v.ModelSpinner", false); 
                component.set("v.DisablePayNow",false);
            }
        }
        if(tamount <= TotalPayamount)
        {
            component.set("v.DisablePayNow",true);
        }
    },
    AfterPaynow : function(component, event, helper)
    {
        component.set("v.ModelSpinner", true);
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var paymap = component.get("v.PaymentMap");
        for (var key in paymap) 
        {            
            if(paymap[key].key == 'RazorPay')
                mapRazorpay = paymap[key].key;
            if(paymap[key].key == 'PayTM')
                mapPaytm = paymap[key].key;
            if(paymap[key].key == 'EazyPay')
                mapEasypay = paymap[key].key;            
            if(paymap[key].key == 'BillDesk')
                mapBilldesk = paymap[key].key;
        }
        var rate_value;
        
        if(mapRazorpay == 'RazorPay')
        { 
            if(document.getElementById('radio-66').checked) 
            {
                rate_value = document.getElementById('radio-66').value;
            }
        }
        if(mapPaytm == 'PayTM')
        { 
            if(document.getElementById('radio-67').checked) {
                rate_value = document.getElementById('radio-67').value;
            }
        }
        if(mapEasypay == 'EazyPay')
        { 
            if(document.getElementById('radio-68').checked) {
                rate_value = document.getElementById('radio-68').value;
            }
        }
        if(mapBilldesk == 'BillDesk')
        {        
            if (document.getElementById('radio-65').checked) {
                rate_value = document.getElementById('radio-65').value;
            }
        }
        var EnteredAmount = component.get("v.EnteredAmount");
        var TotalPayamount ;        
        if(rate_value == null || rate_value=='' || rate_value =='undefined')
        {
            helper.showToast(component,'dismissible','Failed','Please Select Paymnet Gateway','error');
            component.set("v.ModelSpinner", false);             
        }
        else
        {
            var feepayment = component.get("v.lstStuFeePayment");
            for(var i=0;i<feepayment.length;i++)
            {
                TotalPayamount = feepayment[i].Amount_Pending__c;
                if(EnteredAmount >feepayment[i].Amount_Pending__c)
                {
                    helper.showToast(component,'dismissible','Failed','Please Enter Correct Amount','error'); 
                    component.set("v.ModelSpinner", false); 
                }
            }
            if(EnteredAmount <= TotalPayamount)
            {
                if(rate_value == 'RazorPay')
                {
                    if(EnteredAmount != null || EnteredAmount != '')
                    {                    
                        helper.rezorPayGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                    else
                    {
                        helper.rezorPayGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                }
                if(rate_value == 'BillDesk')
                {
                    if(EnteredAmount != null || EnteredAmount != '')
                    {                    
                        helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                    else
                    {                     
                        helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                }
                if(rate_value == 'EazyPay')
                {
                    if(EnteredAmount != null || EnteredAmount != '')
                    {     
                        helper.EasyPayGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                    else
                    {          
                        helper.EasyPayGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                }
                if(rate_value == 'PayTM')
                {
                    if(EnteredAmount != null || EnteredAmount != '')
                    {     
                        helper.paytmGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                    else
                    {          
                        helper.paytmGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                }
            }
        }        
    },
    MultipleAfterPayNow : function(component, event, helper)
    {
        component.set("v.ModelSpinner", true);         
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var Multipaymap = component.get("v.MultiPaymentMap");
        for (var key in Multipaymap) 
        {
            if(Multipaymap[key].key == 'RazorPay')
                mapRazorpay = Multipaymap[key].key;
            if(Multipaymap[key].key == 'PayTM')
                mapPaytm = Multipaymap[key].key;
            if(Multipaymap[key].key == 'EazyPay')
                mapEasypay = Multipaymap[key].key;
            if(Multipaymap[key].key == 'BillDesk')
                mapBilldesk = Multipaymap[key].key;            
        }
        var rate_value;
        var totalpayAmount = component.get("v.totalAmount");
        
        if(mapRazorpay == 'RazorPay')
        {  
            if(document.getElementById('radio-66').checked) {
                rate_value = document.getElementById('radio-66').value;
            }
        }
        if(mapPaytm == 'PayTM')
        {  
            if(document.getElementById('radio-67').checked) {
                rate_value = document.getElementById('radio-67').value;
            }
        }
        if(mapEasypay == 'EazyPay')
        {  
            if(document.getElementById('radio-68').checked) {
                rate_value = document.getElementById('radio-68').value;
            }
        }
        if(mapBilldesk == 'BillDesk')
        {  
            if (document.getElementById('radio-65').checked) {
                rate_value = document.getElementById('radio-65').value;
            }
        }
        if(rate_value == null || rate_value=='' || rate_value =='undefined')
        {
            helper.showToast(component,'dismissible','Failed','Please Select Paymnet Gateway','error'); 
            component.set("v.ModelSpinner", false);
        }
        else
        {
            var multirecds =  component.get("v.lstMultipleRecords");
            if(rate_value == 'RazorPay') 
            {                
                helper.rezorPayGeneratePaymentLink(component, event, helper,multirecds,totalpayAmount,'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow",false);
            }
            if(rate_value == 'BillDesk')
            {
                helper.billDeskGeneratePaymentLink(component, event, helper,multirecds,totalpayAmount,'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow",false);
            }
            if(rate_value == 'EazyPay')
            {
                helper.EasyPayGeneratePaymentLink(component, event, helper,multirecds,totalpayAmount,'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow",false);
            }
            if(rate_value == 'PayTM')
            {
                helper.paytmGeneratePaymentLink(component, event, helper,multirecds,totalpayAmount,'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow",false);
            }
        }
    },
     paytmRedirect : function(component, event, helper) {
        component.find("paymentForm").getElement().submit();
    },
    view : function(component, event, helper)
    {
      var index = event.currentTarget.getAttribute("data-value");
      //var index = event.getSource().get("v.name");       
      var lstStuFeePending = component.get("v.lstStuPaymentFee");        
      var selid = lstStuFeePending[index].Id;
      // var url =window.open('/apex/FEE_FeeReceipt?id=' + selid);

      // >>>>>> New Code Start <<<<<<
      console.log('>>> ' + window.location.href);
      //https://strtsdev23-reva-university.cs31.force.com/StudentPortal/s/student-fee
      var currLocation = window.location.href;
      var siteIndictor = currLocation.indexOf('/s/');
      if (siteIndictor != -1) {
        currLocation = currLocation.substring(0, siteIndictor);
      }
      console.log('>>>> Curr Location: ' + currLocation);
      //https://strtsdev23-reva-university.cs31.force.com/StudentPortal
      var url = window.open(currLocation + '/apex/FEE_FeeReceipt?id=' + selid);
      // >>>>>> New Code End <<<<<<

      var urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
          "url": url
      });
      urlEvent.fire();
    }
})