/**
* TakeHomePayEstimatorControllerTest class description:
*
* Test class for the classes TakeHomePayEstimatorController.
*
**/
@isTest
private class TakeHomePayEstimatorControllerTest {

    @isTest
    static void testGetTaxDeduction() {
        // Set test data
        Decimal taxDeduction;
        User stdUser = TestDataFactory.createUser('stuser');

        // Run test
        System.runAs(stdUser) {
            taxDeduction = TakeHomePayEstimatorController.getTaxDeduction('Single');
        }
        Assert.areEqual(14600.00, taxDeduction, 'Tax deduction does not match');
    }

    @isTest
    static void testgetTaxBrackets() {
        // Run Test
        Test.startTest();
        List<Federal_Tax_Bracket__mdt> taxBrackets = TakeHomePayEstimatorController.getTaxBrackets('Single');
        Test.stopTest();

        // Assert
        Assert.areEqual(7, taxBrackets.size(), 'Expected to get 7 Federal Tax Brackets');
    }

    @isTest
    static void testGetTaxesAndPayChecks() {
        // Set test data
        TakeHomePayWrapper wrapper = new TakeHomePayWrapper();
        wrapper.annualIncome = 100000.00;
        wrapper.filingStatus = 'Single';
        wrapper.taxableIncome = 85400.00;

        // Run Test
        Test.startTest();
        Map<String, Decimal> otherTaxes = TakeHomePayEstimatorController.getTaxesAndPayChecks(wrapper);
        Test.stopTest();

        // Assert
        Assert.areEqual(3, otherTaxes.size(), 'Expected to get 3 records of calculated taxes');
        // Assert calculated numbers
        Assert.areEqual(13840.78, otherTaxes.get('federalTaxValue'), 'Incorrect Federal Tax Value for the Single filing status');
        Assert.areEqual(1450.00, otherTaxes.get('medicare'), 'Incorrect Medicare Value for the Single filing status');
        Assert.areEqual(6200.00, otherTaxes.get('socialSecurity'), 'Incorrect Social Security Value');
    }

    @isTest
    static void testGetTaxesAndPayChecks_CheckSocialSecurity() {
        // Set test data
        TakeHomePayWrapper wrapper = new TakeHomePayWrapper();
        wrapper.annualIncome = 200000.00;
        wrapper.filingStatus = 'Single';
        wrapper.taxableIncome = 185400.00;

        // Run Test
        Test.startTest();
        Map<String, Decimal> otherTaxes = TakeHomePayEstimatorController.getTaxesAndPayChecks(wrapper);
        Test.stopTest();

        // Assert
        Assert.areEqual(3, otherTaxes.size(), 'Expected to get 3 records of calculated taxes');
        // Assert calculated numbers
        Assert.areEqual(10453.20, otherTaxes.get('socialSecurity'), 'Incorrect Social Security Value');
    }

    @isTest
    static void testupdateJobApplication() {
        // Set test data
        String filingStatus = 'Single';
        TakeHomePayWrapper wrapper = new TakeHomePayWrapper();
        wrapper.federalTaxValue = 13840.78;
        wrapper.socialSecurity = 6200.00;
        wrapper.medicare = 1450.00;
        wrapper.annualPaycheck = 78509.22;
        wrapper.monthlyPaycheck = 6542.44;
        Account acc = TestDataFactory.createAccount();
        Job_Application__c jobApp = TestDataFactory.createJobApplication(acc);
        
        // Run test
        Test.startTest();
        TakeHomePayEstimatorController.updateJobApplication(jobApp.Id, wrapper, filingStatus);
        Test.stopTest();

        // Assert
        Job_Application__c updatedJobApp = [
            SELECT
                Id,
                Federal_Income_Tax__c,
                Social_Security__c,
                Medicare_Withholding__c,
                Annual_Take_home_Pay__c,
                Monthly_Take_home_Pay__c,
                Filing_status__c
            FROM Job_Application__c
            WHERE Id = :jobApp.Id
        ];
        Assert.areEqual(wrapper.federalTaxValue, updatedJobApp.Federal_Income_Tax__c, 'Federal Tax Value does not match');
        Assert.areEqual(wrapper.socialSecurity, updatedJobApp.Social_Security__c, 'Social Security Tax Value does not match');
        Assert.areEqual(wrapper.medicare, updatedJobApp.Medicare_Withholding__c, 'Federal Tax Value does not match');
        Assert.areEqual(wrapper.annualPaycheck, updatedJobApp.Annual_Take_home_Pay__c, 'Federal Tax Value does not match');
        Assert.areEqual(wrapper.monthlyPaycheck, updatedJobApp.Monthly_Take_home_Pay__c, 'Federal Tax Value does not match');
        Assert.areEqual(filingStatus, updatedJobApp.Filing_status__c, 'Federal Tax Value does not match');
    }

    @isTest
    static void testupdateJobApplication_Exception() {
        // Set test data
        String filingStatus = 'Single';
        TakeHomePayWrapper wrapper = new TakeHomePayWrapper();
        wrapper.federalTaxValue = 13840.78;
        wrapper.socialSecurity = 6200.00;
        wrapper.medicare = 1450.00;
        wrapper.annualPaycheck = 78509.22;
        wrapper.monthlyPaycheck = 6542.44;
        Account acc = TestDataFactory.createAccount();
        Job_Application__c jobApp = TestDataFactory.createJobApplication(acc);
        User unauthUser = TestDataFactory.createUser('uauser');
        
        // Run test
        Test.startTest();
        try {
            System.runAs(unauthUser) {
                TakeHomePayEstimatorController.updateJobApplication(jobApp.Id, wrapper, filingStatus);
            } 
        } catch (Exception ex) {
            // Assert
            Assert.areEqual('System.AuraHandledException', ex.getTypeName(), 'Expected to get thrown AuraHandledException');
            Assert.areEqual('You can not update Job Application record', ex.getMessage(), 'Exception messages do not match');
        }
        Test.stopTest();
    }
}