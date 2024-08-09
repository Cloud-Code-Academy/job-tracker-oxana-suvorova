/**
* JobApplicationTriggerHandlerHelperTest class description:
*
* Test class for the classes JobApplicationTriggerHandler and JobApplicationHelper.
*
**/
@isTest
private class JobApplicationTriggerHandlerHelperTest {

    @TestSetup
    static void makeTestData(){
        Account acc = TestDataFactory.createAccount();
        List<Contact> conts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact cont = new Contact(
                LastName='Test Contact '+i, 
                AccountId=acc.Id
                );
                conts.add(cont);
            }
        Database.insert(conts);
        TestDataFactory.createJobApplication(acc);
    }

    @isTest
    static void testBeforeInsertSetCompanyContactAsPrimaryContact() {
        // Test data were created
        // Assert
        Job_Application__c insertedJobApp = [
            SELECT 
                Id,
                Primary_Contact__c,
                Primary_Contact__r.Name
            FROM Job_Application__c 
            LIMIT 1
        ];
        Id insertedContId = insertedJobApp.Primary_Contact__c;
        Assert.isNotNull(insertedContId, 'Primary Contact should not be Null');
        Assert.areEqual('Test Contact 0', insertedJobApp.Primary_Contact__r.Name, 'Expected to get the first Contact (sorted by Name)');
    }

    @isTest
    static void testBeforeUpdateSetCompanyContactAsPrimaryContact() {
        // Set up test data
        Job_Application__c jobApp = [
            SELECT 
                Id,
                Primary_Contact__c,
                Description__c
            FROM Job_Application__c 
            LIMIT 1
        ];
        
        // Run Test
        Test.startTest();
        jobApp.Primary_Contact__c = null;
        jobApp.Description__c = 'Primary Contact Was Deleted';
        Database.update(jobApp);
        Test.stopTest();

        // Assert
        Job_Application__c updatedJobApp = [
            SELECT 
                Id,
                Primary_Contact__c,
                Description__c
            FROM Job_Application__c 
            WHERE Id = :jobApp.Id
        ];
        Id updatedContId = updatedJobApp.Primary_Contact__c;
        Assert.isNotNull(updatedContId, 'Primary Contact should not be Null');
        Assert.areEqual('Primary Contact Was Deleted', updatedJobApp.Description__c, 'Descriptions should be updated.');
        Contact resCont = [
            SELECT
                Id,
                Name
            FROM Contact
            WHERE Id = :updatedContId
        ];
        Assert.areEqual('Test Contact 0', resCont.Name, 'Expected to get the first Contact (sorted by Name)');
    }

    @isTest
    static void testBeforeUpdateSetPivotalContactAsPrimaryContact() {
        // Set up test data
        Job_Application__c jobApp = [
            SELECT 
                Id,
                Primary_Contact__c,
                Description__c
            FROM Job_Application__c 
            LIMIT 1
        ];
        List<Contact> conts = [SELECT Id FROM Contact];
        List<Pivotal_Contact__c> pivConts = new List<Pivotal_Contact__c>();
        for (Contact cont : conts) {
            Pivotal_Contact__c pivCont = new Pivotal_Contact__c(
                Job_Application__c = jobApp.Id,
                Contact__c = cont.Id
            );
            pivConts.add(pivCont);
        }
        Database.insert(pivConts);
        
        // Run Test
        Test.startTest();
        jobApp.Primary_Contact__c = null;
        jobApp.Description__c = 'Primary Contact Was Deleted';
        Database.update(jobApp);
        Test.stopTest();

        // Assert
        Job_Application__c updatedJobApp = [
            SELECT 
                Id,
                Primary_Contact__c,
                Description__c
            FROM Job_Application__c 
            WHERE Id = :jobApp.Id
        ];
        Id updatedContId = updatedJobApp.Primary_Contact__c;
        Assert.isNotNull(updatedContId, 'Primary Contact should not be Null');
        Assert.areEqual('Primary Contact Was Deleted', updatedJobApp.Description__c, 'Descriptions should be updated.');
        Pivotal_Contact__c resCont = [
            SELECT 
                Contact__r.Name
            FROM Pivotal_Contact__c
            WHERE Job_Application__c = :updatedJobApp.Id
                AND Contact__c = :updatedContId
            ORDER BY Name ASC 
            LIMIT 1
        ];
        Assert.areEqual('Test Contact 0', resCont.Contact__r.Name, 'Expected to get the first Contact (sorted by Name)');
    }
}