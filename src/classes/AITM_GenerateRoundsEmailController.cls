/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      To generate Tender Offer PDF (attachments) and update tender stage and offer sent.

 * history
 * 01/December/2017  George       Created 
 * 05/August/2018    srnandan     Modified added comments to each method and header of class
 * 12/August/2018    srnandan     Modified AR-3391 added method multipleLocations 
 *                                to show conditional display of data for polish 
 *                                and non polish locations
 *  23/Oct/2018      srnandan     Modified AR-
 *************************************************************************************/
public with sharing class AITM_GenerateRoundsEmailController {
	private static final String STATUS_AWAITING_PRICE = 'Awaiting Price';
    
    /**
     * @description generates email content based on location type and tender
     * @param  tenderId of type Id
     * @param  locationType of type String
     * @return AITM_EmailGeneratorController.EmailDTO
     */
    public static @AuraEnabled AITM_EmailGeneratorController.EmailDTO generate(Id tenderId, String locationType) {
        if(!isTenderLocationsHasFeedback(tenderId) && !Test.isRunningTest()){
            throw new AuraHandledException(Label.AITM_EmptyFeedbackErrorMessage);   
        }
        AITM_RoundsEmailGenerator.Generator emailCreator = new AITM_RoundsEmailGenerator.Generator(tenderId, AITM_TenderDao.NONPOLISH);
        return emailCreator.generate();
    }
	
    /**
     * @description generates email content based on location type and tender
     * @param  tenderId of type Id
     * @param  locationType of type String
     * @return AITM_EmailGeneratorController.EmailDTO
     */
    public static @AuraEnabled Boolean updateTenderChange(Id tenderId) {
       AITM_Tender__c tender = new AITM_TenderDao().getTenderStage(tenderId);
       
       if(tender.AITM_Stage__c == 'STATUS_AWAITING_PRICE' || tender.AITM_No_Feedback_Progress_To_De_Brief__c) {
            return true;
       }
       return false;
    }
    
    /**
     * @description attaches email content
     * @param  emailDTOWithTenderId of type string
     * @return null
     */
    public static @AuraEnabled void attachEmail(String emailDTOWithTenderId) {
        EmailDTOTenderId dataObject = (EmailDTOTenderId) JSON.deserialize(emailDTOWithTenderId, EmailDTOTenderId.class);
        AITM_RoundsEmailGenerator.AttachmentGenerator emailAsAttachmentGenerator = 
			new AITM_RoundsEmailGenerator.AttachmentGenerator(dataObject.tenderId, dataObject.emailDTO, AITM_TenderDao.NONPOLISH);
        emailAsAttachmentGenerator.attach();
        try {
                AITM_TenderDao tenderDao = new AITM_TenderDao();
                tenderDao.updateFeedbackSent(dataObject.tenderId);
            }catch(Exception ex) {
                throw new AuraHandledException('Error updating Feedback Notification');          
            }
    }

    /**
     * @description class holds email dto for a tender
     */
    private @testVisible class EmailDTOTenderId {
        public Id tenderId;
        public AITM_EmailGeneratorController.EmailDTO emailDTO;
    }

    /**
     * @description returns true if tenderlocations has feedback
     * @param  tenderId of type Id
     * @return Boolean
     */
    private static Boolean isTenderLocationsHasFeedback(Id tenderId){
        List<AITM_Tender_Location__c> tenderLocations = new AITM_LocationsDao().getRepresentedCurrentRoundTenderLocations(tenderId);
        Boolean result = false;

        for (AITM_Tender_Location__c tenderLocation : tenderLocations){
            if (tenderLocation.AITM_Has_Feedback__c) {
                result = true;
            }
        }

        return result;
    }
}