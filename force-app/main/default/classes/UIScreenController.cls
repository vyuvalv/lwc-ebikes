public with sharing class UIScreenController {

    private static String screenObjectName = 'uiScreen__c';
    private static String screenFields = 'Id,Name,Type__c,PageName__c,InnerActionsFilter__c,ProgressBarType__c,BodyParameters__c';
    private static String sectionObjectName = 'uiSection__c';
    private static String sectionRelatedChild = 'Sections__r';
    private static String sectionFields = 'Id,Name,Title__c,Type__c,PageName__c,BodyParameters__c,ParentScreenId__c,Order__c';
    private static String baseUrl = URL.getSalesforceBaseUrl().getHost();
     /**  
        @MethodName : getScreenByName
        @Description: get Screen Data
    **/
    @AuraEnabled(Cacheable=true)
    public static String getScreenById( String screenId, String contextId)  {
        Map<String,Object> output = new Map<String,Object> ();
        String screenQuery = 'SELECT ' + screenFields + ',( SELECT ' + sectionFields + ' FROM ' + sectionRelatedChild + ' ORDER BY Order__c )' + ' FROM ' + screenObjectName + ' WHERE ';
   
        if( String.isNotBlank(screenId) ) {
            screenQuery += 'Id=\'' + screenId + '\'';
        }
        // if( String.isNotBlank(screenName) ) {
        //     screenQuery += 'Name=\'' + screenName + '\'';
        // }
        screenQuery += ' LIMIT 1';
            System.debug('@@ screenQuery ' + screenQuery);
        uiScreen__c[] screenData = UIUtils.doQuery(screenQuery, 'screenQuery');
        if(screenData.size()>0 && String.isNotBlank(contextId)) {
            String params = screenData[0].BodyParameters__c;
            if(String.isNotBlank(params)) {
                String MergedParams = UIUtils.getMergedURLParameters(params, Id.valueOf(contextId));
                screenData[0].put('BodyParameters__c',MergedParams);
            }
            if(screenData[0].Sections__r.size()>0) {
                for(uiSection__c section : screenData[0].Sections__r) {
                     String sectionParams = section.BodyParameters__c;
                    if(String.isNotBlank(sectionParams)) {
                        String sectionMergedParams = UIUtils.getMergedURLParameters(sectionParams, Id.valueOf(contextId));
                        section.put('BodyParameters__c',sectionMergedParams);
                    }
                }
            }
        }
        output.put('ScreenData',screenData[0]);
        output.put('BaseURL',baseUrl);
        
        return JSON.serialize(output);
    }
}
