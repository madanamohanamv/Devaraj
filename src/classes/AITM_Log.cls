/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Trigger handler class for TenderLocationsStaging
 
 * history
 * 01/December/2017  George       Created
 * 23/Aug/2018       Shweta       Modified-Added with sharing keyword and cooments for each method
 **********************************************************************************************/

public with sharing class AITM_Log {

   /**
    * @description createerror message in logs
    * @param errorMessage of type String
    * @return void
    */	

	public static void createErrorMessage(String errorMessage) {
		AITM_Log__c log = new AITM_Log__c(
			AITM_Description__c = errorMessage
		);
		insert log;
	}

}