/**
 * @author 			Jan Majling
 * @date 			17/08/2018
 * @group			CAJBP
 * @description		triggers on CAJBP_JbpTeamMemberTrigger__c object
 * 
 * history
 * 17/08/2018	Jan Majling			Created
 * 03/10/2018	Jan Majling			Updated to use an instance of CAJBP_JbpTeamMemberTriggerHandler
 */
trigger CAJBP_JbpTeamMemberTrigger on CAJBP_JBP_Team_Member__c (before insert, after insert, after update, after delete) {

	CAJBP_JbpTeamMemberTriggerHandler handler = new CAJBP_JbpTeamMemberTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

	if(Trigger.isBefore && Trigger.isInsert) {
		handler.handleBeforeInsert();
	}

	if(Trigger.isAfter && Trigger.isInsert) {
		handler.handleAfterInsert();
	}

	if(Trigger.isAfter && Trigger.isUpdate) {
		handler.handleAfterUpdate();
	}

	if(Trigger.isAfter && Trigger.isDelete) {
		handler.handleAfterDelete();
	}
}