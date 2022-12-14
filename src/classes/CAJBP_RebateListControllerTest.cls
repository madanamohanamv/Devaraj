/**
 * @author          Jan Majling
 * @date            09/09/2018
 * @group           CAJBP
 * @description     test class for CAJBP_RebateListController
 *
 * history
 * 09/09/201    Jan Majling         Created 
 */
@isTest
private class CAJBP_RebateListControllerTest {
    @testSetup static void setup() {
        Id recordTypeId = Schema.SObjectType.CAJBP_Joint_Business_Plan__c.getRecordTypeInfosByName().get('Direct JBP').getRecordTypeId();
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Account__c = CAJBP_TestFactory.createAccount().Id,
            CAJBP_Year__c = '2080',
            CAJBP_State__c = 'Draft',
            RecordTypeId = recordTypeId
        );
        insert jbp;
    }

    @isTest static void testGetScorecardWithRebates() {
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
         User user2 = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p2.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testpermissionsetuser2' + System.now().getTime() + '@testorg.com');
         insert user2;
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testpermissionsetuser' + System.now().getTime() + '@testorg.com');
        System.runAs(user2){
            insert u;
        
        
        
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CAJBP_Permission_for_Admin_User_for_JBP'];
           
            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        } 
    
    
        CAJBP_Joint_Business_Plan__c jbp = [
            SELECT Id 
            FROM CAJBP_Joint_Business_Plan__c
            WHERE CAJBP_Joint_Business_Plan_Name__c = 'Test Account Customer Group JBP 2080'
        ].get(0);
        List<CAJBP_Scorecard__c> scorecards = [
            SELECT Id
            FROM CAJBP_Scorecard__c
            WHERE CAJBP_Joint_Business_Plan__c = :jbp.Id
        ];
        CAJBP_Scorecard__c scorecard;
        if(scorecards.isEmpty()) {
            scorecard = new CAJBP_Scorecard__c(
                CAJBP_Joint_Business_Plan__c = jbp.Id
            );
            insert scorecard;
        } else {
            scorecard = scorecards.get(0);
        }

        Integer rebatesCount = 2;
        List<CAJBP_Rebate__c> rebates = new List<CAJBP_Rebate__c>();
        for(Integer i = 0; i < rebatesCount; i++) {
            CAJBP_Rebate__c rebate = new CAJBP_Rebate__c(
                CAJBP_Scorecard__c = scorecard.Id
            );
            rebates.add(rebate);
        }       
        insert rebates;

        CAJBP_Scorecard__c testedScorecard;
        Test.startTest();
        System.runAs(u)
        {
            testedScorecard = CAJBP_RebateListController.getScorecardWithRebates(jbp.Id);
        }    
        Test.stopTest();

        System.assertEquals(rebatesCount, testedScorecard.CAJBP_Rebates__r.size());
    }
}