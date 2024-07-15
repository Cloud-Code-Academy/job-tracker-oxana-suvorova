public with sharing class JobApplicationTriggerHandler extends TriggerHandler {

    private List<Job_Application__c> newJobApps;
    private Map<Id, Job_Application__c> newJobAppsMap;

    /**
     * Constructor. Set instance variables.
     */
    public JobApplicationTriggerHandler() {
        this.newJobApps = (List<Job_Application__c>) Trigger.new;
        this.newJobAppsMap = (Map<Id, Job_Application__c>) Trigger.newMap;
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
        Map<Id, Id> contactIdByCompanyId = getContactsByAccounts(companies);
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
        Map<Id, Id> pivotContIdByJobAppId = getPivotalContactByJobApp(this.newJobAppsMap.keySet());
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
            Map<Id, Id> contactIdByCompanyId = getContactsByAccounts(companies);
            for (Id jobAppId : jobAppIdsToUpdate) {
                Job_Application__c jobApp = this.newJobAppsMap.get(jobAppId);
                jobApp.Primary_Contact__c = contactIdByCompanyId.get(jobApp.Company_Name__c);
            }
        }
    }

    /**
    * @description Collect the first related Contact to the Account.
    * @param accounts: Set of Account Ids
    * @return: the Map of the first Contact Id by it's Account Id.
    **/
    private Map<Id, Id> getContactsByAccounts(Set<Id> accounts) {
        Map<Id, Id> contactIdByAccountId = new Map<Id, Id>();
        List<Account> accountsWithContacts = [
            SELECT 
                Id,
                (SELECT Id FROM Contacts LIMIT 1)
            FROM Account
            WHERE Id IN :accounts
        ];
        for (Account acc : accountsWithContacts) {
            if (acc.Contacts.size() > 0) {
                contactIdByAccountId.put(acc.Id, acc.Contacts[0].Id);
            }
        }
        return contactIdByAccountId;
    }

    /**
    * @description Collect the first Pivotal Contact to the Job Application.
    * @param jobAppIds: List of Job Application Ids
    * @return: the Map of the first Pivotal Contact Id by it's Job Application Id.
    **/
    private Map<Id, Id> getPivotalContactByJobApp(Set<Id> jobAppIds) {
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
}