/***********************************************************************************************
* @author           George
* @date             20/Nov/2017
* @group            AirBP
* @description      Test class to cover AITM_TenderLocationPrePopulationHandler class.
* history
* 20/Nov/2017       George          Created
* 07/March/2018     Ravi Pamidi     AR-2523 Removed AITM_Currency_Pricing_Basis__c field as that was converted as formula field.
* 29/May/2018       srnandan        AR-3169 Modified the soql AITM_Days__c with AITM_Credit_Days__c for lineitem
*************************************************************************************/
@isTest 
private class AITM_TenderLocationPrePopulationHdlTests {

    /**
    * @description This method is to populate the Fields wont work if values are predefined.
    * @param No Parameters
    * @return void
    */
    @isTest 
    static void testPrepopulationOfTheFieldsWontWorkIfValuesArePredefined() {
        TenderLocationPrePopulationHandlerTestSetup testSetup = new TenderLocationPrePopulationHandlerTestSetup().generateData();
        testSetup.createTenderLocationLineItems();
        for (AITM_Tender_Location_Line_Item__c tenderLocation : testSetup.tenderLocations) {
            tenderLocation.AITM_Credit_Days__c = '2';
            tenderLocation.AITM_Invoice_Frequency__c = 'Monthly';
            tenderLocation.AITM_Unit_Of_Measure__c = 'LT';
        }

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();
        
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT AITM_Credit_Days__c, AITM_Invoice_Frequency__c, AITM_Unit_Of_Measure__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        for (Integer index = 0; index < tenderLocationLineItems.size(); index++) {
            System.assertEquals('2', tenderLocationLineItems[index].AITM_Credit_Days__c);
            System.assertEquals('Monthly', tenderLocationLineItems[index].AITM_Invoice_Frequency__c);
            System.assertEquals('LT', tenderLocationLineItems[index].AITM_Unit_Of_Measure__c); 
        }
        
    }

    /**
    * @description This metod is to prepopulate the fields that will work for all in Tender Location line Item as a test data.
    * @param No Parameters
    * @return void
    */
    @isTest 
    static void testPrepopulationOfTheFieldsWillWorkForAllFields() {
        TenderLocationPrePopulationHandlerTestSetup testSetup = new TenderLocationPrePopulationHandlerTestSetup().generateData();
        testSetup.createTenderLocationLineItems();

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();
        
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT Id, AITM_Credit_Days__c, OwnerId, AITM_Invoice_Frequency__c, AITM_Unit_Of_Measure__c, AITM_Delivery_Point__c, AITM_Location_Manager__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        for (Integer index = 0; index < tenderLocationLineItems.size(); index++) {
            System.assertEquals(testSetup.accounts[index].AITM_Invoice_Frequency__c, tenderLocationLineItems[index].AITM_Invoice_Frequency__c);
            //System.assertEquals(testSetup.locations[index].AITM_Unit_Of_Measure__c, tenderLocationLineItems[index].AITM_Unit_Of_Measure__c);
            System.assertEquals(null, tenderLocationLineItems[index].AITM_Location_Manager__c);   
            System.assertEquals(testSetup.locations[index].OwnerId, tenderLocationLineItems[index].OwnerId);   
        }
    }

    /**
    * @description This method is used to populate location manager that will work if location manager available for this sector and location test data.
    * @param No parameters
    * @return void
    */
    @isTest 
    static void testPrepopulationOfLocationManagerWillWorkIfLocationManagerAvailableForThisSectorAndLocation() {
        TenderLocationPrePopulationHandlerTestSetup testSetup = new TenderLocationPrePopulationHandlerTestSetup().generateData();
        Id expectedLocationManager = testSetup.createLocationWithLocationManagerAndRelatedLineItems();

        Test.startTest();
            insert testSetup.tenderLocations;
        Test.stopTest();
        
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = [SELECT AITM_Credit_Days__c, OwnerId, AITM_Invoice_Frequency__c, AITM_Unit_Of_Measure__c, AITM_Location_Manager__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender__c = :testSetup.tender.Id];
        for (Integer index = 0; index < tenderLocationLineItems.size(); index++) {
            //System.assertEquals(expectedLocationManager, tenderLocationLineItems[index].AITM_Location_Manager__c);
        }
    }

    /**
    * @description This method is used to populate Tender Location handler test data setup.
    * @param No Parameters
    * @return Returns Tender Account
    */
    private class TenderLocationPrePopulationHandlerTestSetup extends AITM_TestSetup {
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;

        public TenderLocationPrePopulationHandlerTestSetup generateData(){
            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;

            locations = [SELECT Id, OwnerId, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Delivery_Point__c FROM AITM_Location__c WHERE Id IN :locations];

            tender = createTender();
            insert tender;
			
            createTenderAccounts();
            return this;
        }

        /**
        * @description This method is used to Create Tender Location Line Items test data
        * @param No Parameters
        * @return void
        */
        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
            for (AITM_Tender_Location_Line_Item__c tenderLocation : tenderLocations) {
                tenderLocation.AITM_Unit_Of_Measure__c = null;
                tenderLocation.AITM_Delivery_Point__c = null;
                tenderLocation.AITM_Invoice_Frequency__c = 'Daily';
            }
        }

        /**
        * @description This method is used to Create Locations with Location Manger and Related Line Items test data.
        * @param No Paramaters
        * @return Returns LocationManager Id
        */
        public Id createLocationWithLocationManagerAndRelatedLineItems() {
            AITM_Location__c locationWithLM = locations[1];
             AITM_Location_Manager__c locationManager = new AITM_Location_Manager__c(
                AITM_Sector__c = tender.AITM_Tender_Sector__c, 
                AITM_Location_Manager__c = UserInfo.getUserId(),
                AITM_Location__c = locationWithLM.Id
            ); 

            insert locationManager;

            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locationWithLM});
            for (AITM_Tender_Location_Line_Item__c tenderLocation : tenderLocations) {
                tenderLocation.AITM_Unit_Of_Measure__c = null;
                tenderLocation.AITM_Delivery_Point__c = null;
            }

            return locationManager.Id;
        }
        /**
        * @description This method is used to Create Tender Accounts test data
        * @param No Parameters
        * @return void
        */
        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }
    }

}