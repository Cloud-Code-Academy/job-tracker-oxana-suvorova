public with sharing class EventTriggerHandler extends TriggerHandler {

    private List<Event> newEvents;

    /**
     * Constructor. Set instance variables.
     */
    public EventTriggerHandler() {
        this.newEvents = (List<Event>) Trigger.new;
    }

    /**
    * @description Before Insert method.
    **/
    public override void beforeInsert() {
        beforeInsertUpdate();
    }

    /**
    * @description Before Update method.
    **/
    public override void beforeUpdate() {
        beforeInsertUpdate();
    }

    /**
    * @description Before Insert/Update method.
    **/
    private void beforeInsertUpdate() {
        // Get already Scheduled Events
        List<Event> existedEvents = [
            SELECT 
                Id,
                StartDateTime,
                EndDateTime
            FROM Event
            WHERE Id NOT IN :this.newEvents
        ];

        // Check new/updated Events time don't overlap with existing Events time
        if (existedEvents.size() == 0) {
            return;
        }
        for (Event newEvent : newEvents) {
            Long startTime = newEvent.StartDateTime.getTime();
            Long endTime = newEvent.EndDateTime.getTime();
            for (Event exEvent : existedEvents) {
                // Check overlaping
                if ((startTime >= exEvent.StartDateTime.getTime() && startTime <= exEvent.EndDateTime.getTime()) ||
                    (endTime >= exEvent.StartDateTime.getTime() && endTime <= exEvent.EndDateTime.getTime())) {
                    
                    newEvent.addError('The time of this event overlaps with an earlier scheduled Event');
                }
            }
        }
    }
}