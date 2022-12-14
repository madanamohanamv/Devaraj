/**
 * @author 			Jan Majling
 * @date 			26/07/2018
 * @group			CAJBP
 * @description     triggers on CAJBP_Joint_Business_Plan__c object
 *
 * history
 * 26/07/2018	Jan Majling			Created
 * 03/10/2018	Jan Majling			Updated to use instance of CAJBP_JbpTriggerHandler
 */
trigger CAJBP_JbpTrigger on CAJBP_Joint_Business_Plan__c (before insert, before update, after insert, after update) {

	CAJBP_JbpTriggerHandler handler = new CAJBP_JbpTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
	
	if(Trigger.isBefore && Trigger.isInsert) {
		handler.handleBeforeUpsert();
	}

	if(Trigger.isBefore && Trigger.isUpdate) {
		handler.handleBeforeUpsert();
	}
	
	if(Trigger.isAfter && Trigger.isInsert) {
		handler.handleAfterInsert();
	}
}