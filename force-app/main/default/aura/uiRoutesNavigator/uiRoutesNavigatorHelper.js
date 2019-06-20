({
    doGetGroupRoutesList : function(component) {
        let filterClause = component.get('v.routeFilterString');
        if(filterClause == null || filterClause == undefined)
             filterClause = 'Order__c >' + component.get('v.fromOrder') + ' AND ' + 'Order__c <' +component.get('v.toOrder');
        var action = component.get("c.getGroupedRoutesList");
        action.setParams({
            'contextId': component.get('v.recordId'),
            'contextObject':component.get('v.sObjectName'),
            'extraWhereClause':filterClause,
            'sortOrder':component.get('v.sortOrder')
          });
        action.setCallback(this, function(response){
            const state = response.getState();
            if (state === "SUCCESS") { 
               
                var routeList = JSON.parse(response.getReturnValue());
                let sortedRouteList = [];
                    if(routeList){
                        for(let group of routeList ) {
                            group.routes.sort((a, b) => parseInt(a.Order__c) - parseInt(b.Order__c));
                        }
                        component.set('v.groupRoutesList',routeList);
                    }
            }
            else {
                var errors = response.getError();
                this.addError(component,state + ' - In doGetGroupRoutesList',JSON.stringify(errors[0].message));
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action);
    },
    doNavigate: function(component){
        const selectedRoute = component.get('v.selectedRoute');
        //const contextId = component.get('v.recordId');

        if(selectedRoute.IsNavigation__c == true) {
            const navService = component.find("navigationService");
            const navType = selectedRoute.NavigationType__c;
           
            switch(navType) {
                case 'RecordHome':
                let recordHomeReference = {
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: selectedRoute.ObjectApiName__c,
                        actionName: 'home'
                    }
                };
                navService.navigate(recordHomeReference);
                break;
                case 'RecordPage':
                let recordPageReference = {    
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": selectedRoute.MergedParameters__c,
                        "objectApiName": selectedRoute.ObjectApiName__c,
                        "actionName": selectedRoute.Mode__c
                    }
                };
                navService.navigate(recordPageReference);
                break;
                case 'ListView':
                let listViewReference = {
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: selectedRoute.ObjectApiName__c,
                        actionName: 'list'
                    },
                    state: {         
                        "filterName": selectedRoute.FilterName__c   
                    } 
                };
                navService.navigate(listViewReference);
                break;
                case 'LightningPage':
                let lexReference = {         
                    "type": "standard__namedPage",    
                    "attributes": {        
                        "pageName": selectedRoute.PageName__c,     
                    } 
                };
                navService.navigate(lexReference);
                break;
                case 'RelatedList':
                let relatedReference = {    
                    "type": "standard__recordRelationshipPage",
                    "attributes": {
                        "recordId": selectedRoute.ContextIdField__c,
                        "objectApiName": selectedRoute.ObjectApiName__c,
                        "relationshipApiName": selectedRoute.RelationshipApiName__c,
                        "actionName": 'view'
                    }
                }
                navService.navigate(relatedReference);
                break;
                case 'WebPage':
                let fullURL = selectedRoute.TargetURL__c;
                if(selectedRoute.MergedParameters__c !== null && selectedRoute.MergedParameters__c !== undefined) {
                    fullURL += selectedRoute.MergedParameters__c;
                }           
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                  "url": fullURL
                });
                eUrl.fire();
                //New still not working
                // let webReference = {
                //     type: 'standard__webPage',
                //      attributes: { 
                //         url: fullURL 
                //     },
                //     replace: false 
                // };
                // navService.generateUrl(webReference).then($A.getCallback(function(url) {
                //     cmp.set("v.url", url ? url : defaultUrl);
                // }), $A.getCallback(function(error) {
                //     cmp.set("v.url", defaultUrl);
                // }));
                // navService.navigate(webReference);
                break;
                default:
                console.log(' navType default ' + navType);
            }
        }
        else {
            //do application Event
         console.log('check urlParams ' + JSON.stringify(selectedRoute));
           var appClickEvent = $A.get("e.c:uiRouteClickEvent");
           appClickEvent.setParams({
               "routeData" : selectedRoute
            });  
           appClickEvent.fire();

        }
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
                    console.log('its working');
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
