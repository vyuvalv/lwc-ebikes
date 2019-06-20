({
    onClick : function(component, event, helper) {
        var id = event.target.dataset.menuItemId;
        if (id) {
            component.getSuper().navigate(id);
         }
   },
   doInit: function(component, event, helper) {
       const isRTL = component.get('v.rtl');

       if(isRTL){
            let cmpMenu = component.find('menuDirection');
            $A.util.addClass(cmpMenu, 'nav-direction');
        }
        else {
            let cmpMenu = component.find('menuDirection');
            $A.util.removeClass(cmpMenu, 'nav-direction');
        }
   },
})