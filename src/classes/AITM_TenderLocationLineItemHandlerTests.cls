@isTest 
private class AITM_TenderLocationLineItemHandlerTests {
    @isTest 
    static void testInsertionOfTenderLocationsWillCreateRecordsIfThereAreNoRecordsForTenderAccountCombination() {
        TenderLocationLineItemHandlerTestSetup testSetup = new TenderLocationLineItemHandlerTestSetup().generateData();
        testSetup.createTenderLocationLineItems();

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size(), [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals(tenderLocationVolume*testSetup.tenderLocations.size(), totalVolume);
    }

    @isTest 
    static void testInsertionTenderLocationsWillNotUpdateRecordsIfTheyAreAlreadyCreated() {
        TenderLocationLineItemHandlerTestSetup testSetup = new TenderLocationLineItemHandlerTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.Id = null;
            tenderLocation.AITM_Volume__c = 5;
        }

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size()*2, [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals((1+5)*testSetup.tenderLocations.size(), totalVolume);
    }

    @isTest 
    static void testInsertLocationsWillNotUpdateRecordsToBeZeroIfTheyAreAdHoc() {
        TenderLocationLineItemHandlerTestSetup testSetup = new TenderLocationLineItemHandlerTestSetup().generateData();
        
        testSetup.createTenderLocationLineItems();
        insert testSetup.tenderLocations;

        Decimal tenderLocationVolume = testSetup.tenderLocations[0].AITM_Volume__c;

        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.Id = null;
            tenderLocation.AITM_Volume__c = null;
            tenderLocation.AITM_Ad_hoc_Volume__c = true;
        }

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();

        System.assertEquals(testSetup.tenderLocations.size()*2, [Select Count() FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]);
        Decimal totalVolume = 0;
        for (AITM_Tender_Location_Line_Item__c tenderLocationLine : [SELECT Id, AITM_Volume__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id]) {
            totalVolume += tenderLocationLine.AITM_Volume__c == null? 0 : tenderLocationLine.AITM_Volume__c;
        }
        System.assertEquals((1+0)*testSetup.tenderLocations.size(), totalVolume);
    }

    private class TenderLocationLineItemHandlerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;

        public TenderLocationLineItemHandlerTestSetup generateData(){
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            tender = createTender();
            insert tender;

            return this;
        }

        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }        
    }

}