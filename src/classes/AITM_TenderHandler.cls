/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Trigger handler for Tender

 * history
 * 01/December/2017  George          Created
 * 21/March/2018     srnandan        Modified - AR- 2729 - modified method "notifyRelatedTenderLocations"
 *                                   by adding boolean flag - "isMessageSent" to control chatter notifications per tender.
 *                                   Also added comments at method and class level as per coding standards
 * 22/March/2018     srnandan        Modified - AR - 2773 - modified methods "updateRelatedTenderLocationFeedback","afterUpdate"
 *                                   added new method "updateRelatedTenderLocationOfferedDiffFeedback" and variable "tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback"
 *                                   for the functionality to assign value of minimum offered differential tenderlineitems each location
 * 17/Aug/2018       Shweta          Modified for sonar qube fixes (Added with sharing )
 * 11/December/2018  srnandan        Modified - AR-4624 debrief clone records logic moved to trigger from flow
 * 23/January/2019   srnandan        Modified - AR-4913 to include taxes and fees related fields for debrief record 
 * 12/March/2019     Shweta          Modified - AR-5078 - Deleting a Tender not deleting the Tender Location Line Item
 * 02/April/2019	 Ravi 			 Modified - AR-5028 - Populating Product and Product Specification from TLLI to Debrief record type in method cloneDebriefRecords
 *************************************************************************************/
