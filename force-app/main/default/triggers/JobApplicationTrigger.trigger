trigger JobApplicationTrigger on Job_application__c (before insert, before update) {
    new JobApplicationTriggerHandler().run();
}