({
    getContactHelper  : function(component, event, helper) 
    {
        let action=component.get('c.fetchContact');
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS')
            {               
                component.set('v.ContactDetails',response.getReturnValue());                 
            }  
        });
        $A.enqueueAction(action);
    },
    doRedirectHelper : function (component, event, helper) {
        let ConId=event.getSource().get('v.name');        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": ConId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
})