public with sharing class AITM_TenderHandler implements AITM_TriggerFactory.SObjectHandler {
    private AITM_TriggerFactory.HandlerRepository handlersStorage;
      public static Boolean check = false;

    /**
     * @description constructor to initialize and register handlerrepository
     */
    public AITM_TenderHandler() {
        handlersStorage = new HandlerRepository();
        handlersStorage.register(new TenderInvitationalEmailInvoker());
        handlersStorage.register(new TenderNewRoundStarter());
        handlersStorage.register(new TenderDeleteRelatedLineItems());
        handlersStorage.register(new TenderLocationChatterNotificationHandler());
        handlersStorage.register(new TenderLocationUpdateFeedbackInformation());
        handlersStorage.register(new TenderLocationUpdateNewRoundWhenTenderIsProceedingToNewRound());
        handlersStorage.register(new TenderLocationLineItemDebriefClone());
    }

    /**
     * @description bulk before factory method operation SObject handler
     * @param null
     * @return null
     */
    public void bulkBefore() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkBefore();
        }
    }

    /**
     * @description bulk after factory method operation SObject handler
     * @param null
     * @return null
     */
    public void bulkAfter() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.bulkAfter();
        }
    }

    /**
     * @description before insert operation of trigger event
     * @param so of type SObject
     * @return null
     */
    public void beforeInsert(SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeInsert(so);
        }
    }

    /**
     * @description before update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return null
     */
    public void beforeUpdate(SObject oldSo, SObject so){
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeUpdate(oldSo, so);
        }
    }

    /**
     * @description before delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return null
     */
    public void beforeDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.beforeDelete(so);
        }
    }

    /**
     * @description after insert operation of trigger event
     * @param so of type SObject to hold new values
     * @return null
     */
    public void afterInsert(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterInsert(so);
        }
    }

    /**
     * @description after update operation of trigger event
     * @param oldSo of type SObject to hold old values
     * @param so of type SObject to hold new values
     * @return null
     */
    public void afterUpdate(SObject oldSo, SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterUpdate(oldSo, so);
        }
    }

    /**
     * @description after delete operation of trigger event
     * @param so of type SObject to hold new values
     * @return null
     */
    public void afterDelete(SObject so) {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.afterDelete(so);
        }
    }

    /**
     * @description finally block method called for trigger event
     * @param null
     * @return null
     */
    public void andFinally() {
        for (AITM_TriggerFactory.SObjectHandler concreteHandler : handlersStorage.handlers()) {
            concreteHandler.andFinally();
        }
    }

    /**
     * @description class implementing HandlerRepository interface
     */
    private class HandlerRepository implements AITM_TriggerFactory.HandlerRepository {
        private List<AITM_TriggerFactory.SObjectHandler> handlers;

        /**
         * @description default constructor of handlerrepository class
         */
        public HandlerRepository() {
            handlers = new List<AITM_TriggerFactory.SObjectHandler>();
        }

        /**
         * @description registers/adds SObject handler to collection
         * @param handler of type AITM_TriggerFactory.SObjectHandler
         * @return null
         */
        public void register(AITM_TriggerFactory.SObjectHandler handler) {
            handlers.add(handler);
        }
        
        /**
         * @description returns list collection of SObjectHandler
         * @param null
         * @return List collection of type AITM_TriggerFactory.SObjectHandler
         */
        public List<AITM_TriggerFactory.SObjectHandler> handlers() {
            return handlers;
        }
    }

    /**
     * @description class which invokes chatter InvitationEmail
     */
    private class TenderInvitationalEmailInvoker implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_AWAITING_PRICE = 'Awaiting Price';
        private Set<Id> tenderIdsRequiredToBeNotified;

        /**
         * @description constructor to initialize set collection tenderIdsRequiredToBeNotified
         */
        public TenderInvitationalEmailInvoker() {
            tenderIdsRequiredToBeNotified = new Set<Id>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;

            if (this.notificationRequired(tender, oldTender)) {
                this.addToNotificationList(tender);
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block called for trigger handler 
         * @param null
         * @return null
         */
        public void andFinally() {
            this.sendNotificationEmails();
        }

        /**
         * @description returns true when sendinvitationnotification value changed to true 
         * and stage is awaitingprice
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */
        private Boolean notificationRequired(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            return !oldTender.AITM_Send_Invitation_Notification__c 
                && tender.AITM_Send_Invitation_Notification__c
                && tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
        }

        /**
         * @description adds notification to list collection
         * and stage is awaitingprice
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void addToNotificationList(AITM_Tender__c tender) {
            tender.AITM_Send_Invitation_Notification__c = false;
            tenderIdsRequiredToBeNotified.add(tender.Id);            
        }

        /**
         * @description sends notification emails
         * @param null
         * @return null
         */
        private void sendNotificationEmails() {
            if (tenderIdsRequiredToBeNotified.size() > 0) {
                List<Id> notificationTenderIdAsList = new List<Id>(tenderIdsRequiredToBeNotified);
                AITM_InvitationEmailGenerator.Generator emailCreator = new AITM_InvitationEmailGenerator.Generator(notificationTenderIdAsList[0]);
                AITM_BaseUtils.sendEmails(emailCreator.generateTenderInvitationEmailsBulk(notificationTenderIdAsList));                
            }
        }        
    }

    /**
     * @description class holds tender rounds
     */
    private class TenderNewRoundStarter implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_AWAITING_PRICE = 'Awaiting Price';
        private final String STAGE_FEEDBACK = 'Feedback and Negotiation';

        /**
         * @description default constructor
         */
        public TenderNewRoundStarter() {}

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;

            if (this.newRoundRequiredToBeStarted(tender, oldTender)) {
                this.startNewRound(tender);
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so){}

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {}

        /**
         * @description checks round required to be started
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */
       private Boolean newRoundRequiredToBeStarted(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            //TO DO Need to check multiple locations           
            AITM_TenderDao tenderInstance = new AITM_TenderDao();
            Map<String,Boolean> mapMultipleLocations = tenderInstance.multipleLocations(tender.Id);
            Set<String> TENDER_STAGE = new Set<String>{'Priced','Awaiting Price','Offer Submitted'};
            if(mapMultipleLocations.size() > 1) {
                 check = oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && tender.AITM_Send_Feedback_Notification__c
                  && tender.AITM_Send_LABP_Feedback_Notification__c
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
                                  
                if(check == false && oldTender.AITM_Stage__c == STAGE_FEEDBACK && !TENDER_STAGE.contains(tender.AITM_Stage__c)){
                   tender.AITM_Stage__c = STAGE_FEEDBACK ;             
                }
                if(tender.AITM_No_Feedback_Progress_To_De_Brief__c && oldTender.AITM_Stage__c == STAGE_FEEDBACK){
                    tender.AITM_Stage__c = 'Debrief';   
                }
              return check;
            } else {           
                  check = tender.AITM_Stage__c != oldTender.AITM_Stage__c 
                  && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && (mapMultipleLocations.containsKey('NonPolish') ? tender.AITM_Send_Feedback_Notification__c : tender.AITM_Send_LABP_Feedback_Notification__c)
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
                return check;
                  
            }
        }


        /**
         * @description starts new round for tender
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void startNewRound(AITM_Tender__c tender) {
            //reset flags both feedback and feedbackpolish
            tender.AITM_Stage__c = STAGE_AWAITING_PRICE;
            tender.AITM_Offer_Sent_To_A_Customer__c = false;           
            tender.AITM_Send_Feedback_Notification__c = false;
            tender.AITM_Send_LABP_Feedback_Notification__c = false;
        }
    }

    /**
     * @description acts as ChatterNotificationHandler for TenderLocation
     */
    private @TestVisible class TenderLocationChatterNotificationHandler implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_AWAITING_PRICE = 'Awaiting Price';
        private @TestVisible Set<Id> tenderIdsLocationsOfWhichShouldBeNotified;

        /**
         * @description default constructor to initialize set collection tenderIdsLocationsOfWhichShouldBeNotified
         */
        public TenderLocationChatterNotificationHandler() {
            tenderIdsLocationsOfWhichShouldBeNotified = new Set<Id>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so) {            
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;
                    
            if (this.notificationRequired(tender, oldTender, false)) {
                this.notifyRelatedTenderLocations(tender);
            }
        }

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so){
            AITM_Tender__c tender = (AITM_Tender__c) so;

            if (this.notificationRequired(tender)) {
                this.notifyRelatedTenderLocations(tender);
            }
        }

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;

            if (this.notificationRequired(tender, oldTender)) {
                this.notifyRelatedTenderLocations(tender);
            }
        }

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {
            this.notifyRelatedTenderLocations();
        }

        /**
         * @description returns true when stage changed to awaiting price
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */
        private Boolean notificationRequired(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            return tender.AITM_Stage__c != oldTender.AITM_Stage__c
                && tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
        }

        /**
         * @description returns true when tender stage is awaiting price and send invitation is true
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @param tender of type boolean
         * @return boolean
         */
        private Boolean notificationRequired(AITM_Tender__c tender, AITM_Tender__c oldTender, Boolean forBeforeUpdate) {
            return !oldTender.AITM_Send_Invitation_Notification__c 
                && tender.AITM_Send_Invitation_Notification__c
                && tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
        }

        /**
         * @description sets the stage for notification required criteria
         * @param tender of type AITM_Tender__c
         * @return boolean
         */
        private Boolean notificationRequired(AITM_Tender__c tender) {
            return tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
        }

        /**
         * @description notify related tenderlocations adding to collection for the tender
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void notifyRelatedTenderLocations(AITM_Tender__c tender) {
            tenderIdsLocationsOfWhichShouldBeNotified.add(tender.Id);
        }

        /**
         * @description notifies related tenderlocations posting to chatter
         * @param null
         * @return List collection of ConnectApi.BatchInput
         */
        private @TestVisible List<ConnectApi.BatchInput> notifyRelatedTenderLocations() {
            List<ConnectApi.BatchInput> chatterMessages = new List<ConnectApi.BatchInput>();
            Boolean isMessageSent = false;
            if (tenderIdsLocationsOfWhichShouldBeNotified.size() > 0) {
                for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsLocationsOfWhichShouldBeNotified)) {
                    if (tenderLocation.AITM_Status__c == STAGE_AWAITING_PRICE) {
                        if(!isMessageSent) {
                            chatterMessages.add(this.generateChatterMessage(tenderLocation));
                            isMessageSent = true;
                        }    
                    }
                }
                AITM_BaseUtils.postToChatter(chatterMessages);
            }
            return chatterMessages;
        }
        
        /**
         * @description generates chatter message for a tenderlocation
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return ConnectApi.BatchInput
         */
        private ConnectApi.BatchInput generateChatterMessage(AITM_Tender_Location__c tenderLocation) {
            return AITM_BaseUtils.createChatterMessageWithMention(
                tenderLocation.AITM_Tender__c, 
                tenderLocation.AITM_Location_Manager__c, 
                this.getNotificationMessage(tenderLocation)
            );
        }

        /**
         * @description gets notification message for a tenderlocation
         * @param tenderLocation of type AITM_Tender_Location__c
         * @return string
         */
        private String getNotificationMessage(AITM_Tender_Location__c tenderLocation){
            String text = 'The tender \'' + tenderLocation.AITM_Tender__r.Name + '\' is now in ' + tenderLocation.AITM_Status__c + ' stage. \n';
            if(tenderlocation.AITM_Country__c != null && tenderlocation.AITM_Country__c.toUpperCase() == AITM_LocationsDao.POLISH_COUNTRY) {
                //string prefix = 'labptendering';
                //text += 'For more details go here: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + prefix + '/' + tenderLocation.AITM_Tender__c;
                text += 'For more details go here: ' + AITM_BaseUtils.getLABPURL() + '/' + tenderLocation.AITM_Tender__c;
            } else {
                //text += 'For more details go here: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + tenderLocation.AITM_Tender__c;
                text += 'For more details go here: ' + AITM_BaseUtils.getTenderingURL() + '/' + tenderLocation.AITM_Tender__c;
            }
            return text;
        }
    }

    /**
     * @description class holds information to update Feedback for tenderlocation
     */
    private class TenderLocationUpdateFeedbackInformation implements AITM_TriggerFactory.SObjectHandler { 
        private Map<Id, AITM_Tender__c> tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback;
        private Map<Id, AITM_Tender__c> tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback;
        private final String STAGE_FEEDBACK = 'Feedback and Negotiation';
        
        /**
         * @description default constructor
         */ 
        public TenderLocationUpdateFeedbackInformation() {
            tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback = new Map<Id, AITM_Tender__c>();
            tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback = new Map<Id,AITM_Tender__c>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so){}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @returnnull
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so){}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;
            
            if (this.feedbackUpdateRequired(tender, oldTender)) {
                this.updateRelatedTenderLocationFeedback(tender);
            } else if(tender.AITM_Stage__c == STAGE_FEEDBACK) {
                this.updateRelatedTenderLocationOfferedDiffFeedback(tender);
            }
        }

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {
            this.updateRelatedTenderLocationFeedback();
        }

        /**
         * @description checks feedback update is required
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */
        private Boolean feedbackUpdateRequired(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            return tender.AITM_Quality_Of_Feedback__c != oldTender.AITM_Quality_Of_Feedback__c 
                || tender.AITM_Last_Look_To_Incumbent__c != oldTender.AITM_Last_Look_To_Incumbent__c 
                || tender.AITM_Number_Of_Rounds__c != oldTender.AITM_Number_Of_Rounds__c;
        }

        /**
         * @description map collection to update feedback for related tender
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void updateRelatedTenderLocationFeedback(AITM_Tender__c tender) {
            tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.put(tender.Id, tender);
        }

        /**
         * @description map collection to update feedback for related tender offered differential
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void updateRelatedTenderLocationOfferedDiffFeedback(AITM_Tender__c tender) {
            tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.put(tender.Id, tender);
        }
        /**
         * @description updates feedback and number of rounds for tenderlocations
         * @param null
         * @return null
         */
        private void updateRelatedTenderLocationFeedback() {
			System.debug('inside updateRelatedTenderLocationFeedback');
            List<AITM_Tender_Location__c> tenderLocations = null;
            if(tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.size() > 0) {
                    tenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.keySet());
                }else {
                    tenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.keySet());
                }
            
            Map<Id, AggregateResult> tenderLocationAggregateResult = new AITM_LocationsDao().getMinimumOfferedDifferentialTenderLocationLineItems(tenderLocations);
            if(tenderLocations != null) {
                for (AITM_Tender_Location__c tenderLocation : tenderLocations) {
                    if(!tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.isEmpty()) {
                        AITM_Tender__c tender = tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.get(tenderLocation.AITM_Tender__c); 
                        if(tender != null) {
                        	tenderLocation.AITM_Quality_Of_Feedback__c = tender.AITM_Quality_Of_Feedback__c;
                        	tenderLocation.AITM_Last_Look_To_Incumbent__c = tender.AITM_Last_Look_To_Incumbent__c;
                        	tenderLocation.AITM_Number_Of_Rounds__c = tender.AITM_Number_Of_Rounds__c;
                        }
                    }   
    
                    if(tenderLocationAggregateResult != null && tenderLocationAggregateResult.size() > 0 && tenderLocationAggregateResult.get(tenderLocation.Id) != null && tenderLocationAggregateResult.get(tenderLocation.Id).get('MINIMUMOFFEREDDIFFERENTIAL') != null) {
                        tenderLocation.AITM_Offered_Differential__c = (Decimal)tenderLocationAggregateResult.get(tenderLocation.Id).get('MINIMUMOFFEREDDIFFERENTIAL');
                    }
                }
            
               Database.update(tenderLocations, false);
           }
           
        }
    }

    /**
     * @description class holds information to update NewRound for tenderlocation
     */
    private class TenderLocationUpdateNewRoundWhenTenderIsProceedingToNewRound implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_FEEDBACK = 'Feedback and Negotiation';

        private Set<Id> tenderIdsToChangeRelatedTenderLocationsRound;

        /**
         * @description default constructor
         */
        public TenderLocationUpdateNewRoundWhenTenderIsProceedingToNewRound() {
            tenderIdsToChangeRelatedTenderLocationsRound = new Set<Id>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so){}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;

            if (this.newRoundRequiredToBeStarted(tender, oldTender)&& check) {
                this.changeRoundForTenderLocations(tender);
            }
        }

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {
            this.changeRoundForTenderLocations();
        }

        /**
         * @description new round required to start for tender
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */        
        private Boolean newRoundRequiredToBeStarted(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            AITM_TenderDao tenderInstance = new AITM_TenderDao();
            Map<String,Boolean> mapMultipleLocations = tenderInstance.multipleLocations(tender.Id);
            if(mapMultipleLocations.size() > 1) {
                return tender.AITM_Stage__c != oldTender.AITM_Stage__c 
                  && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
            } else {
               return tender.AITM_Stage__c != oldTender.AITM_Stage__c 
                  && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
            }
        }

        /**
         * @description changes round for tenderlocations for given tender
         * @param tender of type AITM_Tender__c
         * @return null
         */
        private void changeRoundForTenderLocations(AITM_Tender__c tender) {
            tenderIdsToChangeRelatedTenderLocationsRound.add(tender.Id);
        }

        /**
         * @description updates current round for tenderlocations
         * @param null
         * @return null
         */
        private void changeRoundForTenderLocations() {
            if (tenderIdsToChangeRelatedTenderLocationsRound.size() > 0) {
                List<AITM_Tender_Location__c> tenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsToChangeRelatedTenderLocationsRound);
                for (AITM_Tender_Location__c tenderLocation : tenderLocations) {
                    tenderLocation.AITM_Current_Round__c++;
                }
                 check = false;
                 Database.update(tenderLocations, false);
            }
        }

    }

    /**
     * @description class collects the line items to be deleted
     */
    private class TenderDeleteRelatedLineItems implements AITM_TriggerFactory.SObjectHandler {
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItemsToDelete;

        /**
         * @description default constructor
         */
        public TenderDeleteRelatedLineItems() {            
            this.tenderLocationLineItemsToDelete = new List<AITM_Tender_Location_Line_Item__c>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}
        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}
         /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so){}

         /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){
            AITM_Tender__c deletedTender = (AITM_Tender__c) so;
            tenderLocationLineItemsToDelete =  new AITM_LocationsDao().getTenderLocationLineItemsByTender(deletedTender.Id);
          }

        public void andFinally(){           
                deleteRelatedLineItems();            
         }
        private void deleteRelatedLineItems() {      
                    
            if (tenderLocationLineItemsToDelete.size() > Limits.getLimitDMLRows()){               
               // new AITM_LocationsDao().deleteTenderLocationLineItems(tenderLocationLineItemsToDelete );
                //call apex batch job to delete records
               AITM_DeleteTenderLocationLineItemsBatch.BatchState batchState = new AITM_DeleteTenderLocationLineItemsBatch.BatchState(tenderLocationLineItemsToDelete);
               new AITM_DeleteTenderLocationLineItemsBatch.BatchFactory().executeBatch(batchState);
            }            
        }
         /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so){}
         /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so){}

         /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */        
        public void afterDelete(SObject so) {}  

    }
   
    /**
     * @description class clones debrief line items
     */
    private class TenderLocationLineItemDebriefClone implements AITM_TriggerFactory.SObjectHandler {
        private final String STAGE_DEBRIEF = 'Debrief';
        private final String STAGE_FEEDBACK = 'Feedback and Negotiation';
        private final String DEBRIEF_RECORD_TYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
        private Set<Id> tenderIdsToChangeRelatedTenderLocationsRound;

        /**
         * @description default constructor
         */
        public TenderLocationLineItemDebriefClone() {
            tenderIdsToChangeRelatedTenderLocationsRound = new Set<Id>();
        }

        /**
         * @description bulk before factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkBefore(){}

        /**
         * @description bulk after factory method operation SObject handler
         * @param null
         * @return null
         */
        public void bulkAfter(){}

        /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsert(SObject so){}

        /**
         * @description before update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void beforeUpdate(SObject oldSo, SObject so){}

        /**
         * @description before delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeDelete(SObject so){}

        /**
         * @description after insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterInsert(SObject so) {}

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdate(SObject oldSo, SObject so) {
            AITM_Tender__c tender = (AITM_Tender__c) so;
            AITM_Tender__c oldTender = (AITM_Tender__c) oldSo;
            this.cloneDebriefRecords(tender, oldTender);
        }

        /**
         * @description after delete operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void afterDelete(SObject so){}

        /**
         * @description finally block method called for trigger event
         * @param null
         * @return null
         */
        public void andFinally() {
            
        }

        /**
         * @description insert debrief records from existing line items with default record type
         * @param debriefCreateLineItems of type list collection AITM_Tender_Location_Line_Item__c
         * @param lineItems of type list collection AITM_Tender_Location_Line_Item__c
         * @return void
         */
        private void insertDebriefLineItemRecords(List<AITM_Tender_Location_Line_Item__c> debriefCreateLineItems, List<AITM_Tender_Location_Line_Item__c> lineItems) {
            for(AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                AITM_Tender_Location_Line_Item__c debriefItem = new AITM_Tender_Location_Line_Item__c();
                debriefItem.RecordTypeId = DEBRIEF_RECORD_TYPE_ID;
                debriefItem.OwnerId = lineItem.OwnerId;
                debriefItem.AITM_Account__c = lineItem.AITM_Account__c;
                debriefItem.AITM_Bid_Expiry_Date__c = lineItem.AITM_Bid_Expiry_Date__c;
                debriefItem.AITM_Tender__c = lineItem.AITM_Tender__c;
                debriefItem.AITM_Tender_Location__c = lineItem.AITM_Tender_Location__c;
                debriefItem.AITM_Ad_hoc_Volume__c = lineItem.AITM_Ad_hoc_Volume__c;
                debriefItem.AITM_Currency__c = lineItem.AITM_Currency__c;
                debriefItem.AITM_Current_Value__c = lineItem.AITM_Current_Value__c;
                debriefItem.AITM_Tender_Result__c = lineItem.AITM_Tender_Result__c;
                debriefItem.AITM_Credit_Days__c = lineItem.AITM_Credit_Days__c;
                debriefItem.AITM_Location_Delivery_Point__c = lineItem.AITM_Location_Delivery_Point__c; 
                debriefItem.AITM_Details_Context__c = lineItem.AITM_Details_Context__c;                                        
                debriefItem.AITM_Duration__c = lineItem.AITM_Duration__c;
                debriefItem.AITM_Invoice_Frequency__c = lineItem.AITM_Invoice_Frequency__c; 
                debriefItem.AITM_End_Date__c = lineItem.AITM_End_Date__c;
                debriefItem.AITM_Exchange__c = lineItem.AITM_Exchange__c;
                debriefItem.AITM_Location_Manager__c = lineItem.AITM_Location_Manager__c;
                debriefItem.AITM_Last_Tender_Result__c = lineItem.AITM_Last_Tender_Result__c;
                debriefItem.AITM_Level_Of_Interest__c = lineItem.AITM_Level_Of_Interest__c;
                debriefItem.AITM_Location__c = lineItem.AITM_Location__c; 
                debriefItem.AITM_Offered_Differential__c = lineItem.AITM_Offered_Differential__c;
                debriefItem.AITM_Offered_Volume__c = lineItem.AITM_Offered_Volume__c;
                debriefItem.AITM_Pricing_Basis__c = lineItem.AITM_Pricing_Basis__c;
                debriefItem.AITM_Quantity__c = lineItem.AITM_Quantity__c;
                debriefItem.AITM_Requested_Volume_USG__c = lineItem.AITM_Requested_Volume_USG__c;
                debriefItem.AITM_Requested_Volume_UoM__c = lineItem.AITM_Requested_Volume_UoM__c;
                debriefItem.AITM_Round__c = lineItem.AITM_Round__c;
                debriefItem.AITM_Specification__c = lineItem.AITM_Specification__c;
                debriefItem.AITM_Start_Date__c = lineItem.AITM_Start_Date__c;
                debriefItem.AITM_Tender_Result__c = lineItem.AITM_Tender_Result__c;
                debriefItem.AITM_Unit_Of_Measure__c = lineItem.AITM_Unit_Of_Measure__c;
                debriefItem.AITM_Percentage_Volume_Offered__c = lineItem.AITM_Percentage_Volume_Offered__c;
                debriefItem.AITM_History_Line_Item__c = lineItem.AITM_History_Line_Item__c;                                             
                debriefItem.AITM_Volume__c = lineItem.AITM_Volume__c;
                debriefItem.AITM_Rebate__c = lineItem.AITM_Rebate__c;
                debriefItem.AITM_Tender_Owner_Profile__c = lineItem.AITM_Tender_Owner_Profile__c;
                debriefItem.AITM_Taxes_Fees__c = lineItem.AITM_Taxes_Fees__c;
                debriefItem.AITM_Additional_Notes_Taxes_and_Fees__c = lineItem.AITM_Additional_Notes_Taxes_and_Fees__c;
                debriefItem.AITM_Measure__c = lineItem.AITM_Measure__c;
                debriefItem.AITM_Product_Default__c = lineItem.AITM_Product_Default__c;
                debriefItem.AITM_Product_Specification__c = lineItem.AITM_Product_Specification__c;
                debriefItem.AITM_Include_Taxes_and_Fees_in_Contract__c = lineItem.AITM_Include_Taxes_and_Fees_in_Contract__c;
                debriefItem.AITM_Delivery_Method__c = lineItem.AITM_Delivery_Method__c;
                debriefItem.AITM_Previous_TLLI_Id__c = lineItem.Id;
                debriefCreateLineItems.add(debriefItem);
            }
            lineItems.clear();
            Database.insert(debriefCreateLineItems);
            debriefCreateLineItems = null;
            lineItems = null;
        }

        /**
         * @description new round required to start for tender
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return void
         */        
        private void cloneDebriefRecords(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            
            if(tender.AITM_Stage__c != oldTender.AITM_Stage__c && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && tender.AITM_No_Feedback_Progress_To_De_Brief__c) {
                List<AITM_Tender_Location_Line_Item__c> debriefCreateLineItems = new List<AITM_Tender_Location_Line_Item__c>();
                List<AITM_Tender_Location_Line_Item__c> debriefDeleteLineItems = new List<AITM_Tender_Location_Line_Item__c>();    
                List<AITM_Tender_Location_Line_Item__c> debriefUpdateLineItems = new List<AITM_Tender_Location_Line_Item__c>();    
                List<AITM_Tender_Location_Line_Item__c> lineItems = [SELECT AITM_Account__c, AITM_Start_Date__c, AITM_Bid_Expiry_Date__c, AITM_Tender__c, OwnerId,
                                                                AITM_Tender_Location__c, AITM_Ad_hoc_Volume__c, AITM_Currency__c, AITM_Current_Value__c,
                                                                AITM_Credit_Days__c, AITM_Location_Delivery_Point__c, AITM_Description__c, AITM_Details_Context__c,
                                                                AITM_Duration__c, AITM_Invoice_Frequency__c, AITM_End_Date__c, AITM_Exchange__c,
                                                                AITM_Last_Tender_Result__c, AITM_Level_Of_Interest__c, AITM_Location__c, 
                                                                AITM_Location_Manager__c, AITM_Offered_Differential__c, AITM_Offered_Volume__c, 
                                                                AITM_Pricing_Basis__c, AITM_Quantity__c, AITM_Requested_Volume_USG__c,
                                                                AITM_Requested_Volume_UoM__c, AITM_Round__c, AITM_Specification__c,
                                                                AITM_Tender_Result__c, AITM_Unit_Of_Measure__c, AITM_Previous_TLLI_Id__c,
                                                                AITM_Volume__c, AITM_Rebate__c, AITM_Tender_Owner_Profile__c, AITM_Percentage_Volume_Offered__c, 
                                                                AITM_History_Line_Item__c, AITM_Taxes_Fees__c, AITM_Additional_Notes_Taxes_and_Fees__c, 
                                                                AITM_Measure__c, AITM_Include_Taxes_and_Fees_in_Contract__c, AITM_Product_Specification__c, AITM_Product_Default__c, AITM_Delivery_Method__c
                                                                FROM AITM_Tender_Location_Line_Item__c 
                                                                WHERE AITM_Tender__c = : tender.Id AND AITM_Is_Current_Round__c = true 
                                                                AND AITM_Is_Pricing_Basis_Not_Represented__c = false
                                                                AND RecordTypeId !=:DEBRIEF_RECORD_TYPE_ID];
                List<AITM_Tender_Location_Line_Item__c> debriefLineItems = [SELECT AITM_Account__c, AITM_Start_Date__c, AITM_Bid_Expiry_Date__c, AITM_Tender__c, OwnerId,
                                                                AITM_Tender_Location__c, AITM_Ad_hoc_Volume__c, AITM_Currency__c, AITM_Current_Value__c,
                                                                AITM_Credit_Days__c, AITM_Location_Delivery_Point__c, AITM_Description__c, AITM_Details_Context__c,
                                                                AITM_Duration__c, AITM_Invoice_Frequency__c, AITM_End_Date__c, AITM_Exchange__c,
                                                                AITM_Last_Tender_Result__c, AITM_Level_Of_Interest__c, AITM_Location__c, 
                                                                AITM_Location_Manager__c, AITM_Offered_Differential__c, AITM_Offered_Volume__c, 
                                                                AITM_Pricing_Basis__c, AITM_Quantity__c, AITM_Requested_Volume_USG__c,
                                                                AITM_Requested_Volume_UoM__c, AITM_Round__c, AITM_Specification__c,
                                                                AITM_Tender_Result__c, AITM_Unit_Of_Measure__c, AITM_Previous_TLLI_Id__c,
                                                                AITM_Volume__c, AITM_Rebate__c, AITM_Tender_Owner_Profile__c, AITM_Percentage_Volume_Offered__c, 
                                                                AITM_History_Line_Item__c, AITM_Taxes_Fees__c, AITM_Additional_Notes_Taxes_and_Fees__c, 
                                                                AITM_Measure__c, AITM_Include_Taxes_and_Fees_in_Contract__c, AITM_Product_Specification__c, AITM_Product_Default__c, AITM_Delivery_Method__c 
                                                                FROM AITM_Tender_Location_Line_Item__c 
                                                                WHERE AITM_Tender__c = : tender.Id AND AITM_Is_Current_Round__c = true 
                                                                AND RecordTypeId =:DEBRIEF_RECORD_TYPE_ID];
                
                if(debriefLineItems.isEmpty()) {
                    if(lineItems.size() > 9999) {
                        //call apex batch job
                        //AITM_UploadLocationsBatch.BatchState batchState = new AITM_UploadLocationsBatch.BatchState(lineItems);
                        //new AITM_UploadLocationsBatch.BatchFactory().executeBatch(batchState); 
                    } else {
                        insertDebriefLineItemRecords(debriefCreateLineItems, lineItems);
                        debriefCreateLineItems = null;
                        lineItems = null;
                    }
                } else {
                    Map<Id, AITM_Tender_Location_Line_Item__c> mapDebrief = new Map<Id, AITM_Tender_Location_Line_Item__c>();
                    for(AITM_Tender_Location_Line_Item__c lineItemDebrief : debriefLineItems) {
                        mapDebrief.put(lineItemDebrief.AITM_Previous_TLLI_Id__c, lineItemDebrief);
                    }   
                    
                    Set<Id> removeLineItems = new Set<Id>();
                    for(AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                        if(mapDebrief.containsKey(lineItem.Id)) {
                            AITM_Tender_Location_Line_Item__c lineItemDebrief = mapDebrief.get(lineItem.Id);
                            lineItemDebrief.RecordTypeId = DEBRIEF_RECORD_TYPE_ID;
                            lineItemDebrief.OwnerId = lineItem.OwnerId;
                            lineItemDebrief.AITM_Account__c = lineItem.AITM_Account__c;
                            lineItemDebrief.AITM_Start_Date__c = lineItem.AITM_Start_Date__c;
                            lineItemDebrief.AITM_Bid_Expiry_Date__c = lineItem.AITM_Bid_Expiry_Date__c;
                            lineItemDebrief.AITM_Tender__c = lineItem.AITM_Tender__c;
                            lineItemDebrief.AITM_Tender_Location__c = lineItem.AITM_Tender_Location__c;
                            lineItemDebrief.AITM_Ad_hoc_Volume__c = lineItem.AITM_Ad_hoc_Volume__c;
                            lineItemDebrief.AITM_Currency__c = lineItem.AITM_Currency__c;
                            lineItemDebrief.AITM_Current_Value__c = lineItem.AITM_Current_Value__c;
                            lineItemDebrief.AITM_Credit_Days__c = lineItem.AITM_Credit_Days__c;
                            lineItemDebrief.AITM_Location_Delivery_Point__c = lineItem.AITM_Location_Delivery_Point__c; 
                            lineItemDebrief.AITM_Details_Context__c = lineItem.AITM_Details_Context__c;                                        
                            lineItemDebrief.AITM_Duration__c = lineItem.AITM_Duration__c;
                            lineItemDebrief.AITM_Invoice_Frequency__c = lineItem.AITM_Invoice_Frequency__c; 
                            lineItemDebrief.AITM_End_Date__c = lineItem.AITM_End_Date__c;
                            lineItemDebrief.AITM_Exchange__c = lineItem.AITM_Exchange__c;
                            lineItemDebrief.AITM_Location_Manager__c = lineItem.AITM_Location_Manager__c;
                            lineItemDebrief.AITM_Last_Tender_Result__c = lineItem.AITM_Last_Tender_Result__c;
                            lineItemDebrief.AITM_Level_Of_Interest__c = lineItem.AITM_Level_Of_Interest__c;
                            lineItemDebrief.AITM_Location__c = lineItem.AITM_Location__c; 
                            lineItemDebrief.AITM_Offered_Differential__c = lineItem.AITM_Offered_Differential__c;
                            lineItemDebrief.AITM_Offered_Volume__c = lineItem.AITM_Offered_Volume__c;
                            lineItemDebrief.AITM_Pricing_Basis__c = lineItem.AITM_Pricing_Basis__c;
                            lineItemDebrief.AITM_Quantity__c = lineItem.AITM_Quantity__c;
                            lineItemDebrief.AITM_Requested_Volume_USG__c = lineItem.AITM_Requested_Volume_USG__c;
                            lineItemDebrief.AITM_Requested_Volume_UoM__c = lineItem.AITM_Requested_Volume_UoM__c;
                            lineItemDebrief.AITM_Round__c = lineItem.AITM_Round__c;
                            lineItemDebrief.AITM_Specification__c = lineItem.AITM_Specification__c;
                            lineItemDebrief.AITM_Tender_Result__c = lineItemDebrief.AITM_Tender_Result__c;
                            lineItemDebrief.AITM_Unit_Of_Measure__c = lineItem.AITM_Unit_Of_Measure__c;
                            lineItemDebrief.AITM_Percentage_Volume_Offered__c = lineItem.AITM_Percentage_Volume_Offered__c;
                            lineItemDebrief.AITM_History_Line_Item__c = lineItem.AITM_History_Line_Item__c;                                             
                            lineItemDebrief.AITM_Volume__c = lineItem.AITM_Volume__c;
                            lineItemDebrief.AITM_Rebate__c = lineItem.AITM_Rebate__c;
                            lineItemDebrief.AITM_Tender_Owner_Profile__c = lineItem.AITM_Tender_Owner_Profile__c;
                            lineItemDebrief.AITM_Taxes_Fees__c = lineItem.AITM_Taxes_Fees__c;
                        	lineItemDebrief.AITM_Additional_Notes_Taxes_and_Fees__c = lineItem.AITM_Additional_Notes_Taxes_and_Fees__c;
                        	lineItemDebrief.AITM_Measure__c = lineItem.AITM_Measure__c;
                            lineItemDebrief.AITM_Product_Default__c = lineItem.AITM_Product_Default__c;
                            lineItemDebrief.AITM_Product_Specification__c = lineItem.AITM_Product_Specification__c;
                        	lineItemDebrief.AITM_Include_Taxes_and_Fees_in_Contract__c = lineItem.AITM_Include_Taxes_and_Fees_in_Contract__c;
                        	lineItemDebrief.AITM_Delivery_Method__c = lineItem.AITM_Delivery_Method__c;
                            lineItemDebrief.AITM_Previous_TLLI_Id__c = lineItem.Id;
                            debriefUpdateLineItems.add(lineItemDebrief);
                            mapDebrief.remove(lineItem.Id);
                            removeLineItems.add(lineItem.Id);
                        }
                    }
                    
                    for(AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
                        if(!removeLineItems.contains(lineItem.Id)) {
                            AITM_Tender_Location_Line_Item__c lineItemDebrief = new AITM_Tender_Location_Line_Item__c();
                            lineItemDebrief.RecordTypeId = DEBRIEF_RECORD_TYPE_ID;
                            lineItemDebrief.OwnerId = lineItem.OwnerId;
                            lineItemDebrief.AITM_Account__c = lineItem.AITM_Account__c;
                            lineItemDebrief.AITM_Start_Date__c = lineItem.AITM_Start_Date__c;
                            lineItemDebrief.AITM_Bid_Expiry_Date__c = lineItem.AITM_Bid_Expiry_Date__c;
                            lineItemDebrief.AITM_Tender__c = lineItem.AITM_Tender__c;
                            lineItemDebrief.AITM_Tender_Location__c = lineItem.AITM_Tender_Location__c;
                            lineItemDebrief.AITM_Ad_hoc_Volume__c = lineItem.AITM_Ad_hoc_Volume__c;
                            lineItemDebrief.AITM_Currency__c = lineItem.AITM_Currency__c;
                            lineItemDebrief.AITM_Current_Value__c = lineItem.AITM_Current_Value__c;
                            lineItemDebrief.AITM_Tender_Result__c = lineItem.AITM_Tender_Result__c;
                            lineItemDebrief.AITM_Credit_Days__c = lineItem.AITM_Credit_Days__c;
                            lineItemDebrief.AITM_Location_Delivery_Point__c = lineItem.AITM_Location_Delivery_Point__c; 
                            lineItemDebrief.AITM_Details_Context__c = lineItem.AITM_Details_Context__c;                                        
                            lineItemDebrief.AITM_Duration__c = lineItem.AITM_Duration__c;
                            lineItemDebrief.AITM_Invoice_Frequency__c = lineItem.AITM_Invoice_Frequency__c; 
                            lineItemDebrief.AITM_End_Date__c = lineItem.AITM_End_Date__c;
                            lineItemDebrief.AITM_Exchange__c = lineItem.AITM_Exchange__c;
                            lineItemDebrief.AITM_Location_Manager__c = lineItem.AITM_Location_Manager__c;
                            lineItemDebrief.AITM_Last_Tender_Result__c = lineItem.AITM_Last_Tender_Result__c;
                            lineItemDebrief.AITM_Level_Of_Interest__c = lineItem.AITM_Level_Of_Interest__c;
                            lineItemDebrief.AITM_Location__c = lineItem.AITM_Location__c; 
                            lineItemDebrief.AITM_Offered_Differential__c = lineItem.AITM_Offered_Differential__c;
                            lineItemDebrief.AITM_Offered_Volume__c = lineItem.AITM_Offered_Volume__c;
                            lineItemDebrief.AITM_Pricing_Basis__c = lineItem.AITM_Pricing_Basis__c;
                            lineItemDebrief.AITM_Quantity__c = lineItem.AITM_Quantity__c;
                            lineItemDebrief.AITM_Requested_Volume_USG__c = lineItem.AITM_Requested_Volume_USG__c;
                            lineItemDebrief.AITM_Requested_Volume_UoM__c = lineItem.AITM_Requested_Volume_UoM__c;
                            lineItemDebrief.AITM_Round__c = lineItem.AITM_Round__c;
                            lineItemDebrief.AITM_Specification__c = lineItem.AITM_Specification__c;
                            lineItemDebrief.AITM_Start_Date__c = lineItem.AITM_Start_Date__c;
                            lineItemDebrief.AITM_Tender_Result__c = lineItem.AITM_Tender_Result__c;
                            lineItemDebrief.AITM_Unit_Of_Measure__c = lineItem.AITM_Unit_Of_Measure__c;
                            lineItemDebrief.AITM_Percentage_Volume_Offered__c = lineItem.AITM_Percentage_Volume_Offered__c;
                            lineItemDebrief.AITM_History_Line_Item__c = lineItem.AITM_History_Line_Item__c;                                             
                            lineItemDebrief.AITM_Volume__c = lineItem.AITM_Volume__c;
                            lineItemDebrief.AITM_Rebate__c = lineItem.AITM_Rebate__c;
                            lineItemDebrief.AITM_Tender_Owner_Profile__c = lineItem.AITM_Tender_Owner_Profile__c;
                            lineItemDebrief.AITM_Taxes_Fees__c = lineItem.AITM_Taxes_Fees__c;
                        	lineItemDebrief.AITM_Additional_Notes_Taxes_and_Fees__c = lineItem.AITM_Additional_Notes_Taxes_and_Fees__c;
                        	lineItemDebrief.AITM_Measure__c = lineItem.AITM_Measure__c;
                            lineItemDebrief.AITM_Product_Default__c = lineItem.AITM_Product_Default__c;
                            lineItemDebrief.AITM_Product_Specification__c = lineItem.AITM_Product_Specification__c;
                        	lineItemDebrief.AITM_Include_Taxes_and_Fees_in_Contract__c = lineItem.AITM_Include_Taxes_and_Fees_in_Contract__c;
                        	lineItemDebrief.AITM_Delivery_Method__c = lineItem.AITM_Delivery_Method__c;
                            lineItemDebrief.AITM_Previous_TLLI_Id__c = lineItem.Id;
                            debriefCreateLineItems.add(lineItemDebrief);
                        }
                    }
                    if(mapDebrief.size() > 0 ) {
                        for(AITM_Tender_Location_Line_Item__c lineItem : mapDebrief.values()) {
                            debriefDeleteLineItems.add(lineItem);
                        }    
                    }
                    
                    Database.delete(debriefDeleteLineItems);
                    debriefDeleteLineItems = null;
                    Database.insert(debriefCreateLineItems);
                    debriefCreateLineItems = null;
                    Database.update(debriefUpdateLineItems);
                    debriefUpdateLineItems = null;    
                }                                          
            }
        }
    }
}