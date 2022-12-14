/**
 * @author Jan Majling
 * @date 26/07/2018
 * @description		test class for CAJBP_AccountTriggerHandler
 * 
 */
@isTest
private class CAJBP_AccountTriggerHandlerTest {
	
	@isTest static void testAccountUpdate() {
		Account account = CAJBP_TestFactory.createAccount();
		
		CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
			CAJBP_Year__c = '2080',
			CAJBP_Account__c = account.Id
		);
		insert jbp;

		account.Name = 'Power Plant Eco';
		account.Type = 'ZMSP';

		Test.startTest();
		update account;
		Test.stopTest();

		String jbpName = [
			SELECT CAJBP_Joint_Business_Plan_Name__c
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Id = :jbp.Id
		].CAJBP_Joint_Business_Plan_Name__c;
		System.assertEquals('Power Plant Eco Sold-To Party JBP 2080', jbpName);
	}

	@isTest static void testAccountUpdateBulk() {
		Integer count = 200;
		List<Account> accounts = new List<Account>();
		for(Integer i = 0; i < count; i++) {
			Account account = new Account(
				Name = 'Power Plant',
				Type = 'ZMHI'
			);
			accounts.add(account);
		}
		insert accounts;
		
		List<CAJBP_Joint_Business_Plan__c> jbps = new List<CAJBP_Joint_Business_Plan__c>();
		for(Account account : accounts) {
			CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
				CAJBP_Year__c = '2080',
				CAJBP_Account__c = account.Id
			);
			jbps.add(jbp);
		}
		insert jbps;

		for(Account account : accounts) {
			account.Name = 'Power Plant Eco';
			account.Type = 'ZMSP';
		}

		Test.startTest();
		update accounts;
		Test.stopTest();

		Set<Id> jbpIds = new Set<Id>();
		for(CAJBP_Joint_Business_Plan__c jbp : jbps) {
			jbpIds.add(jbp.Id);
		}
		List<CAJBP_Joint_Business_Plan__c> updatedJbps = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Id IN :jbpIds AND CAJBP_Joint_Business_Plan_Name__c LIKE 'Power Plant Eco%'
		];

		System.assertEquals(count, updatedJbps.size());
	}
}