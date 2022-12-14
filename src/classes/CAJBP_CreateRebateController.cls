/**
 * @author			Jan Majling
 * @date			07/09/2018
 * @group			CAJBP
 * @description		controller for lightning component CAJBP_CreateRebate
 *
 * history
 * 07/09/2018	Jan Majling			Created 
 */
public with sharing class CAJBP_CreateRebateController {
	/**
	 * @description gets map of CAJBP_Rebate__c record types except master record type
	 * @return Map<Id,String>
	 */
	@AuraEnabled
	public static Map<Id,String> getRecordTypesWithoutMaster() {
		Map<Id,String> recordTypesById = new Map<Id,String>();
		Map<Id,Schema.RecordTypeInfo> recordTypeInfosById = CAJBP_Rebate__c.SObjectType.getDescribe().getRecordTypeInfosById(); 
		for(Id recordTypeId : recordTypeInfosById.keySet()) {
			RecordTypeInfo recordTypeInfo = recordTypeInfosById.get(recordTypeId);
			if(recordTypeInfo.isMaster()) {
				continue;
			}
			recordTypesById.put(recordTypeId, recordTypeInfo.getDeveloperName());
		}
		return recordTypesById;
	}
}