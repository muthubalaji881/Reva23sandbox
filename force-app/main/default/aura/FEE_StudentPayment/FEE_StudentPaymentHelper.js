({
    doInitHelper : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        var action = component.get("c.DisplayStudentFeeRecords");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();
                    component.set("v.lstPendingFee",retVal.lst_CheckboxWrap);
                    component.set("v.lstPaidFee",retVal.lst_StuPaidDetails);
                    component.set("v.lstStuPaymentFee",retVal.lst_StuPaymentDetails);
                    component.set("v.totalRecordsCount",retVal.lst_CheckboxWrap.length);
                    component.set("v.Studentname",retVal.objStuname);
                    component.set("v.AppNumber",retVal.objAppNumber);
                    component.set("v.SrnNumber",retVal.objSrnNumber);
                    component.set("v.Spinner", false); 
                    component.set("v.totalStuAmount",retVal.TotalAmount);
                    component.set("v.totalStuPenAmount",retVal.TotalPendingAmount);
                    component.set("v.totalStuPaidAmount",retVal.TotalPaidAmount);
                }
            }
            else{                 
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
            
        });       
        $A.enqueueAction(action);	
    },
    VlaidationHlpr: function(component, event, helper)
    {
        component.set("v.Spinner", true); 
        var selid =  component.get("v.SelectedRecId");
        var seldate =  component.get("v.SelectedDueDate");
        var selconatctid = component.get("v.SelectedConId");
        if(seldate != undefined)
        {
            var action = component.get("c.ValidationDate");
            action.setParams({
                "strSelid":selid,
                "selduedate":seldate,
                "Conid":selconatctid
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    if(response.getReturnValue() != undefined)
                    {
                        if(response.getReturnValue().DateError != null)
                        {
                            var retVal = response.getReturnValue().DateError;
                            this.showToast(component,'dismissible','Failed',retVal,'error');
                        }
                        else 
                        {
                            helper.onPayNowHlpr(component, event, helper);
                        }    
                    }
                    component.set("v.Spinner", false);  
                }
                else {                 
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            helper.onPayNowHlpr(component, event, helper);
        }
    },
    onPayNowHlpr: function(component, event, helper)
    {
        var selid =  component.get("v.SelectedRecId");
        var action = component.get("c.FetchFeeRecords");
        action.setParams({
            "strSelid": selid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    var mapPayment = [];
                    var result = response.getReturnValue().map_PaymentGateway;
                    for(var key in result){
                        mapPayment.push({key: key, value: result[key]});
                    }    
                    component.set("v.openModel",true);
                    component.set("v.PaymentMap", mapPayment);
                    component.set("v.lstStuFeePayment",response.getReturnValue().lst_StuFeePayment);
                    component.set("v.feetypestudent",response.getReturnValue().StuFeeType);
                    component.set("v.InstallMentNo",response.getReturnValue().NoOfInstallments);
                    component.set("v.EnteredAmount",response.getReturnValue().PendingAmount); 
                    component.set("v.Spinner", false); 
                }
            }
            else {                 
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    VlaidationMultiHlpr: function(component, event, helper)
    {
        component.set("v.Spinner", true); 
        var totalRecamount =0;            
        var selcRecords = component.get("v.MultiSelectList");
        var selRecList =[];
        for(var i=0;i<selcRecords.length;i++)
        {
            selRecList.push(selcRecords[i].ObjStuFeeDeatils);
            if(selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c != null)
            {
                totalRecamount = totalRecamount + selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c ;
            }
        }
        component.set("v.totalAmount",totalRecamount);            
        component.set("v.SelectedRecLst",selRecList);
        var action = component.get("c.ValidateMultiPayments");
        action.setParams({
            "lst_StuIds": selRecList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().DateError != null)
                    {
                        var retVal = response.getReturnValue().DateError;
                        this.showToast(component,'dismissible','Failed',retVal,'error');
                    }
                    if(response.getReturnValue().DateError == null)
                    {
                        helper.MultipayHlpr(component, event, helper);                        
                    }    
                }
                component.set("v.Spinner", false);  
            }
            else {                 
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);        
    },
    MultipayHlpr :function(component, event, helper)
    {
        component.set("v.Spinner", true); 
        var totalRecamount =0;            
        var selcRecords = component.get("v.MultiSelectList");
        var selRecList =[];
        for(var i=0;i<selcRecords.length;i++)
        {
            selRecList.push(selcRecords[i].ObjStuFeeDeatils);
            if(selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c != null)
            {
                totalRecamount = totalRecamount + selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c ;
            }
        }
        component.set("v.totalAmount",totalRecamount);            
        component.set("v.SelectedRecLst",selRecList);
        var action = component.get("c.MultiStduentFeeRecords");
        action.setParams({
            "lst_StuIds": selRecList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    var mapPayment = [];
                    var result = response.getReturnValue().map_PaymentGateway;
                    for(var key in result){
                        mapPayment.push({key: key, value: result[key]});
                    }   
                    component.set("v.openMultiModel",true); 
                    component.set("v.MultiPaymentMap", mapPayment);
                    component.set("v.lstMultipleRecords",response.getReturnValue().lst_StuFeePayment);
                    component.set("v.ErrMessage",response.getReturnValue().Errmsg);
                    component.set("v.Spinner", false); 
                }
            }
            else{                 
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    rezorPayGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {        
        component.set("v.Spinner", true); 
        var action = component.get("c.razorPayGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().statusCode == 200){
                        window.open(response.getReturnValue().short_url,"_self");
                    }
                    else {                        
                        helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                        component.set("v.Spinner", false);
                    }
                }
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);	 
    },
    billDeskGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {        
        component.set("v.ModelSpinner", true); 
        var action = component.get("c.BillDeskPayGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().statusCode == 200){
                        window.open(response.getReturnValue().short_url,"_self");
                    }
                    else {                        
                        helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);	 
    },
	EasyPayGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {        
        component.set("v.ModelSpinner", true); 
        var action = component.get("c.easypayGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().statusCode == 200){
                        window.open(response.getReturnValue().short_url,"_self");
                    }
                    else {                        
                        helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);	 
    },   
    paytmGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {        
        component.set("v.ModelSpinner", true); 
        var action = component.get("c.PaytmGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           // alert('+++++++++'+state);
            if (state === "SUCCESS") 
            {
                
                if(response.getReturnValue() != undefined)
                {
                  //  alert('+++++++++'+response.getReturnValue().statusCode);
                    if(response.getReturnValue().statusCode == 200){
                        var retVal = response.getReturnValue();
                       // var payUrl = 'https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?mid='+retVal.id+'&orderId='+retVal.status;
                        component.set("v.paytmUrl", retVal.short_url);
                        component.set("v.paytmResponse", retVal);
                        component.set("v.paytmConfirm", true);
                        component.set("v.openModel", false);
                        component.set("v.openMultiModel", false);
                      //  alert('+++++++++'+JSON.stringify(retVal));
                      //  component.find("paymentForm").getElement().submit();
                     //  this.paytmRedirect(component, event, helper);
                    }
                    else {                        
                        helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);	 
    },
   
    showToast : function(component, mode, title, message, type)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2'
        });
        toastEvent.fire();
    }
})