/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    To generate Tender Contract PDF (attachments) and show filter options before generate.

 * history
 * 01/December/2017  George       Created
 * 04/October/2018   Ravi         Modified - AR-4355 - Created getBeSpokeTemplate method for Bespoke Contract generation
 **************************************************************************/

 public with sharing class AITM_TenderContractContainerController  {
    /**
     * @description get filter options to show BESPOKE and non Bespoke
     * @param tenderId of type Id
     * @return options
     */
    public static @AuraEnabled List<AccountOption> getFilterOptions(Id tenderId) {
        List<AccountOption> options = new List<AccountOption>();
        for (AITM_Tender_Account__c tenderAccount : new AITM_AccountDao.TenderAccountDao().getTenderAccountForTender(tenderId)) {
            if(tenderAccount.AITM_Account__r.AITM_Bespoke_Template__c != null) {
                options.add(new AccountOption(tenderAccount, 'BESPOKE'));    
            }            
            else {
                options.add(new AccountOption(tenderAccount));
            }
        }
        return options;
    }

    /**
     * @description get Bespoke Template
     * @param accountId of type Id
     * @return templateName
     */
    public static String getBeSpokeTemplate(Id accountId) {
        String templateName = '';
        List<AITM_Tender_Account__c> accList = [Select AITM_Account__r.AITM_Bespoke_Template__c from AITM_Tender_Account__c where Id =: accountId];
        if(!accList.isEmpty()) {
         if(accList[0].AITM_Account__r.AITM_Bespoke_Template__c != null) {
             templateName = accList[0].AITM_Account__r.AITM_Bespoke_Template__c;
            }
        }
        return templateName;
    }

    /**
     * @description attach Offer documents
     * @param tenderId of type String
     * @param accountId of type String
     * @return null
     */
    public static @AuraEnabled void attachOfferDocuments(String tenderId, String accountId) {
        AITM_TenderContractPDFController.GenerationDTO generationDTO = new AITM_TenderContractPDFController.GenerationDTO();
        generationDTO.customerId = Id.valueOf(accountId);
        generationDTO.tenderId = Id.valueOf(tenderId);
        generationDTO.bespoke = getBeSpokeTemplate(accountId);
        
        AITM_TenderContractPDFController.generateContract(generationDTO);
    }

    /**
     * @description inner class to store accountId and name from Tender Account
     */
    public class AccountOption {
        public @AuraEnabled Id accountId;
        public @AuraEnabled String name;

        /**
         * @description overloaded constructor
         * @param tenderAccount of type AITM_Tender_Account__c
         */
        public AccountOption(AITM_Tender_Account__c tenderAccount) {
            this.accountId = tenderAccount.Id;
            this.name = tenderAccount.AITM_Account__r.Name;
        }
        /**
         * @description overloaded constructor
         * @param tenderAccount of type AITM_Tender_Account__c
         */
        public AccountOption(AITM_Tender_Account__c tenderAccount, String bspoke) {
            this.accountId = tenderAccount.Id;
            this.name = tenderAccount.AITM_Account__r.Name + ' ' + bspoke;
        }
    }
}