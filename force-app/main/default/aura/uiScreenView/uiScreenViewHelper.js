({
    getScreenFromRoute : function(component) {
        const screenId = component.get('v.uiScreenId');
   
        if(screenId !== null && screenId !== undefined && screenId !== 'none'){
        var action = component.get("c.getScreenById");
        action.setParams({
            'screenId': screenId,
            'contextId':component.get('v.recordId')
          });
        action.setCallback(this, function(response){
            var state = response.getState();
            component.set('v.showSpinner',false);
            if (state === "SUCCESS") { 
                var data = JSON.parse(response.getReturnValue());
                    if(data){
                        // check for actions
                        if(data.ScreenData.InnerActionsFilter__c)
                        component.set('v.routesFilter',data.ScreenData.InnerActionsFilter__c);
                        // check for pagesName 
                        if(data.ScreenData.PageName__c !== null && data.ScreenData.PageName__c !== undefined){
                            let compName = data.ScreenData.PageName__c;
                          

                            if(data.ScreenData.Type__c !== undefined && data.ScreenData.Type__c !== null){
                                component.set('v.screenType',data.ScreenData.Type__c );
                                }
                            if(data.ScreenData !== undefined){
                                    component.set('v.screenObject',data.ScreenData);
                                }

                       if(data.ScreenData.Type__c == 'LightningComponent') {    
                           let bodyParams = JSON.parse(data.ScreenData.BodyParameters__c);
                         
                           this.doCreateComponent(component,compName, bodyParams,'compDiv');
                        }
                        else if(data.ScreenData.Type__c == 'Visualforce'){
                            compName = compName + data.ScreenData.BodyParameters__c;
                           
                            if(data.BaseURL !== undefined && data.BaseURL !== null)
                            component.set('v.vfHost',data.BaseURL);
                            console.log('PageName ' + compName + ' Type ' + data.ScreenData.Type__c + ' host ' + data.BaseURL);
                        }
                        else {
                            //Process
                            let processParams = {
                                "uiScreen":data.ScreenData,
                                "isAdmin":component.get('v.isAdmin'),
                                "progressBarType":data.ScreenData.ProgressBarType__c
                            }
                            this.doCreateComponent(component,'c:uiProcessTabs', processParams,'compDiv');
                        }
                        component.set('v.pageName',compName);
                    }
                        
                    
                       
                  }
            }
            else {
                var errors = response.getError();
                this.addError(component,state + ' - In getScreenFromRoute',JSON.stringify(errors[0].message));
            }
        });
        $A.enqueueAction(action);
        }
    },
    doCreateComponent: function(component,compName, params,divId){
       // let namespace = 'c:'+compName;
        $A.createComponents([
            [compName,params]],
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    const comp = components[0];
                   let compDiv = component.find(divId);
                    if(compDiv)
                    compDiv.set("v.body", comp);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
            );

    },
    addError: function(component,msg,details) {

        $A.createComponents([
            ["c:uiErrorMessage",{
                "title" : msg,
                "message":details,
                "severity" : "error",
                "iconVariant": "error",
                "iconName":"utility:priority",
                "closable":true
            }]],
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    var comp = components[0];
                    var errorMsgdiv = component.find("errorMsg");
                    // Replace div body with the dynamic component
                    errorMsgdiv.set("v.body", comp);
                    
                    //component.set('v.showSpinner',false);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    
  },
})
