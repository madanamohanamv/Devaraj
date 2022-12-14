/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      To generate Tender Offer PDF (attachments) and update tender stage and offer sent.

 * history
 * 01/December/2017  George       Created 
 * 05/August/2018    srnandan     Modified added comments to each method and header of class
 * 12/August/2018    srnandan     Modified AR-3391 added method multipleLocations 
 *                                to show conditional display of email buttons for polish 
 *                                and non polish locations 
 * 07/January/2019   srnandan     Modified multipel locations to call getTenderWithTenderLocations
 * 02/February/2019  srnandan     declared static final for retrieving currentUserProfile and removed calling from
 *                                determineShowButtonsByProfile
 * 17/April/2019     srnandan     Modified - AR-XXXX multiplelocations condition with new filter AITM_Locations_Filter
 *************************************************************************************/
public with sharing class AITM_TenderPathShowMoreController {
    static final String currentUserProfile = new AITM_UsersDao().getProfileName(UserInfo.getUserId());
    /**
     * @description LABP Running user
     * @param  null
     * @return boolean
     */
    @AuraEnabled
    public static Boolean getLABPRunningUser() {
        Boolean blnFlag = false;
        blnFlag = AITM_BaseUtils.checkRunningUserIsLABP();
        return blnFlag;
    }
    
    /**
     * @description pulls default values to checkboxes
     * @param  tenderId of type Id
     * @return DefaultValuesToCheckboxes
     */
    @AuraEnabled
    public static DefaultValuesToCheckboxes pullDefaultValuesForCheckboxes(Id tenderId) {
        return new DefaultValuesToCheckboxes(tenderId);
    }

    /**
     * @description change feedback to debrief
     * @param  tenderId of type Id
     * @param  valueToSet of type Boolean
     * @return string
     */
    @AuraEnabled
    public static String changeFeedbackToDeBrief(Id tenderId, Boolean valueToSet) {
        try {
            update new AITM_Tender__c(Id = tenderId, AITM_No_Feedback_Progress_To_De_Brief__c = valueToSet);
        } catch (DMLException e) {
            return e.getDmlMessage(0);
        }
        return 'OK';
    }

    /**
     * @description class holds boolean flags to show buttons
     */
    public class DefaultValuesToCheckboxes {
        @AuraEnabled public Boolean feedbackToDebrief;
        @AuraEnabled public Boolean showButtons;
        @AuraEnabled public Boolean showPolish;
        @AuraEnabled public Boolean showNonPolish;
        @AuraEnabled public Boolean showDownloadLABPExcel;
        private final Set<String> PROFILES_WITH_BUTTONS_VISIBILITY = new Set<String> {
            'Air_TMAccount Manager',
            'Air_TMBusiness Admin',
            'Air_TMRegionalAccount Manager',
            'Air_TMLABP',
            'Air_TMLABPLogin',
            'System Administrator'
        }; 

        /**
         * @description overloaded constructor
         * @param  tenderId of type Id
         */
        public DefaultValuesToCheckboxes(Id tenderId) {
            AITM_Tender__c tender = [SELECT Id, AITM_Produce_Customer_Email__c, AITM_No_Feedback_Progress_To_De_Brief__c FROM AITM_Tender__c WHERE Id = :tenderId LIMIT 1][0];
            feedbackToDebrief = tender.AITM_No_Feedback_Progress_To_De_Brief__c;
            showButtons = determineShowButtonsByProfile();
            multipleLocations(tender.Id);
            showDownloadLABPExcel = AITM_BaseUtils.checkRunningUserIsLABP();
        }

        /**
         * @description overloaded constructor
         * @param  tenderId of type Id
         */
        private Boolean determineShowButtonsByProfile() {
            return PROFILES_WITH_BUTTONS_VISIBILITY.contains(currentUserProfile);
        }

        /**
         * @description multiple locations
         * @param  tenderId of type Id
         * @return null
         */
        public void multipleLocations(Id tenderId) {
           for(AITM_Tender_Location__c location : new AITM_TenderDao().getTenderWithTenderLocations(tenderId).AITM_Tender_Locations__r) {
               if(location.AITM_Locations_Filter__c != null && location.AITM_Locations_Filter__c == AITM_TenderDao.POLISH) {
                    showPolish = true;
               } else {
                    showNonPolish = true;
               }
           }
        }
    }
}