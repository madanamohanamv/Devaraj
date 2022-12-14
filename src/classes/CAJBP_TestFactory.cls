/**
 * @author Jan Majling
 * @date 21/08/2018
 * @description     Test Factory for CAJBP project
 * 
 */
@isTest
public class CAJBP_TestFactory {
	public static final String CURRENCY_ISO_CODE = 'USD';

    public static List<User> createUsers(Integer count, Integer offset) {
        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
        ];
        List<User> users = new List<User>();
        Integer max = count + offset;
        for(Integer i = offset; i < max; i++) {
            User user = new User(
                ProfileId = profile.Id,
                Username = 'cajbp.user@test.com' + i,
                LastName = 'Tester',
                Email = 'user@test.com',
                Alias = 'testuser',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
            );
            users.add(user);
        }
        insert users;
        return users;
    }

    public static Account createAccount() {
        Id recordTypeCustomerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account account = new Account(
            Name = 'Test Account',
            RecordTypeId = recordTypeCustomerId,
            Type = 'ZMHI'
        );
        insert account;
        return account;
    }

    public static CAJBP_Joint_Business_Plan__c createJointBusinessPlan() {
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Account__c = CAJBP_TestFactory.createAccount().Id,
            CAJBP_Year__c = '2080'
        );
        insert jbp;
        return jbp;
    }

    public static CAJBP_JBP_Team_Member__c createJBPTeamMember(Id userId, Id jbpId, String access) {
        CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
            CAJBP_User__c = userId,
            CAJBP_Joint_Business_Plan__c = jbpId,
            CAJBP_Access__c = access
        );
        insert teamMember;
        return teamMember;
    }

    public static CAJBP_Objective__c createObjective(Id jbpId) {
        CAJBP_Objective__c objective = new CAJBP_Objective__c(
           // Name = 'Test Objective',
            CAJBP_Joint_Business_Plan__c = jbpId
        );
        insert objective;
        return objective;
    }

    public static CAJBP_JBP_Activity__c createJbpActivity(Id objectiveId) {
        CAJBP_JBP_Activity__c jbpActivity = new CAJBP_JBP_Activity__c(
            Name = 'Test JBP Activity',
            CAJBP_Objective__c = objectiveId,
            CurrencyIsoCode = CURRENCY_ISO_CODE
        );
        insert jbpActivity;
        return jbpActivity;
    }
}