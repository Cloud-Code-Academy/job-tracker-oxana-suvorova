/**
* InterviewNotificationsBatch class description:
*
* Defines the Interview notification job that can be broken into smaller batches.
* Sends an email notification to the user before their scheduled interview.
*
**/
public class InterviewNotificationsBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public class MyEmailException extends Exception {}

    @TestVisible
    private Id templateId;
    @TestVisible
    private Integer emailsSent = 0;
    @TestVisible
    static Integer testEmailsSent;

    public InterviewNotificationsBatch() {
        EmailTemplate emailTemplate = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'InterviewNotification'
            LIMIT 1
        ];
        // As the classic template exist in the project I don't need to try/catch
        this.templateId = emailTemplate.Id;
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
            List<Messaging.SendEmailResult> sendEmailRes = Messaging.sendEmail(emails);
            for (Messaging.SendEmailResult emailRes : sendEmailRes) {
                If (emailRes.isSuccess()) {
                    emailsSent = emailsSent + 1;
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        testEmailsSent = emailsSent;
    }

    @TestVisible
    private Messaging.SingleEmailMessage composeEmailMessage(Event interview) {
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(this.templateId, interview.OwnerId, interview.Id);
        email.setTargetObjectId(interview.OwnerId);
        email.setTreatTargetObjectAsRecipient(true);
        email.setReplyTo('no-reply@manoolk.com');
        email.setSaveAsActivity(false);

        return email;
    }
}