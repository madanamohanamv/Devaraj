/**
 * @author			Jan Majling
 * @date			09/09/2018
 * @group			CAJBP
 * @description		test class for CAJBP_CreateRebateController
 *
 * history
 * 09/09/201	Jan Majling			Created 
 */
@isTest
private class CAJBP_CreateRebateControllerTest {
	@isTest static void testGetRecordTypesWithoutMaster() {
		Set<Id> recordTypeIds = CAJBP_Rebate__c.SObjectType.getDescribe().getRecordTypeInfosById().keySet();

		Map<Id,String> recordTypesByIds;
		Test.startTest();
		recordTypesByIds = CAJBP_CreateRebateController.getRecordTypesWithoutMaster();
		Test.stopTest();

		for(Id recordTypeId : recordTypesByIds.keySet()) {
			recordTypeIds.remove(recordTypeId);
		}

		System.assertEquals(1, recordTypeIds.size(), 'RecordTypeIds should contain only master record type.');
	}
}