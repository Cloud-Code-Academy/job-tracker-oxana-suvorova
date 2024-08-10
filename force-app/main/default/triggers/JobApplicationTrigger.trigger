trigger JobApplicationTrigger on Job_application__c (before insert, before update, after insert, after update) {
    new JobApplicationTriggerHandler().run();
}