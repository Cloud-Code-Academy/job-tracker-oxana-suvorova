/**
* InterviewNotificationsBatchTest class description:
*
* Test class for the class InterviewNotificationsBatch.
*
**/
@isTest
private class JobApplicationTasksQueueableTest {

    @isTest
    static void testAddTasksByQueueableJob() {
        Account acc = TestDataFactory.createAccount();
        
        // Run Test
        Test.startTest();
        // Queueable Class runs by AfterInsert Trigger
        Job_Application__c jobApp = TestDataFactory.createJobApplication(acc);
        Test.stopTest();

        // Assert
        List<AsyncApexJob> apexJobs = [
            SELECT 
                Id 
            FROM AsyncApexJob
            WHERE JobType = 'Queueable'
        ];
        Assert.areEqual(1, apexJobs.size(), 'Expected 1 Queueable Job was run');
        // Validate that the job has run by verifying that the record was created.
        List<Task> createdTasks = [
            SELECT 
                Id,
                WhatId
            FROM Task
            WHERE WhatId = :jobApp.Id
        ];
        List<Job_Application_Task__mdt> taskParamsToCreate = [
            SELECT
                Id,
                Status__c 
            FROM Job_Application_Task__mdt 
            WHERE Status__c = 'Saved'
        ];
        Assert.areEqual(taskParamsToCreate.size(), createdTasks.size(), 'The number of created tasks must match the number of task params for the status');
    } 
}