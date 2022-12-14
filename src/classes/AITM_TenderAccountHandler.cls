/***********************************************************************************************
* @author           George
* @date             01/December/2017
* @group            AirBP
* @description      Trigger handler for TenderAccount

* history
* 01/December/2017  George          Created
* 16/July/2018      Ravi            Modified - AR-3497 - Created subclass TenderAccountPopulateBankAccountHandler to 
*                                   link Bank Accont to Contracting entity based on Account Payment Currency matching with
*                                   Currency in Bank Account
* 21/Oct/2018       srnandan        Modified - AR-XXXX checkAndUpdate to correct AITM_Days__c to AITM_Credit_Days__c 
*                                   both account and line item
* 03/December/2018  srnandan        Modified - AR-4717 added class AccountValidateAffiliates
* 12/December/2018  srnandan        Modified - AR-4791 change address fields on offer and contract
* 14/March/2018      Shweta         Modified - AR-5037 Added the condition to check for current round in the class TenderAccountCreditTermsCopyHandler 
*************************************************************************************/
public with sharing class AITM_TenderAccountHandler implements AITM_TriggerFactory.SObjectHandler {
    private HandlerRepository handlersStorage;
    
    private Map<Id, ChildAccountsForTenders> childAccountsByParentId;
    
    public AITM_TenderAccountHandler() {
        handlersStorage = new HandlerRepository();
        handlersStorage.register(new TenderAccountParentAccountsMapper());
        handlersStorage.register(new TenderAccountDuplicatesHandler());
        handlersStorage.register(new TenderAccountDeleteRelatedLineItems());
        handlersStorage.register(new TenderAccountCreditTermsCopyHandler());
        handlersStorage.register(new TenderAccountPopulateBankAccountHandler());
        handlersStorage.register(new TenderAccountValidateAffiliates());
        handlersStorage.register(new PopulateLegalEntityDetails());
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
    
    private class TenderAccountParentAccountsMapper implements AITM_TriggerFactory.SObjectHandler {
        private Map<Id, ChildAccountsForTenders> childAccountsByParentId;
        
        public TenderAccountParentAccountsMapper() {
            childAccountsByParentId = new Map<Id, ChildAccountsForTenders>();
        }
        
        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){}
        public void beforeUpdate(SObject oldSo, SObject so){}
        public void beforeDelete(SObject so){}
        
        public void afterInsert(SObject so){
            this.addChildAccountsToInnerCollection(so);
        }
        
        public void afterUpdate(SObject oldSo, SObject so){}
        
        public void afterDelete(SObject so){}
        
        public void andFinally() {
            Set<Id> accountIdsInScope = childAccountsByParentId.keySet();
            if (accountIdsInScope.size() > 0) {
                for (Account accountInScope : new AITM_AccountDao().getAccountsWithItsChilds(accountIdsInScope)) {
                    childAccountsByParentId.get(accountInScope.Id).childAccounts = accountInScope.ChildAccounts;
                }
                insertNewTenderAccounts();
            }
        }
        
        private void addChildAccountsToInnerCollection(SObject so) {
            AITM_Tender_Account__c tenderAccount = (AITM_Tender_Account__c) so;
            if (!childAccountsByParentId.containsKey(tenderAccount.AITM_Account__c)) {
                ChildAccountsForTenders childAccounts = new ChildAccountsForTenders();
                childAccountsByParentId.put(tenderAccount.AITM_Account__c, childAccounts);
            }
            childAccountsByParentId.get(tenderAccount.AITM_Account__c).tenderIds.add(tenderAccount.AITM_Tender__c);
        }
        
        private void insertNewTenderAccounts() {
            List<AITM_Tender_Account__c> allNewTenderAccounts = new List<AITM_Tender_Account__c>();
            
            for (ChildAccountsForTenders childAccounts : childAccountsByParentId.values()) {
                allNewTenderAccounts.addAll(childAccounts.toTenderAccounts());
            }
            if (!allNewTenderAccounts.isEmpty()) {
                new AITM_AccountDao.TenderAccountDao().saveTenderAcccounts(allNewTenderAccounts);
            }
        }
    }
    
    @TestVisible
    private class TenderAccountDuplicatesHandler implements AITM_TriggerFactory.SObjectHandler {
        private final String DUPLICATION_ERROR = Label.AITM_TenderAccountDuplicateError;
        
        public TenderAccountDuplicatesHandler() {}
        
        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){}
        public void beforeUpdate(SObject oldSo, SObject so){}
        public void beforeDelete(SObject so){}
        public void afterInsert(SObject so){}
        public void afterUpdate(SObject oldSo, SObject so){}
        public void afterDelete(SObject so){}
        
        public void andFinally() {
            if (Trigger.isBefore && Trigger.isInsert) {
                checkForDuplicates(Trigger.new);
            }
        }
        
        public void checkForDuplicates(List<AITM_Tender_Account__c> tenderAccountsToSave) {
            Set<Id> tenderIds = new Set<Id>();
            for (AITM_Tender_Account__c tenderAccount : tenderAccountsToSave) {
                tenderIds.add(tenderAccount.AITM_Tender__c);
            }
            
            Map<String, AITM_Tender_Account__c> existingTenderAccounts = this.getExsistingTenderAccountsByTenderAndAccount(tenderIds);
            for (AITM_Tender_Account__c tenderAccount : tenderAccountsToSave) {
                if (existingTenderAccounts.containsKey(this.getUniqueKey(tenderAccount))) {
                    tenderAccount.addError(DUPLICATION_ERROR);
                }
            }
        }
        
        private Map<String, AITM_Tender_Account__c> getExsistingTenderAccountsByTenderAndAccount(Set<Id> tenderIds) {
            Map<String, AITM_Tender_Account__c> result = new Map<String, AITM_Tender_Account__c>();
            for (AITM_Tender_Account__c tenderAccount : new AITM_AccountDao.TenderAccountDao().getTenderAccountsForTenders(tenderIds)) {
                result.put(this.getUniqueKey(tenderAccount), tenderAccount);
            }
            return result;
        }
        
        private String getUniqueKey(AITM_Tender_Account__c tenderAccount) {
            return tenderAccount.AITM_Tender__c+'-'+tenderAccount.AITM_Account__c;
        }
    }
    
    /**
* @description  In use by TenderAccountParentAccountsMapper - as state class, which contains data mapped by account id
*/
    private class ChildAccountsForTenders {
        public Set<Id> tenderIds;
        public List<Account> childAccounts;
        
        public ChildAccountsForTenders() {
            tenderIds = new Set<Id>();
            childAccounts = new List<Account>();
        }
        
        public List<AITM_Tender_Account__c> toTenderAccounts() {
            List<AITM_Tender_Account__c> result = new List<AITM_Tender_Account__c>();
            for (Id tenderId : tenderIds) {
                for (Account childAccount : childAccounts) {
                    result.add(new AITM_Tender_Account__c(
                        AITM_Account__c = childAccount.Id,
                        AITM_Tender__c = tenderId
                    ));
                }
            }
            
            return result;
        }
    }
    
    
    private class TenderAccountDeleteRelatedLineItems implements AITM_TriggerFactory.SObjectHandler {
        private Map<Id, Set<Id>> customerIdsByTenderId;
        
        public TenderAccountDeleteRelatedLineItems() {
            this.customerIdsByTenderId = new Map<Id, Set<Id>>();
        }
        
        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){}
        public void beforeUpdate(SObject oldSo, SObject so){}
        public void beforeDelete(SObject so){}
        public void afterInsert(SObject so){}
        public void afterUpdate(SObject oldSo, SObject so){}
        
        public void afterDelete(SObject so) {
            AITM_Tender_Account__c deletedTenderCustomer = (AITM_Tender_Account__c) so;
            if (!this.customerIdsByTenderId.containsKey(deletedTenderCustomer.AITM_Tender__c)) {
                this.customerIdsByTenderId.put(deletedTenderCustomer.AITM_Tender__c, new Set<Id>());
            }
            this.customerIdsByTenderId.get(deletedTenderCustomer.AITM_Tender__c).add(deletedTenderCustomer.AITM_Account__c);
        }
        
        public void andFinally() {
            if (!this.customerIdsByTenderId.isEmpty()) {
                deleteRelatedLineItems();
            }
        }
        
        
        private void deleteRelatedLineItems() {
            Set<Id> allCustomerIds = new Set<Id>();
            for (Set<Id> customerIds : this.customerIdsByTenderId.values()) {
                allCustomerIds.addAll(customerIds);
            }
            
            List<AITM_Tender_Location_Line_Item__c> lineItemsToDelete = new List<AITM_Tender_Location_Line_Item__c>();
            for (AITM_Tender_Location_Line_Item__c lineItem : new AITM_LocationsDao().getTenderLocationLineItemsByTenderAndAccountIds(this.customerIdsByTenderId.keySet(), allCustomerIds)) {
                for (Id customerId : this.customerIdsByTenderId.get(lineItem.AITM_Tender__c)) {
                    if (lineItem.AITM_Account__c == customerId) {
                        lineItemsToDelete.add(lineItem);
                    }
                }
            }
            
            if (lineItemsToDelete.size()>0) {
                new AITM_LocationsDao().deleteTenderLocationLineItems(lineItemsToDelete);
            }            
        }
    }
    
    
    @TestVisible
    private class TenderAccountCreditTermsCopyHandler implements AITM_TriggerFactory.SObjectHandler {
        public TenderAccountCreditTermsCopyHandler() {}
        
        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){}
        public void beforeUpdate(SObject oldSo, SObject so){}
        public void beforeDelete(SObject so){}
        public void afterInsert(SObject so){}
        public void afterUpdate(SObject oldSo, SObject so){}
        public void afterDelete(SObject so){}
        
        public void andFinally() {
            if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
                checkAndUpdate(Trigger.new, trigger.oldmap);
            }
        }
        
        public void checkAndUpdate(List<AITM_Tender_Account__c> tenderAccounts, map<id,sObject> oldTenderAccountMapArg ) {
            Map<Id,AITM_Tender_Account__c> oldTenderAccountMap = (Map<Id,AITM_Tender_Account__c>)oldTenderAccountMapArg;
            Set<Id> tenderIds = new Set<Id>();
            set<Id> accountIds = new set<id>();
            
            for (AITM_Tender_Account__c tenderAccount : tenderAccounts) {
                
                AITM_Tender_Account__c oldTA = (oldTenderAccountMap != null ? oldTenderAccountMap.get(tenderAccount.id) : null);
                if(oldTA != null && (tenderAccount.AITM_Payment_Currency__c != oldTA.AITM_Payment_Currency__c || tenderAccount.AITM_Security_Text_on_Offer__c != oldTA.AITM_Security_Text_on_Offer__c || tenderAccount.AITM_Security_Type__c != oldTA.AITM_Security_Type__c || tenderAccount.AITM_Invoice_Frequency__c != oldTA.AITM_Invoice_Frequency__c || tenderAccount.AITM_Credit_Days1__c != oldTA.AITM_Credit_Days1__c))
                {
                    tenderIds.add(tenderAccount.AITM_Tender__c);
                    accountIds.add(tenderAccount.AITM_Account__c);
                } else if(oldTA == null && (tenderAccount.AITM_Payment_Currency__c != null || tenderAccount.AITM_Credit_Days1__c != null || tenderAccount.AITM_Invoice_Frequency__c != null)) {
                    tenderIds.add(tenderAccount.AITM_Tender__c);
                    accountIds.add(tenderAccount.AITM_Account__c);
                }
            }
            
            List<AITM_Tender_Location_Line_Item__c> lstTLitems = [select AITM_Tender__c, AITM_Account__c,AITM_Current_Round__c,AITM_Round__c from AITM_Tender_Location_Line_Item__c 
                                                                  where AITM_Account__c in :accountIds and AITM_Tender__c in :tenderIds];
            Map<String, List<AITM_Tender_Location_Line_Item__c>> mpUniqId_to_TenderLineItems = new Map<String, List<AITM_Tender_Location_Line_Item__c>>();
            
            for(AITM_Tender_Location_Line_Item__c TLit : lstTLitems)
            {
                String key = TLit.AITM_Account__c+'-'+TLit.AITM_Tender__c;
                if(mpUniqId_to_TenderLineItems.containsKey(key))
                {
                    mpUniqId_to_TenderLineItems.get(key).add(TLit);
                }
                else{
                    List<AITM_Tender_Location_Line_Item__c> tmpLst = new List<AITM_Tender_Location_Line_Item__c>();
                    tmpLst.add(TLit);
                    mpUniqId_to_TenderLineItems.put(key, tmpLst);
                }
            }
            
            List<AITM_Tender_Location_Line_Item__c> lstTLitemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
            for(AITM_Tender_Account__c tenderAccount : tenderAccounts)
            {
                String key = tenderAccount.AITM_Account__c+'-'+tenderAccount.AITM_Tender__c;
                if(mpUniqId_to_TenderLineItems.get(key) != null)
                    for(AITM_Tender_Location_Line_Item__c TLit : mpUniqId_to_TenderLineItems.get(key)){
                     if(TLit.AITM_Round__c == TLit.AITM_Current_Round__c){
                    TLit.AITM_Payment_Currency__c = tenderAccount.AITM_Payment_Currency__c;
                    TLit.AITM_Security_Type__c = tenderAccount.AITM_Security_Type__c;
                    TLit.AITM_Security_Text_on_Offer__c = tenderAccount.AITM_Security_Text_on_Offer__c;
                    TLit.AITM_Credit_Days__c = tenderAccount.AITM_Credit_Days1__c;
                    TLit.AITM_Invoice_Frequency__c = tenderAccount.AITM_Invoice_Frequency__c;                    
                    lstTLitemsToUpdate.add(TLit);
                }
              }  
            }
            
            update lstTLitemsToUpdate;
            
            
        }
        
        
    }
    
    @TestVisible
    private class TenderAccountValidateAffiliates implements AITM_TriggerFactory.SObjectHandler {
        private final String INVALID_AFFILIATE_ERROR = Label.AITM_AffiliatesError;
        public TenderAccountValidateAffiliates() {}
        
        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){}
        public void beforeUpdate(SObject oldSo, SObject so){}
        public void beforeDelete(SObject so){}
        public void afterInsert(SObject so){
            
        }
        public void afterUpdate(SObject oldSo, SObject so){}
        public void afterDelete(SObject so){}
        
        public void andFinally() {
            if (Trigger.isBefore && Trigger.isUpdate) {
                checkAndUpdate(Trigger.new, trigger.oldmap);
            }
        }
        
        public void checkAndUpdate(List<AITM_Tender_Account__c> tenderAccounts, map<id,sObject> oldTenderAccountMapArg ) {
            Map<Id,AITM_Tender_Account__c> oldTenderAccountMap = (Map<Id,AITM_Tender_Account__c>)oldTenderAccountMapArg;
            Set<Id> accountIds = new Set<Id>();
            for(AITM_Tender_Account__c tenderAccountNew : [SELECT AITM_Account__c FROM AITM_Tender_Account__c WHERE AITM_Tender__c = : tenderAccounts[0].AITM_Tender__c]) {
                if(!accountIds.contains(tenderAccountNew.AITM_Account__c)) {
                    accountIds.add(tenderAccountNew.AITM_Account__c);	       
                }    
            }
            for (AITM_Tender_Account__c tenderAccount : tenderAccounts) {
                AITM_Tender_Account__c oldTA = oldTenderAccountMap.get(tenderAccount.id);
                if(tenderAccount.AITM_Affiliates_Account__c != oldTA.AITM_Affiliates_Account__c) {
                    if (tenderAccount.AITM_Affiliates_Account__c != null && !accountIds.contains(tenderAccount.AITM_Affiliates_Account__c)) {
                        tenderAccount.addError(INVALID_AFFILIATE_ERROR);
                    }
                } 
            }
        }
    }
    
    /**
     * @description class which invokes Tender Account to populate Bank Account
     */
     private class TenderAccountPopulateBankAccountHandler implements AITM_TriggerFactory.SObjectHandler {
       /**
        * @description default constructor
        */
        public TenderAccountPopulateBankAccountHandler() {}
        
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
         * @param so of type SObject
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
        public void afterInsert(SObject so){}
        
        /**
         * @description after update operation of trigger event
         * @param so of type SObject
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
         * @description check isbefore, isupdate and isInsert events to populateBankAccount
         * @param null
         * @return null
         */
        public void andFinally() {
            if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert) ) {
                populateBankAccount(Trigger.new, Trigger.oldMap);
            }
        }
        
        /**
         * @description populate Bank Account in Tender Account
         * @param tenderAccounts
         * @param oldTenderAccountMapArg
         * @return null
         */
        public void populateBankAccount(List<AITM_Tender_Account__c> tenderAccounts, map<id,sObject> oldTenderAccountMapArg ) {
            
            Map<Id,AITM_Tender_Account__c> oldTenderAccountMap = (oldTenderAccountMapArg != null) ? (Map<Id,AITM_Tender_Account__c>)oldTenderAccountMapArg : new Map<Id,AITM_Tender_Account__c>();
            
            Set<Id> accountIds = new Set<Id>();
            set<Id> contractingEntityIds = new set<id>();
            
            List<AITM_Tender_Account__c> tenderAccountsCheck = new List<AITM_Tender_Account__c>();
            
            
            for (AITM_Tender_Account__c tenderAccount : tenderAccounts) {
                AITM_Tender_Account__c oldTA = oldTenderAccountMap.get(tenderAccount.id);
                if(oldTA == null && tenderAccount.AITM_Account__c != null && tenderAccount.AITM_Contracting_Entity__c != null ){
                    tenderAccountsCheck.add(tenderAccount);
                    accountIds.add(tenderAccount.AITM_Account__c);
                    contractingEntityIds.add(tenderAccount.AITM_Contracting_Entity__c);
                } else if(oldTA != null && (tenderAccount.AITM_Account__c != oldTA.AITM_Account__c || tenderAccount.AITM_Contracting_Entity__c != oldTA.AITM_Contracting_Entity__c) ){
                    tenderAccountsCheck.add(tenderAccount);
                    accountIds.add(tenderAccount.AITM_Account__c);
                    contractingEntityIds.add(tenderAccount.AITM_Contracting_Entity__c);
                }
                
            }
         
            if(tenderAccountsCheck.size() > 0) {
                Map<Id,Account> accountMap = new Map<Id,Account>([SELECT AITM_Payment_Currency__c FROM Account WHERE id IN:accountIds]);
                List<AITM_Contracting_Entity_Bank_Account__c> lstCEBA = [SELECT AITM_Bank_Account__c, AITM_Contracting_Entity__c, AITM_Currency__c FROM AITM_Contracting_Entity_Bank_Account__c WHERE AITM_Contracting_Entity__c IN:contractingEntityIds];
                
                Map<id,list<AITM_Contracting_Entity_Bank_Account__c>> mpCEtoCEBAs = new Map<id,list<AITM_Contracting_Entity_Bank_Account__c>>();
                for(AITM_Contracting_Entity_Bank_Account__c ceba : lstCEBA) {
                    if(mpCEtoCEBAs.containsKey(ceba.AITM_Contracting_Entity__c)) {
                        mpCEtoCEBAs.get(ceba.AITM_Contracting_Entity__c).add(ceba);
                    } else{
                        mpCEtoCEBAs.put(ceba.AITM_Contracting_Entity__c, new AITM_Contracting_Entity_Bank_Account__c[]{ceba});
                    }
                }
                
                for(AITM_Tender_Account__c ta: tenderAccountsCheck) {
                    if(ta.AITM_Account__c == null || ta.AITM_Contracting_Entity__c == null) {
                        ta.AITM_Bank_Account__c = null; 
                    } else{
                        Account ac = accountMap.get(ta.AITM_Account__c);
                        if(mpCEtoCEBAs.get(ta.AITM_Contracting_Entity__c) == null) {
                            ta.AITM_Bank_Account__c = null;
                        } else{
                            List<AITM_Contracting_Entity_Bank_Account__c> lstRelatedBankAccount = mpCEtoCEBAs.get(ta.AITM_Contracting_Entity__c);
                            Id selectedBAID;
                            for(AITM_Contracting_Entity_Bank_Account__c ceba : lstRelatedBankAccount){
                                if(ac.AITM_Payment_Currency__c == ceba.AITM_Currency__c) {
                                    selectedBAID = ceba.AITM_Bank_Account__c;
                                }
                            }
                            
                            if(selectedBAID != null) {
                                ta.AITM_Bank_Account__c = selectedBAID;  
                            }
                        }
                    }    
                }
            }
        }
    }

    private class PopulateLegalEntityDetails implements AITM_TriggerFactory.SObjectHandler {
        public PopulateLegalEntityDetails() {}
        
        public void bulkBefore(){}
        public void bulkAfter(){}
        public void beforeInsert(SObject so){}
        public void beforeUpdate(SObject oldSo, SObject so){}
        public void beforeDelete(SObject so){}
        public void afterInsert(SObject so){}
        public void afterUpdate(SObject oldSo, SObject so){}
        public void afterDelete(SObject so){}
        
        public void andFinally() {
            if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert) ) {
                this.populateLegalEntityDetails(Trigger.new, Trigger.oldMap);
            }
        }
        
        public void populateLegalEntityDetails(List<AITM_Tender_Account__c> tenderAccounts, Map<Id,sObject> oldTenderAccountMap) {
            String legalEntityRecordId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
            Map<String, String> mapAccountingDetails = new Map<String, String>();
            Map<String, AITM_Tender_Account__c> mapLegalDetails = new Map<String, AITM_Tender_Account__c>();
            Map<String, Id> mapLegalEntityDetails = new Map<String, Id>();
            Set<Id> tenderAccountIds = new Set<Id>();
            for(AITM_Tender_Account__c tenderAccount : tenderAccounts) {
                tenderAccountIds.add(tenderAccount.Id);
            }
            
            for(AITM_Tender_Account__c tenderAccount : [SELECT AITM_Account__r.AITM_GRN__c FROM AITM_Tender_Account__c WHERE Id IN : tenderAccountIds]) {
                if(tenderAccount.AITM_Account__r.AITM_GRN__c != null) {
                   mapLegalDetails.put(tenderAccount.AITM_Account__r.AITM_GRN__c.left(5), tenderAccount);
                   mapAccountingDetails.put(tenderAccount.AITM_Account__r.AITM_GRN__c, tenderAccount.AITM_Account__r.AITM_GRN__c.left(5));
                }
            }
            
            for(Account acc : [Select AITM_GRN__c FROM Account WHERE AITM_GRN__c IN : mapLegalDetails.keySet() AND RecordTypeId =: legalEntityRecordId]) {
                mapLegalEntityDetails.put(acc.AITM_GRN__c, acc.Id);
            }

            for(AITM_Tender_Account__c tenderAccount : tenderAccounts) {
                tenderAccount.AITM_Legal_Entity__c = mapLegalEntityDetails.get(mapAccountingDetails.get(tenderAccount.AITM_GRN__c));
            }
        }
    }
}