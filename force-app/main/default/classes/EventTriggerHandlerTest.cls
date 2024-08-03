/**
* EventTriggerHandlerTest class description:
*
* Test class for the classes EventTriggerHandler.
*
**/
@isTest
private class EventTriggerHandlerTest {

    @TestSetup
    static void makeTestData(){
        List<Event> events = new List<Event>();
        Date evDate = Date.today().addDays(1);
        Time evTime = Time.newInstance(12, 0, 0, 0);
        for (Integer i = 0; i < 2; i++) {
            events.add(new Event(
                Subject = 'Test event ' + i,
                StartDateTime = Datetime.newInstance(evDate, evTime.addHours(i * 3)),
                EndDateTime = Datetime.newInstance(evDate, evTime.addHours(i * 3 + 1))
            ));
        }
        Database.insert(events);
    }

    @isTest
    static void testBeforeInsert_CheckOverlapingTimePositive() {
        // Set test data
        Date newDate = Date.today().addDays(1);
        Time newTime = Time.newInstance(13, 30, 0, 0);
        Event newEvent = new Event(
            Subject = 'New Test Event',
            StartDateTime = Datetime.newInstance(newDate, newTime),
            EndDateTime = Datetime.newInstance(newDate, newTime.addHours(1))
        );

        // Run Test
        Test.startTest();
        Database.insert(newEvent);
        Test.stopTest();

        // Assert
        List<Event> addedEvent = [
            SELECT 
                Id,
                Subject
            FROM Event
            WHERE Subject = 'New Test Event'
        ];
        Assert.areEqual(1, addedEvent.size(), 'Expected to get inserted Event with Subject \'New Test Event\'');
    }

    @isTest
    static void testBeforeUpdate_CheckOverlapingTimePositive() {
        // Get test data
        Event event = [
            SELECT 
                Id,
                Subject,
                StartDateTime
            FROM Event
            WHERE Subject = 'Test event 1'
            LIMIT 1
        ];
        Datetime oldStartDate = event.StartDateTime;
        event.StartDateTime = event.StartDateTime.addHours(-1);

        // Run Test
        Test.startTest();
        Database.update(event);
        Test.stopTest();

        // Assert
        Event updatedEvent = [
            SELECT 
                Id,
                Subject,
                StartDateTime
            FROM Event
            WHERE Id = :event.Id
        ];
        Assert.areNotEqual(oldStartDate, updatedEvent.StartDateTime, 'Expected to get updated StartDateTime');
    }

    @isTest
    static void testBeforeInsert_CheckOverlapingTimeNegative() {
        // Set test data
        Date newDate = Date.today().addDays(1);
        Time newTime = Time.newInstance(12, 30, 0, 0);
        Event newEvent = new Event(
            Subject = 'New Test Event',
            StartDateTime = Datetime.newInstance(newDate, newTime),
            EndDateTime = Datetime.newInstance(newDate, newTime.addHours(1))
        );

        // Run Test
        String exMessage = '';
        Test.startTest();
        try {
            Database.insert(newEvent);
        } catch (Exception ex) {
            exMessage = ex.getMessage();
        }
        Test.stopTest();

        // Assert
        List<Event> addedEvent = [
            SELECT 
                Id,
                Subject
            FROM Event
            WHERE Subject = 'New Test Event'
        ];
        Assert.areEqual(0, addedEvent.size(), 'Event with Subject \'New Test Event\' should not be inserted');
        Assert.isTrue(exMessage.contains('The time of this event overlaps with an earlier scheduled Event'), 'Error message does not match');
    }

    @isTest
    static void testBeforeUpdate_CheckOverlapingTimeNegative() {
        // Get test data
        Event event = [
            SELECT 
                Id,
                Subject,
                StartDateTime
            FROM Event
            WHERE Subject = 'Test event 1'
            LIMIT 1
        ];
        Datetime oldStartDate = event.StartDateTime;
        event.StartDateTime = event.StartDateTime.addHours(-2);

        // Run Test
        String exMessage = '';
        Test.startTest();
        try {
            Database.update(event);
        } catch (Exception ex) {
            exMessage = ex.getMessage();
        }
        Test.stopTest();

        // Assert
        Event updatedEvent = [
            SELECT 
                Id,
                Subject,
                StartDateTime
            FROM Event
            WHERE Id = :event.Id
        ];
        Assert.areEqual(oldStartDate, updatedEvent.StartDateTime, 'Expected to get unchanged StartDateTime');
        Assert.isTrue(exMessage.contains('The time of this event overlaps with an earlier scheduled Event'), 'Error message does not match');
    }
}