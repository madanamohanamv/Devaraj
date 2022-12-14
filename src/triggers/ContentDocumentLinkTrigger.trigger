/**
 * @Who     Platform Team - Customer Org <adam.walker1@bp.com>
 * @when    10-04-2018
 * @what    The Generic Trigger on ContentDocumentLink. Please add your product specific handler into the ContentDocumentLinkTriggerHandler.cls
 *          If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
 **/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, before update, after update) {
    ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
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
}