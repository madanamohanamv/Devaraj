public with sharing class AITM_DeliveryPointHandler implements AITM_TriggerFactory.SObjectHandler {
    private HandlerRepository handlersStorage;

    public AITM_DeliveryPointHandler() {
        handlersStorage = new HandlerRepository();
        handlersStorage.register(new DeliveryPointChangeDefault());
    }   

    public void bulkBefore() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkBefore();
        }
    }

    public void bulkAfter() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkAfter();
        }
    }

    public void beforeInsert(SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeInsert(so);
        }
    }

    public void beforeUpdate(SObject oldSo, SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeUpdate(oldSo, so);
        }
    }

    public void beforeDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeDelete(so);
        }
    }

    public void afterInsert(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterInsert(so);
        }
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterUpdate(oldSo, so);
        }
    }

    public void afterDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterDelete(so);
        }
    }

    public void andFinally() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.andFinally();
        }
    }

    private class HandlerRepository implements AITM_TriggerFactory.HandlerRepository {
        private List<AITM_TriggerFactory.SObjectHandler> handlers;

        public HandlerRepository() {
            handlers = new List<AITM_TriggerFactory.SObjectHandler>();
        }

        public void register(AITM_TriggerFactory.SObjectHandler handler) {
            handlers.add(handler);
        }
        
        public List<AITM_TriggerFactory.SObjectHandler> handlers() {
            return handlers;
        }
    }

    private class DeliveryPointChangeDefault implements AITM_TriggerFactory.SObjectHandler {
    	private List<Id> locationIds;
    	private Set<Id> currentDeliveryPointIds;
    	private List<AITM_Delivery_Point__c> deliveryPointsToUpdate;

        public DeliveryPointChangeDefault() {
        	locationIds = new List<Id>();
        	currentDeliveryPointIds = new Set<Id>();
        	deliveryPointsToUpdate = new List<AITM_Delivery_Point__c>();
        }

        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){
            AITM_Delivery_Point__c deliveryPoint = (AITM_Delivery_Point__c) so;
            collectLocationIdsOnSetDefaultValue(deliveryPoint, null);
            currentDeliveryPointIds.add(deliveryPoint.Id);
        }
        public void beforeUpdate(SObject oldSo, SObject so){
        	AITM_Delivery_Point__c deliveryPoint = (AITM_Delivery_Point__c) so;
        	AITM_Delivery_Point__c deliveryPointOld = (AITM_Delivery_Point__c) oldSo;
            collectLocationIdsOnSetDefaultValue(deliveryPoint, deliveryPointOld);
        	currentDeliveryPointIds.add(deliveryPoint.Id);
        }
        public void beforeDelete(SObject so){}

        public void afterInsert(SObject so){}

        public void afterUpdate(SObject oldSo, SObject so){}

        public void afterDelete(SObject so){}

        public void andFinally() {
        	if(locationIds.size() > 0){
        		for(AITM_Delivery_Point__c deliveryPoint : [SELECT Id, AITM_Default__c FROM AITM_Delivery_Point__c WHERE AITM_Location__c IN :locationIds AND Id NOT IN :currentDeliveryPointIds]){
        			if(deliveryPoint.AITM_Default__c == true){
        				deliveryPoint.AITM_Default__c = false;
        				deliveryPointsToUpdate.add(deliveryPoint);
        			}
        		}
        	}
        	if(deliveryPointsToUpdate.size() > 0) {
        		update deliveryPointsToUpdate;
        	}
        }

        public void collectLocationIdsOnSetDefaultValue(AITM_Delivery_Point__c deliveryPoint, AITM_Delivery_Point__c deliveryPointOld) {
            if((deliveryPoint.AITM_Default__c && deliveryPointOld == null) || (deliveryPoint.AITM_Default__c && !deliveryPointOld.AITM_Default__c)) {
                locationIds.add(deliveryPoint.AITM_Location__c);
            }
        }

    }


}