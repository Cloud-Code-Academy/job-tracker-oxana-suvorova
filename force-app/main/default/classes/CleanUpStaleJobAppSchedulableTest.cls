/**
* CleanUpStaleJobAppSchedulableTest class description:
*
* Test class for the class CleanUpStaleJobApplicationsSchedulable.
*
**/
@isTest
private class CleanUpStaleJobAppSchedulableTest {

    @TestSetup
    static void makeTestData(){
        Account acc = TestDataFactory.createAccount();
        User stUser = TestDataFactory.createUser('stuser');
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        for (Integer i = 0; i < 5; i++) {
            String status = 'Saved';
            if (i == 4) {
                status = 'Accepted';
            }
            jobApps.add(new Job_Application__c(
                Position_Title__c = 'Test Position ' + i,
                Company_Name__c = acc.Id,
                OwnerId = stUser.Id,
                Follow_up_date__c = Date.today().addDays(-10 * i),
                Status__c = status
            ));
        }
        Database.insert(jobApps);
    }

    @isTest
    static void testStaleJobApps() {
        // Run test
        Test.startTest();
        CleanUpStaleJobApplicationsSchedulable scheduleJob = new CleanUpStaleJobApplicationsSchedulable();
        String year = String.valueOf(Date.today().addYears(1).year());
        String cronExp = '0 0 1 * * ? ' + year;
        System.schedule(
            'CleanUpStaleJobApplications', cronExp, scheduleJob
        );
        scheduleJob.execute(null);
        Test.stopTest();

        // Assert
        List<Job_Application__c> jobApps = [
            SELECT 
                Id,
                Position_Title__c,
                Follow_up_date__c,
                Status__c,
                Notes__c
            FROM Job_Application__c
        ];
        Assert.areEqual(5, jobApps.size(), 'Expected to get 5 Job Application records');
        for (Job_Application__c jobApp : jobApps) {
            if (jobApp.Position_Title__c == 'Test Position 3') {
                Assert.areEqual('Closed', jobApp.Status__c, 'Status should be changed to Closed');
                Assert.areEqual('The job application was closed by an automated process!', jobApp.Notes__c, 'Notes should be correctly populated');
            } else {
                Assert.isFalse(jobApp.Status__c == 'Closed', 'Status of not stale Job Apps and Accepted Job Apps should not be changed');
                Assert.isNull(jobApp.Notes__c, 'Notes should not be populated');
            }
        }
    }
}