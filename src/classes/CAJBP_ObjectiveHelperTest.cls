/**
 * @author Jan Majling
 * @date 23/08/2018
 * @group			CAJBP
 * @description     testing class for CAJBP_ObjectiveHelper
 * 
 * history
 * 23/08/2018	Jan Majling			Created 
 */
@isTest
private class CAJBP_ObjectiveHelperTest {
    @testSetup static void setup() {
        CAJBP_TestFactory.createUsers(1, 0);
        CAJBP_TestFactory.createJointBusinessPlan();
    }

    @isTest static void testShareObjectivesWithTeamMember() {
        Id userId = [SELECT Id FROM User WHERE Username = 'cajbp.user@test.com0'].Id;
        Id jbpId = [SELECT Id FROM CAJBP_Joint_Business_Plan__c WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'].Id;
        CAJBP_JBP_Team_Member__c teamMember = CAJBP_TestFactory.createJBPTeamMember(userId, jbpId, 'Read Only');
        List<CAJBP_Objective__c> objectives = new List<CAJBP_Objective__c>();
        Integer objectivesCount = 1;

        for(Integer i = 0; i < objectivesCount; i++ ) {
            CAJBP_Objective__c objective = new CAJBP_Objective__c(
                CAJBP_Joint_Business_Plan__c = jbpId
            );
            objectives.add(objective);
        }

        Test.startTest();
        insert objectives;
        Test.stopTest();

        Set<Id> objectiveIds = new Set<Id>();
        for(CAJBP_Objective__c objective : objectives) {
            objectiveIds.add(objective.Id);
        }
        List<CAJBP_Objective__Share> objectiveShares = [
            SELECT Id
            FROM CAJBP_Objective__Share
            WHERE ParentId IN :objectiveIds AND UserOrGroupId = :userId
        ];

        System.assertEquals(objectivesCount, objectiveShares.size());
    }

    @isTest static void testShareObjectivesWithoutJbp() {
        Id userId = [SELECT Id FROM User WHERE Username = 'cajbp.user@test.com0'].Id;

        CAJBP_Objective__c objective = new CAJBP_Objective__c();

        Test.startTest();
        insert objective;
        Test.stopTest();

        List<CAJBP_Objective__Share> objectiveShares = [
            SELECT Id
            FROM CAJBP_Objective__Share
            WHERE ParentId = :objective.Id AND UserOrGroupId = :userId
        ];

        System.assertEquals(0, objectiveShares.size());
    }

    @isTest static void testShareObjectivesWithNoTeamMember() {
        Id userId = [SELECT Id FROM User WHERE Username = 'cajbp.user@test.com0'].Id;
        Id jbpId = [SELECT Id FROM CAJBP_Joint_Business_Plan__c WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'].Id;

        CAJBP_Objective__c objective = new CAJBP_Objective__c(
            //Name = 'Increase Sales By 5%',
            CAJBP_Joint_Business_Plan__c = jbpId
        );

        Test.startTest();
        insert objective;
        Test.stopTest();

        List<CAJBP_Objective__Share> objectiveShares = [
            SELECT Id
            FROM CAJBP_Objective__Share
            WHERE ParentId = :objective.Id AND UserOrGroupId = :userId
        ];

        System.assertEquals(0, objectiveShares.size());
    }
}