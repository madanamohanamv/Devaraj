/**************************************************************************
 * @author           Ravi
 * @date             14/Feb/2019
 * @group            AirBP
 * @description      Test class for AITM_TenderOfferExcelController

 * history
 * 14/Feb/2019  Ravi      Created AR-871
 *******************************************************************/
@isTest 
public class AITM_TenderOfferExcelControllerTests {

	public static final String PAGE_URL = '/apex/AITM_TenderOfferXLS?id=';

    /**
     * @description tests to verify initialization of record results on Line items with Debrief records
     * @param  null
     * @return void
     */

	@isTest 
    static void testXLSContent() {
		TenderOfferExcelControllerTestsSetup testSetup = new TenderOfferExcelControllerTestsSetup().generateData();
		testSetup.createTenderLocationLineItems();

		Test.StartTest();
	        PageReference pageRef = Page.AITM_TenderOfferXLS;
	        Test.setCurrentPage(pageRef);
	      	ApexPages.currentPage().getParameters().put('id', testSetup.tender.Id);
	        AITM_TenderOfferExcelController.XLSContent xlsContent = new AITM_TenderOfferExcelController.XLSContent(testSetup.tender.Id);
		Test.StopTest();

            System.assertEquals(null, xlsContent.headerRow);
		    System.assertNotEquals(null, xlsContent.data);

    }

    /**
     * @description generates the test data for account, Location, Tender, TenderLocation, 
     * TenderLocationLineItem for the test class
     * @param  null
     * @return TenderOfferExcelControllerTestsSetup
     */	 

	private class TenderOfferExcelControllerTestsSetup extends AITM_TestSetup {

		public AITM_TenderOfferExcelControllerTests classUnderTest;
		public List<Account> accounts;
		public List<AITM_Location__c> locations;
		public AITM_Tender__c tender;
		public List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
		public List<AITM_Tender_Location__c> tenderLocations;
		public List<User> locationManagers;
		public AITM_Pricing_Basis__c pricingBasis;
		public final Integer ITEMS_COUNT = 10;
        private final ID TLLI_ID_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();

		public TenderOfferExcelControllerTestsSetup generateData(){

			classUnderTest = new AITM_TenderOfferExcelControllerTests();

			accounts = createAccounts(ITEMS_COUNT);
			insert accounts;

			locations = createLocations(ITEMS_COUNT);
			for(AITM_Location__c location : locations){
				location.AITM_Country__c = 'Spain';
			}
			insert locations;

			tender = createTender();
			tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
			tender.AITM_Density__c = '331';
			tender.AITM_Stage__c = 'Awaiting Price';
			insert tender;

			createTenderAccounts();

			locationManagers = createUsers(ITEMS_COUNT, 'Air_TMLocation Manager');
			insert locationManagers;

			tenderLocations = createTenderLocations();
			insert tenderLocations;

			pricingBasis = createPricingBasis();
			insert pricingBasis;

			attachLocationManagersToTenderLocations(locationManagers, tenderLocations);

			return this;
		}

        /**
         * @description creates the test data for TenderLocations 
         * @param  null
         * @return List collection of AITM_Tender_Location__c
         */

		public List<AITM_Tender_Location__c> createTenderLocations() {
			List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
			for(AITM_Location__c location : locations){
				tenderLocations.add(
					createTenderLocation(tender.Id, location.Id)
					);
			}
			return tenderLocations;
		}

        /**
         * @description creates the test data for Pricing Basis 
         * @param  null
         * @return List collection of AITM_Pricing_Basis__c
         */

		public AITM_Pricing_Basis__c createPricingBasis(){
			return new AITM_Pricing_Basis__c(
				Name = 'P008',
				AITM_Description__c = 'Barges FOB Rotterdam High Prior Month WD',
				AITM_Currency__c = 'USD',
				AITM_Unit_Of_Measure__c = 'USG'
				);
		}

        /**
         * @description creates the test data to attach Location managers to Tender Locations 
         * @param  null
         * @return List collection of AITM_Location_Manager__c
         */

		public void attachLocationManagersToTenderLocations(List<User> locationManagers, List<AITM_Tender_Location__c> tenderLocations) {

			List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
			Integer index = 0;

			for(AITM_Tender_Location__c tenderLocation : tenderLocations){
				tenderLocation.AITM_Location_Manager__c = locationManagers[index].Id;
				result.add(tenderLocation);
				index++;
			}

			upsert result;

		}

        /**
         * @description creates the test data for Tender Accounts 
         * @param  null
         * @return List collection of AITM_Tender_Account__c
         */

		public void createTenderAccounts() {
			insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
		}

        /**
         * @description creates test data list of TenderLocationLineItems 
         * @param  null
         * @return void
         */

		public void createTenderLocationLineItems() {
			tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
			insert tenderLocationLineItems;
		}

        /**
         * @description creates test data for TenderLocationLineItem 
         * @param tenderId of type Id
         * @param accountId of type Id
         * @param locationId of type Id
         * @param tenderLocationId of type Id
         * @return AITM_Tender_Location_Line_Item__c
         */

		public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
			return new AITM_Tender_Location_Line_Item__c(
				AITM_Tender__c = tenderId,
				AITM_Account__c = accountId,
				AITM_Location__c = locationId,
				AITM_Start_Date__c = Date.today(),
				AITM_Tender_Location__c = tenderLocationId,
				AITM_End_Date__c = Date.today().addYears(1),
				AITM_Volume__c = 1.0,
				AITM_Requested_Volume_USG__c = 1,
				AITM_Tender_Result__c = 'BG',
				AITM_Currency__c = 'USD',
				AITM_Unit_Of_Measure__c = 'USG',
				AITM_Credit_Days__c = '3',
				AITM_Offered_Differential__c = 12
				);
		}
	}
}