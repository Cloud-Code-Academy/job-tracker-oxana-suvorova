public with sharing class AccountHelper {

    /**
    * @description Collect the first related Contact to the Account.
    * @param accounts: Set of Account Ids
    * @return: the Map of the first Contact Id by it's Account Id.
    **/
    public static Map<Id, Id> getContactsByAccounts(Set<Id> accounts) {
        Map<Id, Id> contactIdByAccountId = new Map<Id, Id>();
        List<Account> accountsWithContacts = [
            SELECT 
                Id,
                (SELECT Id FROM Contacts LIMIT 1)
            FROM Account
            WHERE Id IN :accounts
        ];
        for (Account acc : accountsWithContacts) {
            if (acc.Contacts.size() > 0) {
                contactIdByAccountId.put(acc.Id, acc.Contacts[0].Id);
            }
        }
        return contactIdByAccountId;
    }
    
    /**
    * @description Collect Accounts by name. If Account does not exist, create it.
    * @param accNames: Set of Account Names
    * @return: the Map of the Account by it's Name.
    **/
    public static Map<String, Account> getAccountsByName(Set<String> accNames) {
        Map<String, Account> accountsByName = new Map<String, Account>();
        List<Account> accounts = [
            SELECT 
                Id,
                Name
            FROM Account
            WHERE Name IN :accNames
        ];
        // Add existing Accounts
        for (Account acc : accounts) {
            accountsByName.put(acc.Name, acc);
        }
        // Check and create new Accounts
        Set<String> accountsKeys = accountsByName.keySet();
        if (accountsKeys.containsAll(accNames)) {
            // return Accounts Map if we have all names
            return accountsByName;
        }
        List<Account> newAccs = new List<Account>();
        Set<String> tempNameSet = new Set<String>(accNames);
        tempNameSet.removeAll(accountsKeys);
        for (String name : tempNameSet) {
            Account acc = new Account(Name=name);
            accountsByName.put(name, acc);
            newAccs.add(acc);
        }
        if (newAccs.size() > 0) {
            Database.insert(newAccs);
        }

        return accountsByName;
    }
}