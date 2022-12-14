/**
 * @Who     Platform Team - Customer Org <adam.walker1@bp.com>
 * @when    10-04-2018
 * @what    The Generic Trigger Handler for the Event. Please add your product specific handler this class
 *          If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
 **/
public class EventTriggerHandler {

    private final List<Event> newRecords;
    private final List<Event> oldRecords;
    private final Map<Id, Event> newMap;
    private final Map<Id, Event> oldMap;

    public EventTriggerHandler(List<Event> newRecords, List<Event> oldRecords, Map<Id, Event> newMap, Map<Id,Event> oldMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newMap     = newMap;
        this.oldMap     = oldMap;
    }

    public void handleBeforeInsert() {
      
    }
    
    public void handleAfterInsert() {
        new CASFO_AccountLastMeetingActivity().startUpdate(newRecords, oldMap);
        new CAJBP_EventTriggerHandler(this.newRecords, this.oldRecords).handleAfterInsert();
    }

    public void handleBeforeUpdate() {

    }
   
    public void handleAfterUpdate() {
        new CASFO_AccountLastMeetingActivity().startUpdate(newRecords, oldMap);
        new CAJBP_EventTriggerHandler(this.newRecords, this.oldRecords).handleAfterUpdate();
    }

    public void handleBeforeDelete() {
        new CASFO_QBREventDeleted().updateAccountWhenQBRDeleted(oldRecords);
    }
    
    public void handleAfterDelete() {
        new CAJBP_EventTriggerHandler(this.newRecords, this.oldRecords).handleAfterDelete();
    }
}