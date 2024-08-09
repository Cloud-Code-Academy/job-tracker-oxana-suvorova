/**
* JoobleJobBoardControllerTest class description:
*
* Test class for the classes JoobleJobBoardController.
*
**/
@isTest
private class JoobleJobBoardControllerTest {

    @isTest
    static void testGetNewJobPositions() {
        // Set test data
        Test.setMock(HttpCalloutMock.class, new JoobleJobBoardCalloutMock());
        Map<String, Object> paramsMap = new Map<String, Object>();
        paramsMap.put('keywords', 'salesforce developer');
        paramsMap.put('location', 'Boston');
        paramsMap.put('datecreatedfrom', Datetime.newInstance(2024, 7, 1));

        // Run test
        Test.startTest();
        List<JoobleWrapper.JoobleJob> searchResult = JoobleJobBoardController.getNewJobPositions(paramsMap);
        Test.stopTest();

        // Assert
        Assert.areEqual(1, searchResult.size(), 'Expected to get 1 Job position after callout');
        JoobleWrapper.JoobleJob sJob = searchResult[0];
        Assert.isNotNull(sJob.company, 'Company value should not be Null');
        Assert.isNotNull(sJob.id, 'Id value should not be Null');
        Assert.isNotNull(sJob.link, 'Link value should not be Null');
        Assert.isNotNull(sJob.location, 'Location value should not be Null');
        Assert.isNotNull(sJob.snippet, 'Snippet (description) value should not be Null');
        Assert.isNotNull(sJob.salary, 'Salary value should not be Null');
        Assert.isNotNull(sJob.source, 'Source value should not be Null');
        Assert.isNotNull(sJob.title, 'Title value should not be Null');
        Assert.isNotNull(sJob.type, 'Type value should not be Null');
        Assert.isNotNull(sJob.updated, 'Updated date value should not be Null');
    }

    @isTest
    static void testGetNewJobPositions_CatchException() {
        // Set test data
        Test.setMock(HttpCalloutMock.class, new JoobleJobBoardCalloutMockBadResponse());
        Map<String, Object> paramsMap = new Map<String, Object>();
        paramsMap.put('keywords', '');
        paramsMap.put('location', '');
        String exType;

        // Run test
        Test.startTest();
        try {
            List<JoobleWrapper.JoobleJob> searchResult = JoobleJobBoardController.getNewJobPositions(paramsMap);
        } catch (Exception ex) {
            exType = ex.getTypeName();
        }
        Test.stopTest();

        // Assert
        Assert.areEqual('System.AuraHandledException', exType, 'Expected to get thrown AuraHandledException');
    }

    @isTest
    static void testSaveNewJobPositions() {
        // Set test Data
        List<JoobleWrapper.JoobleJob> newJobs = new List<JoobleWrapper.JoobleJob>();
        for (Integer i = 0; i < 5; i++) {
            JoobleWrapper.JoobleJob job = new JoobleWrapper.JoobleJob();
            job.company = 'Test Company';
            job.id = '74281858086593410'+i;
            job.link = 'http://google.com/item'+i;
            job.location = 'Boston, MA';
            job.salary = '100000';
            job.snippet = 'Test description';
            job.source = 'jooble.com';
            job.title = 'Test Title';
            job.type = 'Remote';
            job.updated = Datetime.newInstance(2024, 7, 1, 0, 0, 0);
            newJobs.add(job);
        }
        // Clear the company in the first item of the list
        newJobs[0].company = '';
        // Create user with edit permissions
        User stdUser = TestDataFactory.createUser('stuser');
        PermissionSet ps = [
            SELECT 
                Id 
            FROM PermissionSet 
            WHERE Name = 'Job_Application_Tracker_Permissions'
        ];
        Database.insert(new PermissionSetAssignment(AssigneeId = stdUser.Id, PermissionSetId = ps.Id));

        // Run Test
        Test.startTest();
        System.runAs(stdUser) {
            JoobleJobBoardController.saveNewJobPositions(newJobs);
        }
        Test.stopTest();

        // Assert
        List<Job_Application__c> createdJobApps = [
            SELECT
                Id,
                Position_Title__c,
                Location__c,
                Description__c,
                Salary_Info__c,
                URL__c,
                Jooble_Id__c,
                Company_Name__r.Name
            FROM Job_Application__c
        ];
        Assert.areEqual(5, createdJobApps.size(), 'Expected to get 5 Job Application records');
        for (Job_Application__c jobApp : createdJobApps) {
            if (jobApp.Jooble_Id__c == '742818580865934100') {
                Assert.areEqual('Default Empty Company', jobApp.Company_Name__r.Name, 'When company is empty value expected to get Default Empty Company Account');
            } else {
                Assert.areEqual('Test Company', jobApp.Company_Name__r.Name, 'Expected to get Test Company Account');
            }
            Assert.areEqual('Test Title', jobApp.Position_Title__c, 'Position title does not match');
            Assert.areEqual('Boston, MA', jobApp.Location__c, 'Location does not match');
            Assert.areEqual('100000', jobApp.Salary_Info__c, 'Salary info does not match');
            Assert.areEqual('http://google.com/item', jobApp.URL__c.left(22), 'URL link does not match');
        }
    }

    @isTest
    static void testSaveNewJobPositions_SecurityExseption() {
        // Set test Data
        List<JoobleWrapper.JoobleJob> newJobs = new List<JoobleWrapper.JoobleJob>();
        JoobleWrapper.JoobleJob job = new JoobleWrapper.JoobleJob();
        job.company = 'Test Company';
        job.id = '742818580865934100';
        job.link = 'http://google.com/item';
        job.location = 'Boston, MA';
        job.salary = '100000';
        job.snippet = 'Test description';
        job.source = 'jooble.com';
        job.title = 'Test Title';
        job.type = 'Remote';
        job.updated = Datetime.newInstance(2024, 7, 1, 0, 0, 0);
        newJobs.add(job);

        // Create user without edit permissions
        User stdUser = TestDataFactory.createUser('stuser');

        // Run Test
        Test.startTest();
        try {
            System.runAs(stdUser) {
                JoobleJobBoardController.saveNewJobPositions(newJobs);
            }
        } catch (Exception ex) {
            // Assert
            Assert.areEqual('System.SecurityException', ex.getTypeName(), 'Expected to get thrown SecurityException');
            Assert.areEqual('Insufficient permissions to create Job Applications', ex.getMessage(), 'Exception messages do not match');
        }
        Test.stopTest();
    }
}