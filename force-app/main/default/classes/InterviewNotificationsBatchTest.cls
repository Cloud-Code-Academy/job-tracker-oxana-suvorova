/**
* InterviewNotificationsBatchTest class description:
*
* Test class for the class InterviewNotificationsBatch.
*
**/
@isTest
private class InterviewNotificationsBatchTest {

    @isTest
    static void testBatchConstructor() {
        // Run Test
        Test.startTest();
        InterviewNotificationsBatch newBatch = new InterviewNotificationsBatch();
        Test.stopTest();

        // Assert
        Assert.isNotNull(newBatch.templateId, 'Private variable templateId is expected to be not Null');
    }

    @isTest
    static void testBatchable_completesSuccessfully() {
        // Run Test
        Test.startTest();
        Id batchId = Database.executeBatch(new InterviewNotificationsBatch());
        Test.stopTest();

        // Assert
        // Batchable Job was completed
        AsyncApexJob apexJob = [
            SELECT 
                JobType,
                Status
            FROM AsyncApexJob
            WHERE Id = :batchId
        ];
        Assert.areEqual('BatchApex', apexJob.JobType, 'Expected to get BatchApex Job');
        Assert.areEqual('Completed', apexJob.Status, 'Expected that BatchApex Job completes successfully');
    }

    @isTest
    static void testComposeEmailMessage() {
        // Create test User and Event
        User stUser = TestDataFactory.createUser('stuser');
        TestDataFactory.createEvents(1, stUser, 1);
        Event createdEvent = [
            SELECT 
                Id,
                OwnerId
            FROM Event
            WHERE OwnerId = :stUser.Id
            LIMIT 1
        ];

        // Run test
        Test.startTest();
        InterviewNotificationsBatch newBatch = new InterviewNotificationsBatch();
        Messaging.SingleEmailMessage emailMessage = newBatch.composeEmailMessage(createdEvent);
        Test.stopTest();

        // Assert
        Assert.areEqual('InterviewNotification', emailMessage.getTemplateName(), 'Expected Email Template Name is InterviewNotification');
        Assert.areEqual('no-reply@manoolk.com', emailMessage.getReplyTo(), 'Expected replyTo email does not match');
        Assert.areEqual(stUser.Id, emailMessage.getTargetObjectId(), 'Target Object Id does not match');
    }

    @isTest
    static void testBatchable_EmailsSent() {
        // Create test User and 5 Events
        User stUser = TestDataFactory.createUser('stuser');
        // 5 events for the next day
        TestDataFactory.createEvents(5, stUser, 1);
        TestDataFactory.createEvents(5, stUser, 3);

        // Run Test
        Test.startTest();
        InterviewNotificationsBatch newBatch = new InterviewNotificationsBatch();
        Id batchId = Database.executeBatch(newBatch);
        Test.stopTest();

        Assert.areEqual(5, InterviewNotificationsBatch.testEmailsSent, 'Expected to send 5 emails');
    }
}