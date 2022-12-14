/**
 * @author 			Jana Cechova
 * @date 			26/07/2018
 * @group			CAJBP
 * @description     triggers on CAJBP_JbpActivity__c object
 *
 * history
 * 26/07/2018	Jana Cechova			Created
 * 03/10/2018	Jan Majling				Updated to use instance of CAJBP_JbpActivityTriggerHandler
 */
trigger CAJBP_JbpActivityTrigger on CAJBP_JBP_Activity__c(before insert) {

	CAJBP_JbpActivityTriggerHandler handler = new CAJBP_JbpActivityTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

    if(Trigger.isBefore && Trigger.isInsert) {
    	handler.handleBeforeInsert();
    }
}