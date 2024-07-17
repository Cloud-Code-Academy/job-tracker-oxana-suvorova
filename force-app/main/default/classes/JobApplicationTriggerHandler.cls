public with sharing class JobApplicationTriggerHandler extends TriggerHandler {

    private List<Job_Application__c> newJobApps;
    private Map<Id, Job_Application__c> newJobAppsMap;
    private Map<Id, Job_Application__c> oldJobAppsMap;

    /**
     * Constructor. Set instance variables.
     */
    public JobApplicationTriggerHandler() {
        this.newJobApps = (List<Job_Application__c>) Trigger.new;
        this.newJobAppsMap = (Map<Id, Job_Application__c>) Trigger.newMap;
        this.oldJobAppsMap = (Map<Id, Job_Application__c>) Trigger.oldMap;
    }
    
    /**
    * @description Before Insert method.
    **/
    public override void beforeInsert() {
        // Collect Account (Company) Ids to get Contacts
        Set<Id> companies = new Set<Id>();
        for (Job_Application__c jobApp : this.newJobApps) {
            if (jobApp.Primary_Contact__c == null && jobApp.Company_Name__c != null) { 
                companies.add(jobApp.Company_Name__c);
            }
        }
        // Set Primary Contact with the first contact related to the Company
        Map<Id, Id> contactIdByCompanyId = AccountHelper.getContactsByAccounts(companies);
        if (contactIdByCompanyId.size() > 0) {
            for (Job_Application__c jobApp : newJobApps) {
                if (jobApp.Primary_Contact__c == null && jobApp.Company_Name__c != null) {
                    jobApp.Primary_Contact__c = contactIdByCompanyId.get(jobApp.Company_Name__c);
                }
            }
        }
    }

    /**
    * @description Before Update method.
    **/
    public override void beforeUpdate() {
        // Collect first Pivotal Contacts
        Map<Id, Id> pivotContIdByJobAppId = JobApplicationHelper.getPivotalContactByJobApp(this.newJobAppsMap.keySet());
        // Collect Account (Company) Ids to get Contacts
        Set<Id> companies = new Set<Id>();
        Set<Id> jobAppIdsToUpdate = new Set<Id>();
        // Set Promary Contact with first Contact available in the Pivotal Contacts.
        for (Job_Application__c jobApp : this.newJobAppsMap.values()) {
            if (jobApp.Primary_Contact__c == null) {
                jobApp.Primary_Contact__c = pivotContIdByJobAppId.get(jobApp.Id);
                if (jobApp.Primary_Contact__c == null && jobApp.Company_Name__c != null) {
                    companies.add(jobApp.Company_Name__c);
                    jobAppIdsToUpdate.add(jobApp.Id);
                }
            }
        }
        // Set Primary Contact with the first contact related to the Company
        if (companies.size() > 0) {
            Map<Id, Id> contactIdByCompanyId = AccountHelper.getContactsByAccounts(companies);
            for (Id jobAppId : jobAppIdsToUpdate) {
                Job_Application__c jobApp = this.newJobAppsMap.get(jobAppId);
                jobApp.Primary_Contact__c = contactIdByCompanyId.get(jobApp.Company_Name__c);
            }
        }
    }

    /**
    * @description After Insert method.
    **/
    public override void afterInsert() {
        afterInsertUpdate();
    }

    /**
    * @description After Update method.
    **/
    public override void afterUpdate() {
        afterInsertUpdate();
    }

    /**
    * @description After Insert/Update method.
    **/
    private void afterInsertUpdate() {
        // Collect Statuses and Job Applications to create Tasks if Status was updated
        List<String> statuses = new List<String>();
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        for (Job_Application__c jobApp : this.newJobApps) {
            if (Trigger.isUpdate && jobApp.Status__c == this.oldJobAppsMap?.get(jobApp.Id).Status__c) {
                continue;
            }
            statuses.add(jobApp.Status__c);
            jobApps.add(jobApp);
        }
        // Generate the task records based on the application status
        JobApplicationHelper.addTasksByJobAppStatus(jobApps, statuses);
    }
}