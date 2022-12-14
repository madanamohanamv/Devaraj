/**
 * @Who     Maros Zilka
 * @when    10-04-2018
 * @what    The Generic Trigger on Event. Please add your product specific handler into the EventTriggerHandler.cls
 *          If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
 **/

trigger EventTrigger on Event (before insert, after insert, before update, after update, before delete, after delete) {
    EventTriggerHandler handler = new EventTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    if(Trigger.isBefore && Trigger.isInsert) {
        handler.handleBeforeInsert();
    }
    else if(Trigger.isAfter && Trigger.isInsert) {
        handler.handleAfterInsert();
    }
    else if(Trigger.isBefore && Trigger.isUpdate) {
        handler.handleBeforeUpdate();
    }
    else if(Trigger.isAfter && Trigger.isUpdate) {
        handler.handleAfterUpdate();
    }
    else if(Trigger.isBefore && Trigger.isDelete) {
        handler.handleBeforeDelete();
    }
    else if(Trigger.isAfter && Trigger.isDelete) {
        handler.handleAfterDelete();
    }
}