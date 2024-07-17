public with sharing class JobApplicationHelper {

    /**
    * @description Collect the first Pivotal Contact to the Job Application.
    * @param jobAppIds: List of Job Application Ids
    * @return: the Map of the first Pivotal Contact Id by it's Job Application Id.
    **/
    public static Map<Id, Id> getPivotalContactByJobApp(Set<Id> jobAppIds) {
        Map<Id, Id> contactIdByJobAppId = new Map<Id, Id>();
        List<Job_Application__c> jobAppWithPivotalCont = [
            SELECT 
                Id, 
                (SELECT Contact__c 
                FROM Pivotal_Contacts__r 
                ORDER BY Name ASC LIMIT 1)
                FROM Job_Application__c
                WHERE Id IN :jobAppIds
        ];
        for (Job_Application__c jobApp : jobAppWithPivotalCont) {
            if (jobApp.Pivotal_Contacts__r.size() > 0) {
                contactIdByJobAppId.put(jobApp.Id, jobApp.Pivotal_Contacts__r[0].Contact__c);
            }
        }
        return contactIdByJobAppId;
    }

    /**
    * @description Runs Queueable class to create Tasks related to the Job Application Status
    * @param jobAppStatusById: Map of the Job Application Statuses by the Job Application Ids
    **/
    public static void addTasksByJobAppStatus(List<Job_Application__c> jobApps, List<String> statuses) {
        JobApplicationTasksQueueable jobAppTasksJob = new JobApplicationTasksQueueable(jobApps, statuses);
        System.enqueueJob(jobAppTasksJob);
    }
}