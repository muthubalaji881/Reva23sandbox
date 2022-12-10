({
    
    getURLParameterValue: function() {
        var queryString = location.search.substring(1);
        console.log("contact",queryString);
        
        var paramValue = {};
        queryString.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
    
        return paramValue;
      },
    
    doInitHelper : function(component, event, helper) 
    {
        var urlParams = helper.getURLParameterValue();
        var contactId = urlParams['contactId'];
        debugger;
        if(contactId!=undefined)
        {
        	component.set("v.FlowConId",contactId);
        }
        component.set("v.Spinner", true);
        var varFlowConId =  component.get("v.FlowConId");
        debugger;
        if(varFlowConId != "")
        {debugger;
            var action = component.get("c.displayApplicantFeeRecords");
            debugger;
            action.setParams({
            "flowConId": varFlowConId
           
        });debugger;
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
                    debugger;
                }
            }
            else{                 
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
            
        });          
        }    
        $A.enqueueAction(action);	
    },
    
    onPayNowHlpr: function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var selId =  component.get("v.SelectedRecId");
        console.log("+>"+selId);
        var varFlowConId =  component.get("v.FlowConId");
          debugger;
        if(varFlowConId != undefined)
        {
            var action = component.get("c.fetchApplicantFeeRecords");
            debugger;
            action.setParams({
            "strSelId": selId,
            "flowConId": varFlowConId
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
                    debugger;
                    component.set("v.openModel",true);
                    component.set("v.PaymentMap", mapPayment);
                    component.set("v.lstStuFeePayment",response.getReturnValue().lst_StuFeePayment);
                    component.set("v.feetypestudent",response.getReturnValue().StuFeeType);
                    component.set("v.InstallMentNo",response.getReturnValue().NoOfInstallments);
                    component.set("v.EnteredAmount",response.getReturnValue().PendingAmount); 
                    component.set("v.Spinner", false); 
                    debugger;
                    
                }
            }
            else {      
                debugger;
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
        });

        }
        $A.enqueueAction(action);
    },
    
    rezorPayGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {        
        component.set("v.Spinner", true);
        var varFlowConId =  component.get("v.FlowConId");
        if(varFlowConId != undefined)
        {
        var action = component.get("c.razorPayGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType,
            "flowConId": varFlowConId
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
        }
        $A.enqueueAction(action);	 
    },
    
    // Going with only RazorPay for Nov 1st 2022 Application fee Release, hence commenting for now
    billDeskGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {        
        component.set("v.ModelSpinner", true); 
        var varFlowConId =  component.get("v.FlowConId");
        if(varFlowConId != undefined)
        {
        var action = component.get("c.BillDeskPayGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType,
            "flowConId": varFlowConId
        });
            debugger;
        action.setCallback(this, function(response) {
            var state = response.getState();
            debugger;
            if (state === "SUCCESS") 
            { debugger;
                if(response.getReturnValue() != undefined)
                { debugger;
                    if(response.getReturnValue().statusCode == 200){
                        debugger;
                        window.open(response.getReturnValue().short_url,"_self");
                    }
                
                    else {   
                        debugger;
                        helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else{
                debugger;
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        }
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