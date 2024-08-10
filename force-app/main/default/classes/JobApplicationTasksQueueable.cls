public class JobApplicationTasksQueueable implements Queueable {

    private List<Job_Application__c> jobApps;
    private Set<String> statusSet = new Set<String>();
    private Map<String, List<Job_Application_Task__mdt>> taskParamsByStatus = new Map<String, List<Job_Application_Task__mdt>>();

    public JobApplicationTasksQueueable(List<Job_Application__c> jobApps, List<String> statuses) {
        this.jobApps = jobApps;
        this.statusSet.addAll(statuses);
    }

    public void execute(QueueableContext context) {
        // Collect Task params to create
        List<Job_Application_Task__mdt> taskParamsToCreate = [
            SELECT 
                Status__c, 
                Priority__c, 
                Days_untill_Due_Date__c, 
                Subject__c 
            FROM Job_Application_Task__mdt 
            WHERE Status__c IN :this.statusSet
        ];

        if (taskParamsToCreate.size() > 0) {
            // Collect Map of Task Params for each Status
            for (Job_Application_Task__mdt tskParam : taskParamsToCreate) {
                if (this.taskParamsByStatus.containsKey(tskParam.Status__c)) {
                    this.taskParamsByStatus.get(tskParam.Status__c).add(tskParam);
                } else {
                    this.taskParamsByStatus.put(tskParam.Status__c, new List<Job_Application_Task__mdt>{tskParam});
                }
            }

            createTasks();
        }
    }

    /**
    * @description Creates Tasks for each Job Application buy Status
    **/
    private void createTasks() {
        List<Task> newTasks = new List<Task>();  
        for (Job_Application__c jobApp : this.jobApps) {
            List<Job_Application_Task__mdt> taskParams = this.taskParamsByStatus.get(jobApp.Status__c);
            for (Job_Application_Task__mdt param : taskParams) {
                Task newTask = new Task();
                newTask.Subject = param.Subject__c;
                newTask.ActivityDate = Date.today().addDays((Integer)param.Days_untill_Due_Date__c);
                newTask.WhatId = jobApp.Id;
                newTask.OwnerId = jobApp.OwnerId;
                newTask.Priority = param.Priority__c;
                newTasks.add(newTask);
            }
        }
        Database.insert(newTasks);
    }
}