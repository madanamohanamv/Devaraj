/**
 * @author			Jan Majling
 * @date			28/08/2018
 * @group			CAJBP
 * @description		helper functions for CAJBP_JbpTeamMember__c object
 *
 * history
 * 28/08/2018	Jan Majling			Created 
 */
public with sharing class CAJBP_JbpTeamMemberHelper {
	/**
	 * @description creates unique key consisting of CAJBP_Joint_Business_Plan__c Id
	 * and CAJBP_User__c Id
	 * @param teamMember of type CAJBP_JBP_Team_Member__c
	 * @return String
	 */
	public String createUniqueKey(CAJBP_JBP_Team_Member__c teamMember) {
		return (String)teamMember.CAJBP_Joint_Business_Plan__c + teamMember.CAJBP_User__c;
	}

	/**
	 * @description sets unique key to JBP Team Members
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 */
	public void setUniqueKeys(List<CAJBP_JBP_Team_Member__c> teamMembers) {
		for(CAJBP_JBP_Team_Member__c teamMember : teamMembers) {
			teamMember.CAJBP_Unique_Key__c = this.createUniqueKey(teamMember);
		}
	}

	/**
	 * @description prevents duplicates of JBP Team Members by comparing unique keys
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 */
	public void preventDuplicates(List<CAJBP_JBP_Team_Member__c> teamMembers) {
		Map<String,CAJBP_JBP_Team_Member__c> teamMembersByUniqueKey = new Map<String,CAJBP_JBP_Team_Member__c>();
		for(CAJBP_JBP_Team_Member__c teamMember : teamMembers) {
			teamMembersByUniqueKey.put(teamMember.CAJBP_Unique_Key__c, teamMember);
		}

		List<CAJBP_JBP_Team_Member__c> existingTeamMembers = [
			SELECT CAJBP_Unique_Key__c
			FROM CAJBP_JBP_Team_Member__c
			WHERE CAJBP_Unique_Key__c IN :teamMembersByUniqueKey.keySet()
		];
		for(CAJBP_JBP_Team_Member__c existingTeamMember : existingTeamMembers) {
			String uniqueKey = existingTeamMember.CAJBP_Unique_Key__c;
			teamMembersByUniqueKey.get(uniqueKey).addError(Label.CAJBP_Duplicated_JBP_Team_Member);
		}
	}
}