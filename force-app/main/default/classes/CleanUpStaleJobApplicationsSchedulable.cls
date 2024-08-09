/**
* CleanUpStaleJobApplicationsSchedulable class description:
*
* Schedulable class that runs at a specified time to clean up stale Job Applications.
* Stale Criteria:
*   - Status is not Closed or Accepted
*   - Follow Date 30 days or more
*
**/
public with sharing class CleanUpStaleJobApplicationsSchedulable implements Schedulable {

    public void execute(SchedulableContext sc) {
        Set<String> statusesToIgnore = new Set<String>{'Closed', 'Accepted'};

        List<Job_Application__c> jobApps = [
            SELECT 
                Id,
                Status__c,
                Notes__c
            FROM Job_Application__c
            WHERE Follow_up_date__c <= N_DAYS_AGO:30
                AND Status__c NOT IN :statusesToIgnore
        ];

        if (jobApps.size() > 0) {
            for (Job_Application__c jobApp : jobApps) {
                jobApp.Status__c = 'Closed';
                jobApp.Notes__c = 'The job application was closed by an automated process!';
            }
            Database.update(jobApps);
        }
    }
}