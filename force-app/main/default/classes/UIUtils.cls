public with sharing class UIUtils {
    /**  
        @MethodName : getPackagePrefix
        @Description:get Namespace by given Apex class name
    **/
   public static String getPackagePrefix(String className) {
       ApexClass cs =[select NamespacePrefix from ApexClass where Name =:className];
       return cs.NamespacePrefix;
   }
   /**  
        @MethodName : getCustomMetaDataByDevName
        @Description: get all Custom Metadata records from mdt Object by developerName
    **/
   public static String getMDTQueryByDevName (Boolean needPrefix, String className,Set<String> relationshipFields,Set<String> fields, String mdtObject, String whereClause) {
        String prefix = '';
        if(needPrefix)
        prefix = getPackagePrefix(className)+'__';
   
       // Build custom Metadata query
       String mdtQuery = 'SELECT MasterLabel, DeveloperName, QualifiedApiName,';
       if(relationshipFields.size()>0) {
            for(String field : relationshipFields){
                mdtQuery += prefix + field.replace('__c','__r') + '.QualifiedApiName,';
            }
        }
        if(fields.size()>0){
            for(String field : fields){
                mdtQuery += prefix + field + ',';
            }
        }
        mdtQuery = mdtQuery.removeEnd(',');
        mdtQuery += ' FROM ' + prefix + mdtObject;
        if(whereClause != null)
        mdtQuery += ' WHERE ' + whereClause;

       return mdtQuery;
   }
    /**  
        @MethodName : buildSOQLQuery
        @Description: Build SOQL Query String for given fields,Sobject, filter,sort, limit 
    **/
   public static String buildSOQLQuery (List<String> fields,String objectName, String whereClause, String sortClause, Integer queryLimit ) {
        Set<String> uniqueFields = new Set<String> ();
        String searchQuery = 'SELECT ';
         // add fields to query
        if(fields.size()>0){
            for(String field : fields){
                uniqueFields.add(field); 
            }
           searchQuery += String.join(new List<String>(uniqueFields),',');
        }
        searchQuery += ' FROM ' + objectName;
        if(String.isNotBlank(whereClause))
        searchQuery += ' WHERE ' + whereClause;
        if(String.isNotBlank(sortClause))
        searchQuery += ' ORDER BY ' + sortClause ;
        searchQuery += ' LIMIT ' + queryLimit;
        System.debug(searchQuery);
        return searchQuery;
    }
   /**  
        @MethodName : doQuery
        @Description: Run all queries and throw errors
    **/
    @AuraEnabled 
   public static List<Sobject> doQuery (String queryString,String queryName) {
        List<Sobject> objectList = new List<Sobject>();
        try{
            objectList = Database.query(queryString);   
        }    
        catch (DMLException e) {
            Map<String,Object> errorMap = new Map<String,Object>  {  
                'Exception type caught ' => e.getTypeName(),
                'Message ' => e.getMessage(),
                'Cause ' => e.getCause(),
                'Line number ' => e.getLineNumber(),
                'Stack trace ' => e.getStackTraceString(),
                'Query Name' => queryName
            };
         // "Convert" the exception into an AuraHandledException
          throw new AuraHandledException( JSON.serializePretty(errorMap, true) ); 
        }
       
       return objectList;
   }

    /**  
        @MethodName : getMergedURLParameters
        @Description: Will Merge Context sObject values into DataService Request URL parameters
    **/
    public static String getMergedURLParameters(String urlParametersString, Id contextId) {
        String objectName = contextId.getSObjectType().getDescribe().getName();
        Schema.SObjectType mySObj = Schema.getGlobalDescribe().get(objectName);
        // Get sObject Describe Result
        Schema.DescribeSObjectResult mySObjDescribe = mySObj.getDescribe();
        // Get Field Map
        Map<String,Schema.SObjectField> mapFields = mySObjDescribe.fields.getMap();
        Set<String> fieldToQuery = new Set<String> ();
        for(String fieldName : mapFields.keyset()){
            String mergeString = '%'+fieldName+'%';
            if(urlParametersString.containsIgnoreCase( mergeString )) {
                fieldToQuery.add(fieldName);
            }
        }
        String[] fieldToQueryList = new List<String>();
        fieldToQueryList.addAll(fieldToQuery);
        String whereClause = 'Id =\'' + contextId + '\'';
        if(fieldToQueryList.size()>0){
        String contextParametersQuery = buildSOQLQuery(fieldToQueryList,objectName,whereClause,null,1);
        sObject[] contextObject = doQuery(contextParametersQuery,'contextParametersQuery');
        for(String fieldName : mapFields.keyset()){
            String capField = fieldName.capitalize();
            String mergeString = '%'+capField+'%';
            if(urlParametersString.containsIgnoreCase( mergeString )) {
                String contextValue = String.valueOf(contextObject[0].get(fieldName));
                if(String.isNotBlank(contextValue)) {
                    urlParametersString = urlParametersString.replace(mergeString,contextValue);
                }
            }
        }}
        return urlParametersString;
    }
}
