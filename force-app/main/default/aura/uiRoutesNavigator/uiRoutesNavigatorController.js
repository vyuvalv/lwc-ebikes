({
    doInit : function(component, event, helper) {
        helper.doGetGroupRoutesList(component);
    },
    onSelectRouteAction:function(component, event, helper) {
        var allGroupedRoutes = component.get('v.groupRoutesList');
        var selectedRouteId = component.get('v.selectedRouteId');
        if(selectedRouteId === null || selectedRouteId === undefined)  {
            selectedRouteId = event.currentTarget.dataset.index;
        }
        var isAdmin = component.get('v.isAdmin');
       // console.log('the selected route is ' + selectedRouteId);
        if(selectedRouteId == 'New'){

              var objectName = component.get('v.routeSObjectName'),
              createRecordEvent = $A.get("e.force:createRecord");
              if(createRecordEvent) {
              createRecordEvent.setParams({
                  "entityApiName": objectName
              });
              createRecordEvent.fire();
              }
          }
      else if (selectedRouteId == 'Refresh') {
        helper.doGetGroupRoutesList(component);
      }
      else {
            for(let group of allGroupedRoutes) {
                for(let route of group.routes){
                    if(route.Id === selectedRouteId) {
                            component.set('v.selectedRoute',route);
                    }
                }
            }
        }
        if(isAdmin == false)
        helper.doNavigate(component);

      },
      onEditRoute:function(component, event, helper) {
        var selectedRouteId = event.currentTarget.dataset.index;
       // console.log('@ Clicked EditMode ' + selectedRouteId);
        var editRecordEvent=$A.get("e.force:editRecord");
            if(editRecordEvent){
            editRecordEvent.setParams({
                "recordId": selectedRouteId
            });
            editRecordEvent.fire();
            }
      },
      doSwitchAdmin:function(component, event, helper) {
          let adminFlag = component.get('v.isAdmin');
          component.set('v.isAdmin',!adminFlag);
      },
 
      handleSelectAction: function (component, event, helper) {
        // This will contain the index (position) of the selected lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");
        if(!selectedMenuItemValue) 
             selectedMenuItemValue = event.getSource().get('v.name');

        var allGroupedRoutes = component.get('v.groupRoutesList');
           if(selectedMenuItemValue)
            component.set('v.selectedRouteId',selectedMenuItemValue);
            console.log('Select Action => ' + selectedMenuItemValue);
            for(let group of allGroupedRoutes) {
                for(let route of group.routes){
                    if(route.Id === selectedMenuItemValue) {
                           component.set('v.selectedRoute',route);
                           helper.doNavigate(component);
                    }
                }
            }
             
    }
})
