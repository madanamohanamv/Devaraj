trigger ContentVersionTrigger on ContentVersion (after insert, after update, before insert, before update, before delete) {
    
    ContentVersionTriggerHandler handler = new ContentVersionTriggerHandler(Trigger.new, Trigger.newMap, Trigger.oldMap);
    
    if(Trigger.isBefore) {
        handler.before();
        if(Trigger.isInsert)
            handler.beforeInsert();
        else if(Trigger.isUpdate)
            handler.beforeUpdate();
        else if(Trigger.isDelete)
            handler.beforeDelete();
    }
    else if(Trigger.isAfter) {
        handler.after();
        if(Trigger.isInsert)
            handler.afterInsert();
        else if(Trigger.isUpdate)
            handler.afterUpdate();
    }
}