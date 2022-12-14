/**
 * @author			Jan Majling
 * @date			03/10/2018
 * @group			CAJBP
 * @description		handles triggers of CAJBP_Objective__c object
 *
 * history
 * 03/10/2018	Jan Majling			Created
 */
public with sharing class CAJBP_ObjectiveTriggerHandler {
	private final List<CAJBP_Objective__c> newRecords;
	private final List<CAJBP_Objective__c> oldRecords;
	private final Map<Id,CAJBP_Objective__c> newMap;
	private final Map<Id,CAJBP_Objective__c> oldMap;

	/**
	 * @description constructor
	 * @param newRecords of type List<CAJBP_Objective__c>
	 * @param oldRecords of type List<CAJBP_Objective__c>
	 * @param newMap of type Map<Id,CAJBP_Objective__c>
	 * @param oldMap of type Map<Id,CAJBP_Objective__c>
	 */
	public CAJBP_ObjectiveTriggerHandler(List<CAJBP_Objective__c> newRecords, List<CAJBP_Objective__c> oldRecords, Map<Id,CAJBP_Objective__c> newMap, Map<Id,CAJBP_Objective__c> oldMap) {
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.newMap = newMap;
		this.oldMap = oldMap;
	}

	/**
	 * @description handles after insert trigger event
	 */
	public void handleAfterInsert() {
		new CAJBP_ObjectiveHelper().shareObjectivesWithTeamMembers(this.newRecords);
	}
}