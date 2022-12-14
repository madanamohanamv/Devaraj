/***************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_AccountDao

 * history
 * 01/December/2017  George       Created
 * 07/March/2018     srnandan     Modified - added header and method comments
 **********************************************************/
@isTest 
private class AITM_AccountDaoTests {

    /**
     * @description tests to verify accounts by grn
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetAccountByGRNWillReturnAllOfThemAsAList() {
        AccountDaoTestSetup testSetup = new AccountDaoTestSetup().generateData();

        Test.startTest();
            List<Account> result = testSetup.classUnderTest.getAccountsByGRN(new Set<String>{'1000000', '1000002', '1000007', '1000008'});
        Test.stopTest();

        System.assertEquals(4, result.size());
    }

    /**
     * @description tests to verify accounts group by grn
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetAccountsGroupedByGRNWillReturnAllOfThemAsAMap() {
        AccountDaoTestSetup testSetup = new AccountDaoTestSetup().generateData();

        Test.startTest();
            Map<String, Id> result = testSetup.classUnderTest.getAccountsGroupedByGRN(new Set<String>{'1000000', '1000002', '1000007', '1000008'});
        Test.stopTest();

        System.assertEquals(4, result.size());
        System.assertEquals(testSetup.accounts[0].Id, result.get('1000000'));
    }

    /**
     * @description tests to validate accounts
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetValidateAccounts() {
        AccountDaoTestSetup testSetup = new AccountDaoTestSetup().generateData();
        Account acc = testSetup.accounts[0];
        acc.AITM_Credit_Days1__c = '1';
        acc.AITM_Customer_Segment__c = 'Core';
        update acc;

        Test.startTest();
            Boolean result = testSetup.classUnderTest.getValidateAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(false, result);
    }

    /**
     * @description tests to get account with TLLI
     * @param  null
     * @return void
     */
    @isTest  
    static void testGetAccountWithTLLI() {
        AccountDaoTestSetup testSetup = new AccountDaoTestSetup().generateData();
        Account acc = testSetup.accounts[0];
        Account acc1 = testSetup.accounts[1];
        Set<Id> accountId = new Set<Id>();
        accountId.add(acc.Id);
        accountId.add(acc1.Id);
      
        Test.startTest();
            List<Account> result = testSetup.classUnderTest.getAccountsByTenderLocationLineItemAccountId(accountId);
        Test.stopTest();
        System.assertEquals(2, result.size());
    }

    /**
     * @description tests to verify tender account with offer information
     * @param  null
     * @return void
     */
    @isTest  
    static void testTenderAccountDaoGetTenderAccountWithOfferInformation() {
        AccountDaoTestSetup testSetup = new AccountDaoTestSetup().generateData();

        Test.startTest();
           AITM_Tender_Account__c result = new AITM_AccountDao.TenderAccountDao().getTenderAccountWithOfferInformation(testSetup.tenderAccounts[0].Id);
        Test.stopTest();

        System.assertEquals(testSetup.tenderAccounts[0].Id, result.Id);
    }

    /**
     * @description tests to verify tender account for a tender
     * @param  null
     * @return void
     */
    @isTest  
    static void testTenderAccountDaoGetTenderAccountForTender() {
        AccountDaoTestSetup testSetup = new AccountDaoTestSetup().generateData();

        Test.startTest();
           List<AITM_Tender_Account__c> result = new AITM_AccountDao.TenderAccountDao().getTenderAccountForTender(testSetup.tender.Id);
        Test.stopTest();

        System.assertEquals(testSetup.ITEMS_COUNT, result.size());
    }

    /**
     * @description AccountDao Test data setup class
     */
    private class AccountDaoTestSetup extends AITM_TestSetup {
        private List<Account> accounts;
        private AITM_AccountDao classUnderTest;
        private List<AITM_Location__c> locations;
        private AITM_Tender__c tender;
        private List<AITM_Tender_Account__c> tenderAccounts;

        private final Integer ITEMS_COUNT = 10;

        /**
         * @description default constructor
         */ 
        private AccountDaoTestSetup() {
            classUnderTest = new AITM_AccountDao();
            AITM_DeactivateTriggerSetting__c settings = AITM_DeactivateTriggerSetting__c.getOrgDefaults();
			settings.AITM_IsActive__c = true;
			upsert settings AITM_DeactivateTriggerSetting__c.Id;
        }

        /**
         * @description generate test data
         * @param  null
         * @return AccountDaoTestSetup
         */
        private AccountDaoTestSetup generateData() {
            accounts = createAccounts(ITEMS_COUNT);
            insert accounts;

            tender = createTender();
            insert tender;

            tenderAccounts = createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
            insert tenderAccounts;

            return this;
        }

        /**
         * @description creates tenderlocations
         * @param  null
         * @return List collection of AITM_Tender_Location__c
         */
        private List<AITM_Tender_Location__c> createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
            for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                    );
            }
            return tenderLocations;
        }

    }

}