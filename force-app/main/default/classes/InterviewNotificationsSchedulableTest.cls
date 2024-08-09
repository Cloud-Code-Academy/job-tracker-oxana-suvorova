/**
* InterviewNotificationsSchedulableTest class description:
*
* Test class for the Schedulable class InterviewNotificationsSchedulable.
*
**/
@isTest
public with sharing class InterviewNotificationsSchedulableTest {

    public static final String CRON_EXP = '0 0 0 29 6 ? 2045';

    @isTest
    static void testExecute() {

        Test.startTest();
        // Schedule the test job
        InterviewNotificationsSchedulable scheduleJob = new InterviewNotificationsSchedulable();
        String jobId = System.schedule('InterviewNotificationsSchedulable_Test', CRON_EXP, scheduleJob);
        Test.stopTest();

        CronTrigger ct = [
            SELECT 
                Id,
                CronExpression,
                TimesTriggered,
                NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        // Verify cron expressions
        Assert.areEqual(CRON_EXP, ct.CronExpression, 'Cron Expression does not match');
        // Verify the job has not run
        Assert.areEqual(0, ct.TimesTriggered, 'The Job should not be run');
        // Verify next time the job will run
        Assert.areEqual('2045-06-29 00:00:00', String.valueOf(ct.NextFireTime), 'Next fire time does not match');
    }
}