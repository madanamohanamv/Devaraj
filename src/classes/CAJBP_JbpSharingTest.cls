/**
 * @author Jan Majling
 * @date 23/08/2018
 * @description		testing class for CAJBP_JbpSharing
 * 
 * history
 * 23/08/2018	Jan Majling			Created 
 */
@isTest
private class CAJBP_JbpSharingTest {
	@testSetup static void setup() {
		CAJBP_TestFactory.createJointBusinessPlan();
	}

	@isTest static void testGrantAccessForTeamMembers() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'
		].Id;
		Integer teamMembersCount = 200;
		Set<Id> userIds = new Set<Id>();
		List<User> users = CAJBP_TestFactory.createUsers(teamMembersCount, 0);
		List<CAJBP_JBP_Team_Member__c> teamMembers = new List<CAJBP_JBP_Team_Member__c>();
		for(User user : users) {
			CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
				CAJBP_User__c = user.Id,
				CAJBP_Joint_Business_Plan__c = jbpId,
				CAJBP_Access__c = 'Read Only'
			);
			teamMembers.add(teamMember);
			userIds.add(user.Id);
		}

		Test.startTest();
		insert teamMembers;
		Test.stopTest();

		List<CAJBP_Joint_Business_Plan__Share> jbpShareObjects = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__Share
			WHERE ParentId = :jbpId AND UserOrGroupId IN :userIds AND AccessLevel = 'Read'
		];

		System.assertEquals(teamMembersCount, jbpShareObjects.size());
	}

	@isTest static void testGrantAccessForInvalidTeamMember() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = null,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read Only'
		);
		String errorMessage;

		Test.startTest();
		try {
			insert teamMember;
		} catch(DmlException error) {
			errorMessage = error.getMessage();
		}
		Test.stopTest();

		System.assert(errorMessage.contains(Label.CAJBP_GrantAccessError));
	}

	@isTest static void testUpdateAccessForTeamMembers() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'
		].Id;
		Integer teamMembersCount = 200;
		Set<Id> userIds = new Set<Id>();
		List<User> users = CAJBP_TestFactory.createUsers(teamMembersCount, 0);
		List<CAJBP_JBP_Team_Member__c> teamMembers = new List<CAJBP_JBP_Team_Member__c>();
		for(User user : users) {			
			CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
				CAJBP_User__c = user.Id,
				CAJBP_Joint_Business_Plan__c = jbpId,
				CAJBP_Access__c = 'Read Only'
			);
			teamMembers.add(teamMember);
			userIds.add(user.Id);
		}

		insert teamMembers;
		for(CAJBP_JBP_Team_Member__c teamMember : teamMembers) {
			teamMember.CAJBP_Access__c = 'Read/Write';
		}

		Test.startTest();
		update teamMembers;
		Test.stopTest();

		List<CAJBP_Joint_Business_Plan__Share> jbpShareObjects = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__Share
			WHERE ParentId = :jbpId
				AND UserOrGroupId IN :userIds
				AND AccessLevel = 'Edit'
		];

		System.assertEquals(teamMembersCount, jbpShareObjects.size());
	}

	@isTest static void testRevokeAccessForTeamMembers() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'
		].Id;
		Integer teamMembersCount = 200;
		Set<Id> userIds = new Set<Id>();
		List<User> users = CAJBP_TestFactory.createUsers(teamMembersCount, 0);
		List<CAJBP_JBP_Team_Member__c> teamMembers = new List<CAJBP_JBP_Team_Member__c>();
		for(User user : users) {			
			CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
				CAJBP_User__c = user.Id,
				CAJBP_Joint_Business_Plan__c = jbpId,
				CAJBP_Access__c = 'Read Only'
			);
			teamMembers.add(teamMember);
			userIds.add(user.Id);
		}

		insert teamMembers;

		Test.startTest();
		delete teamMembers;
		Test.stopTest();

		List<CAJBP_Joint_Business_Plan__Share> jbpShareObjects = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__Share
			WHERE ParentId = :jbpId
				AND UserOrGroupId IN :userIds
				AND AccessLevel = 'Read'
		];

		System.assertEquals(0, jbpShareObjects.size());
	}
}