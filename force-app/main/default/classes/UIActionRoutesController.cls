public with sharing class UIActionRoutesController {
    
    private static String routeObjectName = 'UIRouteAction__c';
    private static String groupingFieldName = 'Group__c';
    private static String orderField = 'Order__c';
    private static String[] routeFields = new List<String>{'Id','Name','uiScreenId__c','ContextIdField__c','Label__c','Group__c','LightningIcon__c','NavigationType__c','RelationshipApiName__c','FilterName__c','Mode__c','ObjectApiName__c','IsNavigation__c','TargetURL__c','MergedParameters__c','Active__c','PageName__c'};
    private static String routeStaticFilterClause = 'Active__c = true';
    private static Integer routeStaticLimit = 50;
    /**  
        @MethodName : getFieldSetFromObjectId
        @Description: get all fields from a Fieldset Name and contextId 
    **/
    @AuraEnabled(Cacheable=true)
    public static String getGroupedRoutesList( String contextId, String contextObject, String extraWhereClause,String sortOrder )  {
        Set<String> groupNames = new Set<String>();
        String routeWhereClause = routeStaticFilterClause;
        if(String.isNotBlank(extraWhereClause)) {
            routeWhereClause += ' AND ' + extraWhereClause;
        }
        String routeSortClause = orderField + ' ' + sortOrder;
        String routeQueryString = UIUtils.buildSOQLQuery(routeFields,routeObjectName, routeWhereClause,routeSortClause,routeStaticLimit);
        List<Sobject> routesList = UIUtils.doQuery(routeQueryString,'routeQueryString');
        List<Sobject> updatedRoutesList = new List<Sobject>();
        for(Sobject route:routesList) {
            String URLParams = (String)route.get('MergedParameters__c');

            if(contextId !='home'){
            String contextField = (String)route.get('ContextIdField__c');
            //call Merged ContextId Method
                if(contextField == 'Id' || String.isBlank(contextField)) {
                    route.put('ContextIdField__c',contextId);
                }
                else {
                    try {
                        String returnedContext = getContextId(contextField,contextObject,contextId);
                        route.put('ContextIdField__c',returnedContext);
                    }
                    catch(Exception e) {
                        throw new AuraHandledException( 'Wrong Field ' + e.getMessage() ); 
                    }
                }
           
            
            //call Merged URL Method
            if(String.isNotBlank(URLParams)){
            String MergedURLParams = UIUtils.getMergedURLParameters(URLParams,contextId);
            route.put('MergedParameters__c',MergedURLParams);
            }
            }
            String currentGroup = (String)route.get(groupingFieldName);
            groupNames.add(currentGroup);
            updatedRoutesList.add(route);
        }
        
        List<Map<String,Object>> groupedRoutesList = new List<Map<String,Object>> ();
        for(String  groupName: groupNames)  {
          Map<String,Object> groupObject = new Map<String,Object>();
          List<SObject>groupRoutes = new List<SObject>();
          for(Sobject route:updatedRoutesList) {
              String currentRouteGroup = (String)route.get(groupingFieldName);
              if( currentRouteGroup == groupName ) {
                  groupRoutes.add(route);
              }
          }
          groupObject.put('groupName',groupName);
          groupObject.put('routes',groupRoutes);
          groupedRoutesList.add(groupObject);   
        }
        return JSON.serialize(groupedRoutesList);
    }
    /**  
        @MethodName : getContextIdField
        @Description: Will Merge Context sObject values into DataService Request URL parameters
    **/
    public static String getContextId(String contextField, String contextObjectName, Id contextId) {
        String contextQuery = 'SELECT ' + contextField + ' FROM ' + contextObjectName + ' WHERE Id=\'' + contextId +'\'';
        System.debug('contextQuery ' + contextQuery);
        List<Sobject> contextSObjects = UIUtils.doQuery(contextQuery,'contextQuery');
        return String.valueOf(contextSObjects[0].get(contextField));
    }
    
   
}
