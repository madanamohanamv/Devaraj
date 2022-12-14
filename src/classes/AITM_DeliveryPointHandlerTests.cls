@isTest private class AITM_DeliveryPointHandlerTests {
    @isTest 
    static void testDefaultValueChangesAfterNewDefaultAssigned() {
        DeliveryPointHandlerTestSetup testSetup = new DeliveryPointHandlerTestSetup();
		testSetup.generateData();
		
		Integer newDefault = 2;

        Test.startTest();
			AITM_Delivery_Point__c deliveryPointNewDefault = testSetup.deliveryPoints[newDefault];
			deliveryPointNewDefault.AITM_Default__c = true;
			update deliveryPointNewDefault;
        Test.stopTest();

        List<AITM_Delivery_Point__c> deliveryPointsUpdated = [SELECT Name, Id, AITM_Default__c FROM AITM_Delivery_Point__c WHERE AITM_Location__c = :testSetup.locations[0].Id ORDER BY Name ASC];
    	
    	Integer index = 0;
    	for(AITM_Delivery_Point__c deliveryPoint : deliveryPointsUpdated) {
    		if(deliveryPoint.Name == 'TESTNAME-' + newDefault){
    			System.assertEquals(true, deliveryPointsUpdated[index].AITM_Default__c);
    		}else {
    			System.assertEquals(false, deliveryPointsUpdated[index].AITM_Default__c);
    		}
    		index++;
    	}
    }

    private class DeliveryPointHandlerTestSetup extends AITM_TestSetup {
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Delivery_Point__c> deliveryPoints;
        public final Integer ITEMS_COUNT = 10;

        public DeliveryPointHandlerTestSetup(){
        	locations = new List<AITM_Location__c>();
        }

        public void generateData() {
            locations = createLocations(ITEMS_COUNT);
            insert locations;
            tender = createTender();
            insert tender;
            deliveryPoints = createDeliveryPoints(ITEMS_COUNT);
            System.debug(deliveryPoints);
            insert deliveryPoints;
        }

        public List<AITM_Delivery_Point__c> createDeliveryPoints(Integer size) {
	        List<AITM_Delivery_Point__c> result = new List<AITM_Delivery_Point__c>();
	        for (Integer index = 0; index < size; index++) {
	            AITM_Delivery_Point__c iterationDeliveryPoint = createDeliveryPoint(locations[0], false, index);
	            result.add(iterationDeliveryPoint);
	        }
	        return result;
	    }


    }
}