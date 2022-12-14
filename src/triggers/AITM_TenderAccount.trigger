trigger AITM_TenderAccount on AITM_Tender_Account__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	if(AITM_DeactivateTriggerSetting__c.getInstance() != null && !AITM_DeactivateTriggerSetting__c.getInstance().AITM_IsActive__c) {
        return;
	}
    AITM_TriggerFactory factory = new AITM_TriggerFactory(AITM_Tender_Account__c.sObjectType);
    factory.execute();
}