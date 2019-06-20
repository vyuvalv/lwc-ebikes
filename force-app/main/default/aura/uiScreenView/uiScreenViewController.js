({
    doInit : function(component, event, helper) {
        const screenId = component.get('v.uiScreenId');
        if(screenId !== null && screenId !== undefined && screenId !== 'none')
        helper.getScreenFromRoute(component);
        else {
            component.set('v.showSpinner',false);
            helper.addError(component,'No Screen selected','Please select a screen to display as default');
        }
    },
    doGetScreen: function(component, event, helper) {
    //    const screenId = component.get('v.uiScreenId');
    //    if(screenId !== null && screenId !== undefined)
       helper.getScreenFromRoute(component);
    },
    doSetScreen:function(component, event, helper) {
        const selectedRoute = event.getParam("routeData");
        //not needed potentially but just verify
        if(selectedRoute.IsNavigation__c == false) {
            if(selectedRoute.uiScreenId__c !== null) {
                component.set('v.uiScreenId',selectedRoute.uiScreenId__c);
                component.set('v.screenTitle',selectedRoute.Label__c);
                component.set('v.iconName',selectedRoute.LightningIcon__c);
                component.set('v.routesFilter',null);
                console.log('recieved from event ' + selectedRoute.uiScreenId__c);
                //helper.getScreenFromRoute(component, selectedRoute.uiScreenId__c);
            }
            
        }
    },
    doEditScreen: function(component, event, helper) {
        const screenId = component.get('v.uiScreenId');
        var editRecordEvent=$A.get("e.force:editRecord");
            if(editRecordEvent){
            editRecordEvent.setParams({
                "recordId": screenId
            });
            editRecordEvent.fire();
            }
    },
    

})
