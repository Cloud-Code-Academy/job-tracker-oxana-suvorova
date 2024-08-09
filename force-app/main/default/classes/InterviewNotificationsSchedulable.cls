/**
* InterviewNotificationsSchedulable class description:
*
* Helps to run the Interview notification Batchable job at specific times.
*
**/
public with sharing class InterviewNotificationsSchedulable implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new InterviewNotificationsBatch(), 20);
    }
}