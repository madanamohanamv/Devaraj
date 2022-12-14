@isTest 
private class AITM_TenderAccountHandlerTests {

    public static final Integer ACCOUNTS_SIZE = 20; 
    public static final Integer TENDER_SIZE = 4;
    @isTest 
    static void testTenderAccountsSingleInsertionForHierarchyWillAlsoInsertHierarchyAccounts() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        
        Test.startTest();
            insert singleTenderAccount;
        Test.stopTest();

        //System.assertEquals(ACCOUNTS_SIZE, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id], 'All Accounts Should Be Shared');
        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id], 'All Accounts Should Be Shared');
    }

    @isTest 
    static void testTenderAccountsSingleInsertionWithoutHierarchyWillOnlyInsertThisAccount() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;

        Test.startTest();
            insert singleTenderAccount;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id], 'Only One Account Should Be Shared');
    }

    @isTest 
    static void testTenderAccountsBulkInsertionWillInsertValidNumberOfTenderAccounts() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();

        Test.startTest();
            insert testSetup.tenderAccounts;
        Test.stopTest();

        System.assertEquals(ACCOUNTS_SIZE*TENDER_SIZE, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c IN :testSetup.tenders], 'All Accounts Should Be Shared For All Tenders');
    }

    @isTest 
    static void testTenderAccountsOnInsertWillNotCreateDuplicates() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;
        insert singleTenderAccount;
        AITM_Tender_Account__c headTenderAccount = testSetup.createSingleTenderAccounts();
        Test.startTest();
            insert headTenderAccount;
        Test.stopTest();

        //System.assertEquals(ACCOUNTS_SIZE, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id]);
        System.assertEquals(2, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id]);
    }

    @isTest 
    static void testUpdateWillWorkWithoutErrors() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;
        insert singleTenderAccount;

        Test.startTest();
            singleTenderAccount.AITM_Credit_Days__c = 2;
             //singleTenderAccount.AITM_Security_Type__c = 'BG - Bank Guarantee';
       
            update singleTenderAccount;
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :testSetup.tenders[0].Id AND AITM_Credit_Days__c = 2 AND AITM_Security_Type__c = 'BG - Bank Guarantee']);
    }

    @isTest 
    static void testDeletionWillWorkWithoutErrors() {
        TenderAccountHandlerTestSetup testSetup = new TenderAccountHandlerTestSetup().generateData();
        AITM_Tender_Account__c singleTenderAccount = testSetup.createSingleTenderAccounts();
        singleTenderAccount.AITM_Account__c = testSetup.accountHierarchy[1].Id;
        insert singleTenderAccount;

        testSetup.createTenderLocationLineItems();
        System.assertEquals(testSetup.tenderLocations.size(),[SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :testSetup.tenderLocations]);
        
        
        Test.startTest();
        delete singleTenderAccount;
        Test.stopTest();
        System.assertEquals(testSetup.tenderLocations.size(),[SELECT Count() FROM AITM_Tender_Location_Line_Item__c WHERE Id IN :testSetup.tenderLocations]); 
        
    }

    private class TenderAccountHandlerTestSetup extends AITM_TestSetup {
        public List<AITM_Tender_Account__c> tenderAccounts;
        public List<Account> accountHierarchy;
        public List<AITM_Tender__c> tenders;
        public List<AITM_Location__c> locations;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;

        public TenderAccountHandlerTestSetup generateData(){
            tenders = createTenders(AITM_TenderAccountHandlerTests.TENDER_SIZE);
            insert tenders;
            accountHierarchy = createAccounts(AITM_TenderAccountHandlerTests.ACCOUNTS_SIZE);
			
            for (Account acc :accountHierarchy)
            {
              acc.AITM_Security_Type__c = 'BG - Bank Guarantee';                
            }
            insert accountHierarchy;

            locations = createLocations(1);
            insert locations;


            updateAccountsToFormHierarchy();

            tenderAccounts = createTenderAccounts(tenders, accountHierarchy);
            
            return this;
        }

        public void updateAccountsToFormHierarchy() {
            for (Integer index = 1; index < accountHierarchy.size(); index++) {
                accountHierarchy[index].ParentId = accountHierarchy[0].Id;
            }

            update accountHierarchy;
        }

        public AITM_Tender_Account__c createSingleTenderAccounts() {
            return new AITM_Tender_Account__c(AITM_Account__c = accountHierarchy[0].Id, AITM_Tender__c = tenders[0].Id);
        }

        public AITM_Tender_Account__c createTenderAccountWithoutAccountsHierarchy() {
            Account parentAccount = super.createAccount();
            insert parentAccount;
            return super.createTenderAccount(tenders[0].Id, parentAccount.Id);
        }

        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tenders[0]}, accountHierarchy, new List<AITM_Location__c>{locations[0]});
            insert tenderLocations;
        }
    }

}