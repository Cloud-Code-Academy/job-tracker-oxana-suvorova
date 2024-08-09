public with sharing class JoobleJobBoardController {

    /**
    * @description Returns the result of callout request to the Jooble Job Board API.
    * Callout response Wrapped by class JoobleWrapper and uses in LWC JoobleJobBoard
    * @param keywords: The String represents the search keywords to pass in Callout.
    * @param location: The String used to search for jobs in certain location
    * @param dateFrom: The Datetime value to filter jobs created after this date.
    * @return: The List of wrapped Job positions
    **/
    @AuraEnabled
    public static List<JoobleWrapper.JoobleJob> getNewJobPositions(Map<String, Object> paramsMap){
        try {
            List<JoobleWrapper.JoobleJob> newJobs = new List<JoobleWrapper.JoobleJob>();
            String params = JSON.serialize(paramsMap);
            
            HttpResponse response = makeCallout(params);
            if (response.getStatusCode() == 200) {
                JoobleWrapper jobWrap = JoobleWrapper.parse(response.getBody());
                newJobs = jobWrap.jobs;
            } else {
                throw new CalloutException('Bad request');
            }

            return newJobs;

        } catch (Exception ex) {
            String message = ex.getMessage();
            AuraHandledException auraEx = new AuraHandledException(message);
            auraEx.setMessage(message);
            throw auraEx;
        }
    }

    private static HttpResponse makeCallout(String params) {
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint('callout:JoobleJobBoard');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(params);
        HttpResponse response = http.send(request);

        return response;
    }

    @AuraEnabled
    public static void saveNewJobPositions(List<JoobleWrapper.JoobleJob> selectedJobs){
        // Check if we can insert records before trying to insert
        if (!Schema.SObjectType.Job_Application__c.isCreateable()) {
            throw new SecurityException(
                'Insufficient permissions to create Job Applications'
            );
        }
        // collect account names
        Set<String> accNames = new Set<String>();
        for (JoobleWrapper.JoobleJob joobleJob : selectedJobs) {
            if (String.isBlank(joobleJob.company)) {
                joobleJob.company = 'Default Empty Company';
            }
            accNames.add(joobleJob.company);
        }

        Map<String, Account> accountsByName = AccountHelper.getAccountsByName(accNames);
        // Upsert Job Applications
        List<Job_Application__c> newJobApps = new List<Job_Application__c>();
        for (JoobleWrapper.JoobleJob joobleJob : selectedJobs) {
            Job_Application__c jobApp = new Job_Application__c();
            jobApp.Position_Title__c = joobleJob.title;
            jobApp.Location__c = joobleJob.location;
            jobApp.Description__c = 'Type: ' + joobleJob.type + '<br />' + joobleJob.snippet;
            jobApp.Salary_Info__c = joobleJob.salary;
            jobApp.URL__c = joobleJob.link;
            jobApp.Jooble_Id__c = joobleJob.id;
            jobApp.Company_Name__c = accountsByName.get(joobleJob.company).Id;
            newJobApps.add(jobApp);
        }
        Database.upsert(newJobApps, Job_Application__c.Jooble_Id__c);
    }
}