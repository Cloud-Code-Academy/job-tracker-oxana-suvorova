/**
 * TestDataFactory contain methods that can be called by test methods to perform useful tasks
 */
@isTest
public with sharing class TestDataFactory {

    /**
     * Get Profile
     */
    public static Profile getProfile(String name) {
        return [
            SELECT 
                Id
            FROM Profile
            WHERE Name = :name
            LIMIT 1
        ];
    }

    /**
     * Create User
     */
    public static User createUser(String alias) {
        Profile profile = getProfile('Standard User');
        User newUser = new User();
        newUser.Alias = alias;
        newUser.Email = 'mail.suvorova.o@gmail.com';//alias + '@testjobapp.com';
        newUser.LastName = 'Testing';
        newUser.ProfileId = profile.Id;
        newUser.Username = alias + '@testjobapp.com';
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.LocaleSidKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        Database.insert(newUser);

        return newUser;
    }

    /**
     * Create Event (Interview)
     */
    public static void createEvents(Integer numEvents, User user, Integer daysAfterToday) {
        List<Event> events = new List<Event>();

        // Get record type
        Schema.DescribeSObjectResult dEvent = Schema.SObjectType.Event;
        Map<String, Schema.RecordTypeInfo> rtByName = dEvent.getRecordTypeInfosByName();
        Id rtId = rtByName.get('Interview').getRecordTypeId();

        Date eventDate = Date.today().addDays(daysAfterToday);
        Datetime startDate = Datetime.newInstance(eventDate, Time.newInstance(9, 0, 0, 0));
        // Create Events
        for (Integer i = 0; i < numEvents; i++) {
            Event newEvent = new Event();
            newEvent.RecordTypeId = rtId;
            newEvent.Subject = 'Test Interview '+i;
            newEvent.StartDateTime = startDate.addHours(i);
            newEvent.EndDateTime = newEvent.StartDateTime.addHours(1);
            newEvent.OwnerId = user.Id;
            events.add(newEvent);
        }

        Database.insert(events);
    }

    /**
     * Create Account (Company for Job Application)
     * @return: Created Account
     */
    public static Account createAccount() {
        Account acc = new Account(Name='Test Account');
        Database.insert(acc);

        return acc;
    }

    /**
     * Create Job Application
     * @param acc: Account as a Company
     * @return: Created Job Application
     */
    public static Job_Application__c createJobApplication(Account acc) {
        User stUser = [SELECT Id FROM User LIMIT 1];
        if (stUser == null) {
            stUser = createUser('stuser');
        }

        Job_Application__c jobApp = new Job_Application__c(
            Position_Title__c = 'Test Position',
            Company_Name__c = acc.Id,
            OwnerId = stUser.Id
        );
        Database.insert(jobApp);

        return jobApp;
    }
}