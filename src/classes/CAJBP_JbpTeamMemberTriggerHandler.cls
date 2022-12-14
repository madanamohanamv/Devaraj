/**
 * @author			Jan Majling
 * @date			28/08/2018
 * @group			CAJBP
 * @description		handles triggers of CAJBP_JBP_Team_Member__c object
 *
 * history
 * 28/08/2018	Jan Majling			Created
 * 03/10/2018	Jan Majling			Updated to set records in constructor
 */
public with sharing class CAJBP_JbpTeamMemberTriggerHandler {
	private final List<CAJBP_JBP_Team_Member__c> newRecords;
	private final List<CAJBP_JBP_Team_Member__c> oldRecords;
	private final Map<Id,CAJBP_JBP_Team_Member__c> newMap;
	private final Map<Id,CAJBP_JBP_Team_Member__c> oldMap;

	/**
	 * @description constructor
	 * @param newRecords of type List<CAJBP_JBP_Team_Member__c>
	 * @param oldRecords of type List<CAJBP_JBP_Team_Member__c>
	 * @param newMap of type Map<Id,CAJBP_JBP_Team_Member__c>
	 * @param oldMap of type Map<Id,CAJBP_JBP_Team_Member__c>
	 */
	public CAJBP_JbpTeamMemberTriggerHandler(List<CAJBP_JBP_Team_Member__c> newRecords, List<CAJBP_JBP_Team_Member__c> oldRecords, Map<Id,CAJBP_JBP_Team_Member__c> newMap, Map<Id,CAJBP_JBP_Team_Member__c> oldMap) {
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.newMap = newMap;
		this.oldMap = oldMap;
	}

	/**
	 * @description handles before insert CAJBP_JBP_Team_Member__c trigger event
	 */
	public void handleBeforeInsert() {
		CAJBP_JbpTeamMemberHelper helper = new CAJBP_JbpTeamMemberHelper();
		helper.setUniqueKeys(this.newRecords);
		helper.preventDuplicates(this.newRecords);
	}

	/**
	 * @description handles after insert CAJBP_JBP_Team_Member__c trigger event
	 */
	public void handleAfterInsert() {
		new CAJBP_JbpSharing().grantAccess(this.newRecords);
	}

	/**
	 * @description handles after update CAJBP_JBP_Team_Member__c trigger event
	 */
	public void handleAfterUpdate() {
		new CAJBP_JbpSharing().grantAccess(this.newRecords);
	}

	/**
	 * @description handles after delete CAJBP_JBP_Team_Member__c trigger event
	 */
	public void handleAfterDelete() {
		new CAJBP_JbpSharing().revokeAccess(this.oldRecords);
	}
}