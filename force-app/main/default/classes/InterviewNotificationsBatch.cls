/**
* InterviewNotificationsBatch class description:
*
* Defines the Interview notification job that can be broken into smaller batches.
* Sends an email notification to the user before their scheduled interview.
*
**/
public with sharing class InterviewNotificationsBatch implements Database.Batchable<sObject> {
    
    public class MyEmailException extends Exception {}

    private Id templateId;

    public InterviewNotificationsBatch() {
        EmailTemplate emailTemplate = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'InterviewNotification'
            LIMIT 1
        ];
        if (emailTemplate != null) {
            this.templateId = emailTemplate.Id;
        } else {
            throw new MyEmailException('Can not find an email with name InterviewNotification');
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query for all schedueled Interview Events and return the query locator
        return Database.getQueryLocator([
            SELECT
                Id, 
                Subject, 
                Interview_Type__c, 
                Interview_Format__c, 
                Location, 
                Description, 
                Who.Name, 
                Owner.Name, 
                Owner.Email, 
                StartDateTime
            FROM Event
            WHERE RecordType.Name = 'Interview' 
                AND StartDateTime = NEXT_N_DAYS:1
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Event> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Event interview : scope) {
            emails.add(composeEmailMessage(interview));
        }
        if (emails.size() > 0) {
            try {
                Messaging.sendEmail(emails);
            } catch (Exception ex) {
                System.debug('Error sending email: ' + ex.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc) {}

    private Messaging.SingleEmailMessage composeEmailMessage(Event interview) {
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(this.templateId, interview.OwnerId, interview.Id);
        email.setTargetObjectId(interview.OwnerId);
        email.setTreatTargetObjectAsRecipient(true);
        email.setReplyTo('no-reply@manoolk.com');
        email.setSaveAsActivity(false);

        return email;
    }
}