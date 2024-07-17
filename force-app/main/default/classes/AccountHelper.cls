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
    
}