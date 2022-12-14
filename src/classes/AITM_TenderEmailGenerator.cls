/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      acts as data access object for all account related queries

 * history
 * 01/December/2017  George      Created 
 * 11/May/2017       Anusha      Modified AR-3091 to get distributionEmailList from Account and Contact
 * 20/May/2018       srnandan    Modified AR-3091 - Added method getDebriefDistributionList
 *                               added comments at class and method level
 * 23/July/2018      Anusha      Modified AR-3795 - modified the method getdistributionEmailList from Contact to Account
 *                               added comments at class and method level
 * 10/August/2018    srnandan    Modified AR-4011 - modified overloaded constructor AITM_TenderEmailGenerator
 *                               and GeneratorTenderData
 * 05/Sep/2018       Saravan     Modified AR-4161 - Modified GeneratorTenderData class to include Account Manager Email 
 * 23/December/2018  srnandan    Modified - AR-4876 - Modified methods GeneratorTenderData to include pricingresponsibility and delegates
 * 20/February/2018  Shweta      Modified - AR-5010 - Modified method getEmailTemplateMarkup to get only the active templates
 ************************************************************************************************/
public virtual class AITM_TenderEmailGenerator  {
    protected AITM_EmailGeneratorController.EmailDTOFactory emailDTOFactory;
    protected GeneratorTenderData tenderData;

    /**
     * @description overloaded constructor
     * @param tenderId of type Id
     */
    public AITM_TenderEmailGenerator(Id tenderId) {
        emailDTOFactory = new AITM_EmailGeneratorController.EmailDTOFactory();
        tenderData = new GeneratorTenderData(tenderId);
    }

    /**
     * @description overloaded constructor
     * @param tenderId of type Id
     */
    public AITM_TenderEmailGenerator(Id tenderId, String locationType) {
        emailDTOFactory = new AITM_EmailGeneratorController.EmailDTOFactory();
        tenderData = new GeneratorTenderData(tenderId, locationType);
    }

    /**
     * @description generates emailDTOFactory object
     * @param null
     */
    public virtual AITM_EmailGeneratorController.EmailDTO generate() {
        return emailDTOFactory.create();
    }

    /**
     * @description gets email template mark up
     * @param emailTemplateName of type string
     * @return string
     */
    protected String getEmailTemplateMarkup(String emailTemplateName) {
    List<EmailTemplate> templates = [SELECT Markup FROM EmailTemplate WHERE IsActive = true AND DeveloperName = :emailTemplateName];
      if(!templates.isEmpty()){
         return templates[0].Markup;
       }
        else {
         return null;
        }
    }
    
    /**
     * @description replaces placeholder with fieldValues 
     * @param rawBody of type string
     * @param placeholder of type string
     * @param fieldValue of type string
     * @return string
     */
    protected String replaceFieldForRawBody(String rawBody, String placeholder, String fieldValue) {
        if (fieldValue != null) {
            return rawBody.replace(placeholder, fieldValue);
        } else {
            return rawBody.replace(placeholder, '');
        }
    }

    /**
     * @description gets linewrapper with td html tag
     * @param line of type string
     * @return string
     */
    protected String getLineWrapperWithTD(String line) {
        return '<td style="border-top: 1px solid rgb(216, 221, 230);white-space: nowrap; font-weight:400;padding: .5rem;">' +
            (String.isNotBlank(line) ? line : '') + '</td>';
    }

    /**
     * @description Inner class holds Tender related data
     */
    public class GeneratorTenderData {
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location__c> tenderLocations;
        public List<AITM_Tender_Location__c> tenderLocationsWithDeBrief;
        public List<AITM_Tender_Account__c> tenderAccounts;
        public String currentRound;
        public String accountManagerEmail;	
        public Set<String> locationManagersEmail;
        public Set<String> locationManagerDelegatesEmail;
        public List<Account> distributionEmailList;
        public final String ACCOUNT_DEBRIEF = 'DEBEMAIL';
        
        /**
         * @description overloaded constructor tender data
         * @param tenderId of type Id
         */
        public GeneratorTenderData(Id tenderId) {
            tender = new AITM_TenderDao().getTender(tenderId);
            tenderLocations = new List<AITM_Tender_Location__c>();
            //tenderLocations = new AITM_LocationsDao().getTenderLocationsWithLineItemsForFeedback(tenderId);
            tenderLocationsWithDeBrief = new AITM_LocationsDao().getTenderLocationsWithDeBriefLineItemsForFeedback(tenderId);
            tenderAccounts =  new AITM_AccountDao.TenderAccountDao().getTenderAccountForTender(tenderId);
            locationManagersEmail = new Set<String>();
            locationManagerDelegatesEmail = new Set<String>();
            accountManagerEmail = tender.Owner.Email;
            //for (AITM_Tender_Location__c tenderLocation : tenderLocations) {
            for(AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getTenderLocationsWithLineItemsForFeedback(tenderId)) {
                tenderLocations.add(tenderLocation);
                for(AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {  
                    if(lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'CA' && (lineItem.AITM_Location_Delivery_Point__c != null && (lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == lineItem.AITM_Tender__r.AITM_Tender_Sector__c || lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'BOTH'))) {
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c != null) {
                            locationManagersEmail.add(lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Email); 
                        }
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null) {
                            locationManagersEmail.add(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Email);   
                        }
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c != null) {
                            locationManagerDelegatesEmail.addAll(lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c.split('\n'));
                        }                        
                    } else {
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c != null) {
                            locationManagersEmail.add(lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Email);
                        }
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null) {
                            locationManagersEmail.add(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Email);   
                        }
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c != null) {
                            locationManagerDelegatesEmail.addAll(lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c.split('\n'));
                        }
                    }      
                }
                if (tenderLocation.AITM_Current_Round__c != null) {
                    currentRound = String.valueOf(tenderLocation.AITM_Current_Round__c);
                }
            }
        }
        
        /**
         * @description overloaded constructor tender data
         * @param tenderId of type Id
         */
        public GeneratorTenderData(Id tenderId, String locationType) {
            tender = new AITM_TenderDao().getTender(tenderId);
            tenderLocations = new List<AITM_Tender_Location__c>();
            //tenderLocations = new AITM_LocationsDao().getTenderLocationsWithLineItemsForFeedback(tenderId, locationType);
            tenderLocationsWithDeBrief = new AITM_LocationsDao().getTenderLocationsWithDeBriefLineItemsForFeedback(tenderId, locationType);
            tenderAccounts =  new AITM_AccountDao.TenderAccountDao().getTenderAccountForTender(tenderId);
            locationManagersEmail = new Set<String>();
            locationManagerDelegatesEmail = new Set<String>();
            accountManagerEmail = tender.Owner.Email;
            for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getTenderLocationsWithLineItemsForFeedback(tenderId, locationType)) {
                tenderLocations.add(tenderLocation);
                for(AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {  
                    if(lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'CA' && (lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == lineItem.AITM_Tender__r.AITM_Tender_Sector__c || lineItem.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'BOTH')) {
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c != null) {
                            locationManagersEmail.add(lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Email); 
                        }
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null) {
                            locationManagersEmail.add(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Email);   
                        }
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c != null) {
                            locationManagerDelegatesEmail.addAll(lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c.split('\n'));
                        }                        
                    } else {
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c != null) {
                            locationManagersEmail.add(lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Email);
                        }
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null) {
                            locationManagersEmail.add(lineItem.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Email);   
                        }
                        if(lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c != null) {
                            locationManagerDelegatesEmail.addAll(lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c.split('\n'));
                        }
                    }      
                }
                if (tenderLocation.AITM_Current_Round__c != null) {
                    currentRound = String.valueOf(tenderLocation.AITM_Current_Round__c);
                }
            }
        }

        /**
         * @description gets emailAddressList using Accounts
         * @param grns set collection of type string   
         * @return List collection of emailAddressList (sobject)
         */
        public Set<String> getLocationsDistributionList() {
            Set<String> emailAddressList = new Set<String>();
            getDebriefDistributionList();
            if (distributionEmailList != null) {
                for(Account account : distributionEmailList) {
                    emailAddressList.add(account.AITM_DistributionEmail__c);
                }
            }
            return emailAddressList;
        }

        /**
         * @description gets debrief distributionEmailList using Accounts
         * @param null
         * @return void
         */
         public void getDebriefDistributionList() {
            List<Account> result = new AITM_AccountDao.TenderAccountDao().getDistributionListofAccount(ACCOUNT_DEBRIEF);
            distributionEmailList = result;
        }
    }

    /**
     * @description Inner class holds Attachment info
     */
    public virtual class AttachmentGenerator {
        protected Id tenderId;
        protected AITM_EmailGeneratorController.EmailDTO emailDTO;
        protected String locationType;

        /**
         * @description overloaded constructor
         * @param tenderId of type Id
         * @param emailDTO of type AITM_EmailGeneratorController.EmailDTO
         */
        public AttachmentGenerator(Id tenderId, AITM_EmailGeneratorController.EmailDTO emailDTO, String locationType) {
            this.tenderId = tenderId;
            this.emailDTO = emailDTO;
            this.locationType = locationType;
        }
        
        /**
         * @description attaches email attachment
         * @param null
         * @return void
         */
        public void attach() {
            AITM_EmailGeneratorController.EmailMessage emailToAttach = new AITM_EmailGeneratorController.EmailMessageFactory().create(emailDTO);
            String fileName = this.getFileName(emailToAttach);
            Blob fileBody = this.getFileBody(emailToAttach);
            String chatterPost = this.getChatterPost(emailToAttach);
            this.createContentVersionAndRelateItToTheTender(fileName, fileBody, chatterPost);
        }

        /**
         * @description creates contentversion related to tender
         * @param fileName of type string
         * @param fileBody of type Blob
         * @param chatterPost of type string
         * @return void
         */
        protected void createContentVersionAndRelateItToTheTender(String fileName, Blob fileBody, String chatterPost) {
            ContentVersion contractFile = AITM_BaseUtils.createContentVersion(fileBody, fileName);
            AITM_BaseUtils.createChatterPostToRelate(chatterPost, this.tenderId, contractFile.Id);
        }
        
        /**
         * @description gets file name
         * @param emailToAttach of type AITM_EmailGeneratorController.EmailMessage
         * @return string
         */
        protected virtual String getFileName(AITM_EmailGeneratorController.EmailMessage emailToAttach) {
            return emailToAttach.subject + '.html';
        }
        
        /**
         * @description gets file body
         * @param emailToAttach of type AITM_EmailGeneratorController.EmailMessage
         * @return Blob
         */
        protected Blob getFileBody(AITM_EmailGeneratorController.EmailMessage emailToAttach) {
            return Blob.valueOf(emailToAttach.getHTMLBody());
        }
        
        /**
         * @description gets chatter post
         * @param emailToAttach of type AITM_EmailGeneratorController.EmailMessage
         * @return string
         */
        protected virtual String getChatterPost(AITM_EmailGeneratorController.EmailMessage emailToAttach) {
            return '';
        }
    }
}