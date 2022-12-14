/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_TenderOfferPDFController

 * history
 * 01/December/2017      George       Created
 * 04/September/2018     Anusha       Modified - added method level comments as per coding standards
 *******************************************************************/
@IsTest 
private class AITM_LogTests {

	/**
     * @description tests to create logs
     * @param  null
     * @return void
     */
	@isTest  
	static void checkIfLogCreatesARecord() {

		Test.startTest();
			try {
				Account account = new Account();
				insert account;
			} catch(Exception e) {
				AITM_Log.createErrorMessage(e.getMessage());
			}
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM AITM_Log__c LIMIT 100]);
	}

}