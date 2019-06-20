public class UIError {
        @AuraEnabled public Object exceptionType {get;set;}
        @AuraEnabled public Object message {get;set;}
        @AuraEnabled public Object cause {get;set;}
        @AuraEnabled public Object lineNumber {get;set;}
        @AuraEnabled public Object stackTrace {get;set;}
        @AuraEnabled public String query {get;set;}
        @AuraEnabled public String customMSG {get;set;}

        public UIError (String customMSG, String query, Object exceptionType,Object message,Object cause,Object lineNumber,Object stackTrace) {
            this.customMSG = customMSG;
            this.exceptionType = exceptionType;
            this.message = message;
            this.cause = cause;
            this.lineNumber = lineNumber;
            this.stackTrace = stackTrace;
            this.query = query;
        }

    }