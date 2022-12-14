trigger AITM_Tender on AITM_Tender__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	if(AITM_DeactivateTriggerSetting__c.getInstance() != null && !AITM_DeactivateTriggerSetting__c.getInstance().AITM_IsActive__c) {
        return;
    }
    AITM_TriggerFactory factory = new AITM_TriggerFactory(AITM_Tender__c.sObjectType);
    factory.execute();
}