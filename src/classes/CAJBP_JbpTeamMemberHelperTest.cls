/**
 * @author			Jan Majling
 * @date 			30/08/2018
 * @group			CAJBP
 * @description		testing class for CAJBP_JbpTeamMemberHelper
 * 
 * history
 * 30/08/2018	Jan Majling			Created 
 */
@isTest
private class CAJBP_JbpTeamMemberHelperTest {
	@testSetup static void setup() {
		CAJBP_TestFactory.createJointBusinessPlan();
		CAJBP_TestFactory.createUsers(1,0);
	}

	@isTest static void testUniqueKey() {
		Id userId = [SELECT Id FROM User WHERE Username = 'cajbp.user@test.com0'].Id;
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = userId,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read Only'
		);

		String uniqueKey;
		Test.startTest();
		uniqueKey = new CAJBP_JbpTeamMemberHelper().createUniqueKey(teamMember);
		Test.stopTest();

		String expectedKey = (String)jbpId + userId;
		System.assertEquals(expectedKey, uniqueKey);
	}

	@isTest static void testSetUniqueKeys() {
		List<User> users = CAJBP_TestFactory.createUsers(2,1);
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_JbpTeamMemberHelper helper = new CAJBP_JbpTeamMemberHelper();
		Set<String> uniqueKeys = new Set<String>();
		List<CAJBP_JBP_Team_Member__c> teamMembers = new List<CAJBP_JBP_Team_Member__c>();
		for(User user : users) {
			CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
				CAJBP_User__c = user.Id,
				CAJBP_Joint_Business_Plan__c = jbpId,
				CAJBP_Access__c = 'Read Only'
			);
			teamMembers.add(teamMember);
			uniqueKeys.add(helper.createUniqueKey(teamMember));
		}

		Test.startTest();
		helper.setUniqueKeys(teamMembers);
		Test.stopTest();

		for(CAJBP_JBP_Team_Member__c teamMember : teamMembers) {
			uniqueKeys.remove(teamMember.CAJBP_Unique_Key__c);
		}

		System.assert(uniqueKeys.isEmpty());
	}

	@isTest static void testNoDuplicatedJbpTeamMember() {
		Id userId = [SELECT Id FROM User WHERE Username = 'cajbp.user@test.com0'].Id;
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = userId,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read Only'
		);
		insert teamMember;
		CAJBP_JBP_Team_Member__c newTeamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = userId,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read/Write'
		);

		String errorMessage;
		Test.startTest();
		try {
			insert newTeamMember;
		} catch(Exception e) {
			errorMessage = e.getMessage();
		}
		Test.stopTest();

		System.assert(errorMessage.contains(Label.CAJBP_Duplicated_JBP_Team_Member));
	}
}