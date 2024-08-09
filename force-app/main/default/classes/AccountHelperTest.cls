/**
* AccountHelperTest class description:
*
* Test class for the class AccountHelper.
*
**/
@isTest
private class AccountHelperTest {

    @testSetup
    static void testData() {
        Account acc = new Account(Name='First Account');
        Database.insert(acc);
    }

    @isTest
    static void testGetContactsByAccounts() {
        // Set test data
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Contact> conts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact cont = new Contact(
                LastName='Test Contact'+i, 
                AccountId=acc.Id
            );
            conts.add(cont);
        }
        Database.insert(conts);

        // Run Test
        Test.startTest();
        Map<Id, Id> contactsByAccounts = AccountHelper.getContactsByAccounts(new Set<Id>{acc.Id});
        Test.stopTest();

        // Assert
        Assert.areEqual(1, contactsByAccounts.size(), 'Expected 1 pair in Map result');
        List<Contact> createdConts = [
            SELECT 
                Id
            FROM Contact
            WHERE AccountId = :acc.Id
        ];
        Assert.areEqual(2, createdConts.size(), 'Expected 2 contacts');
        Set<Id> contIds = (new Map<Id,Contact>(createdConts)).keySet();
        Assert.isTrue(contIds.contains(contactsByAccounts.get(acc.Id)), 'Contact Id should be in created Contacts');
    }

    @isTest 
    static void testGetAccountsByName_withoutCreation() {
        // Set test data
        // Created at first only one Account before test
        Set<String> accNames = new Set<String>{'First Account'};

        // Run Test
        Test.startTest();
        Map<String, Account> accountsByName = AccountHelper.getAccountsByName(accNames);
        Test.stopTest();

        // Assert
        Assert.areEqual(accountsByName.size(), 1, 'Expected 1 pair of Name-Account');
        Assert.areEqual('First Account', accountsByName.get('First Account')?.Name, 'Name of the account expected to be \'First Account\'');
    }

    @isTest 
    static void testGetAccountsByName_withCreation() {
        // Set test data
        // Created at first only one Account before test
        Set<String> accNames = new Set<String>{'First Account', 'Second Account', 'Third Account'};

        // Run Test
        Test.startTest();
        Map<String, Account> accountsByName = AccountHelper.getAccountsByName(accNames);
        Test.stopTest();

        // Assert
        Assert.areEqual(accountsByName.size(), 3, 'Expected 3 pairs of Name-Account');
        for (String name : accNames) {
            Assert.areEqual(name, accountsByName.get(name)?.Name, 'Name of the account should be '+name);
        }
        // Check if there are no extra Accounts
        List<AggregateResult> accCount = [
            SELECT 
                COUNT(Id) numAccs
            FROM Account
            GROUP BY Name
            HAVING COUNT(Id) > 1
        ];
        Assert.isTrue(accCount.isEmpty(), 'Expected no duplicate Accounts');
    }
}