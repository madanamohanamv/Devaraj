/**
 * @author 			Jan Majling
 * @date 			22/08/2018
 * @group			CAJBP
 * @description		triggers on CAJBP_Objective__c object
 * 
 * history
 * 22/08/2018	Jan Majling			Created
 */
trigger CAJBP_ObjectiveTrigger on CAJBP_Objective__c (after insert) {
	CAJBP_ObjectiveTriggerHandler handler = new CAJBP_ObjectiveTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

	if(Trigger.isAfter && Trigger.isInsert) {
		handler.handleAfterInsert();
	}
}