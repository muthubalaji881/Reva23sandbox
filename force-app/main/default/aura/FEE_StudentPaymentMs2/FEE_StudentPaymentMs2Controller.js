({
    doInit : function(component, event, helper) 
    {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);        
        helper.doInitHelper(component, event, helper);	
    },
    
   /* onPageReferenceChange: function(cmp, evt, helper)
    {
        var myPageRef = cmp.get("v.pageReference");
        var id = myPageRef.state.c__id;
        cmp.set("v.id", id);
    }, */

    closeModel: function(component, event, helper) 
    {      
        component.set("v.openModel", false);
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
        helper.onPayNowHlpr(component, event, helper);
    },
    
    AfterPaynow : function(component, event, helper)
    {
        component.set("v.ModelSpinner", true);
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var paymap = component.get("v.PaymentMap");
        debugger;
        for (var key in paymap) 
        {            
            if(paymap[key].key == 'RazorPay')
                mapRazorpay = paymap[key].key;
           // if(paymap[key].key == 'PayTM')
              //  mapPaytm = paymap[key].key;
            //if(paymap[key].key == 'EazyPay')
               // mapEasypay = paymap[key].key;            
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
        /*if(mapPaytm == 'PayTM')
        { 
            if(document.getElementById('radio-67').checked) {
                rate_value = document.getElementById('radio-67').value;
            }
        }*/
        if(mapEasypay == 'EazyPay')
        { 
            if(document.getElementById('radio-68').checked) {
                rate_value = document.getElementById('radio-68').value;
            }
        }
        if(mapBilldesk == 'BillDesk')
        {  
            debugger;
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
            if(rate_value == 'RazorPay')
            {
                if(EnteredAmount != null || EnteredAmount != '')
                {                    
                    helper.rezorPayGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                    component.set("v.ModelSpinner", false);
                }
                else
                {
                    helper.rezorPayGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');
                    component.set("v.ModelSpinner", false);
                }
            }
            // Going with only RazorPay for Nov 1st 2022 Application fee Release, hence commenting for now
            if(rate_value == 'BillDesk')
            {
                if(EnteredAmount != null || EnteredAmount != '')
                {                    
                    helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                    component.set("v.ModelSpinner", false);
                }
                else
                {                     
                    helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');
                    component.set("v.ModelSpinner", false);
                }
            } 
        }
    },
    
})