/**
 * @author 			Jan Majling
 * @date 			17/08/2018
 * @group			CAJBP
 * @description		handles sharing for CAJBP_Joint_Business_Plan__c object and its related objects
 * 
 * history
 * 17/08/2018	Jan Majling			Created 
 */
public with sharing class CAJBP_JbpSharing {
	private final String SHARING_REASON = Schema.CAJBP_Joint_Business_Plan__Share.RowCause.Sharing_To_JBP_Team_Member__c;
	private final String PERMISSION_SET_CAJBP_USER_NAME = 'CAJBP_Permission_for_Standard_User_for_JBP';
	private String actionType;
	private String permissionSetId;
	private List<CAJBP_JBP_Team_Member__c> teamMembers;
	private Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByJbp;
	private Boolean isTriggeredByRelatedRecords;

	/**
	 * @description adds access to JBPs for the provided team members
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 */
	public void grantAccess(List<CAJBP_JBP_Team_Member__c> teamMembers) {
		this.actionType = 'Grant';
		this.isTriggeredByRelatedRecords = false;
		this.teamMembers = teamMembers;
		processRecords();
		this.addPermissionSet();
	}

	/**
	 * @description revokes access to JBPs from the provided team members
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 */
	public void revokeAccess(List<CAJBP_JBP_Team_Member__c> teamMembers) {
		this.actionType = 'Revoke';
		this.isTriggeredByRelatedRecords = false;
		this.teamMembers = teamMembers;
		processRecords();
		this.removePermissionSet();
	}

	/**
	 * @description processes JBP records and related records
	 */
	private void processRecords() {
		Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByJbp = this.getTeamMembersByJbp();

		this.setAccessToRecords(this.teamMembersByJbp, this.teamMembers);

		List<CAJBP_Objective__c> objectives = [
			SELECT CAJBP_Joint_Business_Plan__c
			FROM CAJBP_Objective__c
			WHERE CAJBP_Joint_Business_Plan__c IN :teamMembersByJbp.keySet()
		];

		this.processRelatedRecords(objectives);
	}

	/**
	 * @description grant access to related records
	 * @param relatedRecords of type List<SObject>
	 */
	public void grantAccessToRelatedRecords(List<SObject> relatedRecords) {
		this.actionType = 'Grant';
		this.isTriggeredByRelatedRecords = true;
		processRelatedRecords(relatedRecords);
	}

	/**
	 * @description revoke access to related records
	 * @param relatedRecords of type List<SObject>
	 */
	public void revokeAccessToRelatedRecords(List<SObject> relatedRecords) {
		this.actionType = 'Revoke';
		this.isTriggeredByRelatedRecords = true;
		processRelatedRecords(relatedRecords);
	}

	/**
	 * @description adds CAJBP standard user permission set to the provided team members
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>>
	 */
	public void addPermissionSet() {
		Id permissionSetId = this.getPermissionSetId();
		List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>();
		Set<Id> userIds = new Set<Id>();
		List<User> usersWithoutPermission;
		List<String> userStringIds;

		for(CAJBP_JBP_Team_Member__c teamMember : this.teamMembers) {
			userIds.add(teamMember.CAJBP_User__c);
		}

		usersWithoutPermission = [
			SELECT Id
			FROM User
			WHERE Id IN :userIds AND Id NOT IN (
				SELECT AssigneeId
				FROM PermissionSetAssignment
				WHERE PermissionSetId = :permissionSetId
			)
		];
		if(usersWithoutPermission.isEmpty()) {
			return;
		}

		userStringIds = new List<String>();
		for(User user : usersWithoutPermission) {
			userStringIds.add(user.Id);
		}
		CAJBP_SharingService.assignPermissionSetToUsers(permissionSetId, userStringIds);
	}

	/**
	 * @description revokes CAJBP standard user permission set from the provided team members
	 */
	public void removePermissionSet() {
		Set<Id> userIds = new Set<Id>();

		for(CAJBP_JBP_Team_Member__c teamMember : this.teamMembers) {
			userIds.add(teamMember.CAJBP_User__c);
		}
		List<User> usersToRemove = [
			SELECT Id
			FROM User
			WHERE Id IN :userIds AND Id NOT IN (
				SELECT CAJBP_User__c
				FROM CAJBP_JBP_Team_Member__c
			)
		];
		if(usersToRemove.isEmpty()) {
			return;
		}

		Id permissionSetId = this.getPermissionSetId();
		List<String> userToRemoveStringIds = new List<String>();
		for(User user : usersToRemove ) {
			userToRemoveStringIds.add(user.Id);
		}
		CAJBP_SharingService.removePermissionSetFromUsers(permissionSetId, userToRemoveStringIds);
	}

	/**
	 * @description gets Id of CAJBP standard permission set
	 * @return Id
	 */
	public Id getPermissionSetId() {
		if(this.permissionSetId != null ) {
			return this.permissionSetId;
		}
		List<PermissionSet> permissionSets = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = :PERMISSION_SET_CAJBP_USER_NAME
			LIMIT 1
		];
		this.permissionSetId = permissionSets.get(0).Id;
		return this.permissionSetId;
	}

	/**
	 * @description processes related records
	 * @param relatedRecords of type List<SObject>
	 */
	private void processRelatedRecords(List<SObject> relatedRecords) {
		if(relatedRecords.isEmpty()) {
			return;
		}

		String objectName = relatedRecords.get(0).getSObjectType().getDescribe().getName();
		String relationshipFieldName = this.getNameOfRelationshipField(objectName);

		List<CAJBP_JBP_Team_Member__c> teamMembers = this.getTeamMembersFromRelatedRecords(relatedRecords, relationshipFieldName);
		if(teamMembers.isEmpty()) {
			return;
		}
		Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByJbp = this.getTeamMembersByJbp();
		Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByRelatedRecord = new Map<Id,List<CAJBP_JBP_Team_Member__c>>();
		for(SObject record : relatedRecords) {
			teamMembersByRelatedRecord.put(
				record.Id,
				teamMembersByJbp.get((Id)record.get(relationshipFieldName))
			);
		}
		List<SObject> triggerRecords = this.isTriggeredByRelatedRecords ? relatedRecords : teamMembers;
		this.setAccessToRecords(teamMembersByRelatedRecord,	triggerRecords);
	}

	/**
	 * @description gets a list of team members from related records
	 * @param relatedRecords of type List<SObject>
	 * @param relationshipFieldName of type String
	 * @return List<CAJBP_JBP_Team_Member__c>
	 */
	private List<CAJBP_JBP_Team_Member__c> getTeamMembersFromRelatedRecords(List<SObject> relatedRecords, String relationshipFieldName) {
		if(this.teamMembers != null) {
			return this.teamMembers;
		}
		Set<Id> jbpIds = new Set<Id>();
		for(SObject record : relatedRecords) {
			jbpIds.add((Id)record.get(relationshipFieldName));
		}
		List<CAJBP_JBP_Team_Member__c> teamMembers = [
			SELECT CAJBP_Joint_Business_Plan__c, CAJBP_User__c, CAJBP_Access__c
			FROM CAJBP_JBP_Team_Member__c
			WHERE CAJBP_Joint_Business_Plan__c IN :jbpIds
		];
		this.teamMembers = teamMembers;
		return teamMembers;
	}

	/**
	 * @description gets name of the field referencing to CAJBP_Joint_Business_Plan__c
	 * @param objectName of type String
	 * @return String
	 */
	private String getNameOfRelationshipField(String objectName) {
		SObjectType SObjectType = Schema.getGlobalDescribe().get(objectName);
		Schema.SObjectType jbpType = CAJBP_Joint_Business_Plan__c.SObjectType;

		for(Schema.SObjectField field : SObjectType.getDescribe().fields.getMap().values()) {
			Schema.DescribeFieldResult fieldResult = field.getDescribe();
			List<Schema.SObjectType> referencedToList = fieldResult.getReferenceTo();
			if(!referencedToList.isEmpty() && referencedToList.get(0) == jbpType) {
				return fieldResult.getName();
			}
		}

		return '';
	}

	/**
	 * @description sets access to the provided records
	 * @param teamMembersBySharedRecord of type Map<Id,List<CAJBP_JBP_Team_Member__c>>
	 * @param triggerRecords of type List<SObject>
	 */
	private void setAccessToRecords(Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersBySharedRecord, List<SObject> triggerRecords) {
		List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>();
		for(Id sharedRecordId : teamMembersBySharedRecord.keySet()) {
			for(CAJBP_JBP_Team_Member__c teamMember : teamMembersBySharedRecord.get(sharedRecordId)){
				CAJBP_SharedItem sharedItem = new CAJBP_SharedItem();
				sharedItem.sharedRecordId = sharedRecordId;
				sharedItem.userOrGroupId = teamMember.CAJBP_User__c;
				sharedItem.sharingReason = SHARING_REASON;
				sharedItem.accessLevel = teamMember.CAJBP_Access__c;
				sharedItem.triggerKey = this.isTriggeredByRelatedRecords ? (String)sharedRecordId : teamMember.CAJBP_Unique_Key__c;
				sharedItems.add(sharedItem);
			}
		}
		CAJBP_SharingService sharingService = new CAJBP_SharingService();
		List<CAJBP_SharedItem> sharedItemsWithErrors;

		if(this.actionType == 'Grant') {
			sharedItemsWithErrors = sharingService.grantAccess(sharedItems);
		} else if(this.actionType == 'Revoke') {
			sharedItemsWithErrors = sharingService.revokeAccess(sharedItems);
		}

		this.processErrors(sharedItemsWithErrors, triggerRecords);
	}

	/**
	 * @description creates a map of team members grouped by Joint Business Plan Id
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 * @return Map<Id,List<CAJBP_JBP_Team_Member__c>>
	 */
	public Map<Id,List<CAJBP_JBP_Team_Member__c>> getTeamMembersByJbp() {
		if(this.teamMembersByJbp != null) {
			return this.teamMembersByJbp;
		}

		Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByJbp = new Map<Id,List<CAJBP_JBP_Team_Member__c>>();
		for(CAJBP_JBP_Team_Member__c teamMember : this.teamMembers) {
			List<CAJBP_JBP_Team_Member__c> subList = teamMembersByJbp.get(teamMember.CAJBP_Joint_Business_Plan__c);
			if (subList == null) {
				subList = new List<CAJBP_JBP_Team_Member__c>();
				teamMembersByJbp.put(teamMember.CAJBP_Joint_Business_Plan__c, subList);
			}
			subList.add(teamMember);
		}

		this.teamMembersByJbp = teamMembersByJbp;
		return teamMembersByJbp;
	}

	/**
	 * @description processes errors
	 * @param sharedItemsWithErrors of type List<CAJBP_SharedItem>
	 * @param triggerRecords of type List<SObject>
	 */
	private void processErrors(List<CAJBP_SharedItem> sharedItemsWithErrors, List<SObject> triggerRecords) {
		if(sharedItemsWithErrors.isEmpty()) {
			return;
		}

		Map<String,SObject> triggerRecordsByKey = new Map<String,SObject>();
		for(SObject triggerRecord : triggerRecords) {
			if(this.isTriggeredByRelatedRecords) {
				triggerRecordsByKey.put(
					(String)triggerRecord.get('Id'),
					triggerRecord
				);
			} else {
				triggerRecordsByKey.put(
					(String)triggerRecord.get('CAJBP_Unique_Key__c'),
					triggerRecord
				);
			}	
		}

		for(CAJBP_SharedItem sharedItemWithError : sharedItemsWithErrors) {
			SObject failedRecord = triggerRecordsByKey.get(sharedItemWithError.triggerKey);
			failedRecord.addError(sharedItemWithError.errorMessage);
		}
	}
}