/**
 * Wrapper class used to pass Callout response from Apex JoobleJobBoardController to LWC joobleJobBoard.
 */
public with sharing class JoobleWrapper {
    // @AuraEnabled public Integer totalCount {get;set;} // TODO use for paginations
    @AuraEnabled public List<JoobleJob> jobs {get;set;}

    public class JoobleJob {
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String location {get;set;}
        @AuraEnabled public String snippet {get;set;}
        @AuraEnabled public String salary {get;set;}
        @AuraEnabled public String source {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String link {get;set;}
        @AuraEnabled public String company {get;set;}
        @AuraEnabled public Datetime updated {get;set;}
        @AuraEnabled public String id {get;set;}
    }

    public static JoobleWrapper parse(String json) {
        return (JoobleWrapper) System.JSON.deserialize(json, JoobleWrapper.class);
    }
}