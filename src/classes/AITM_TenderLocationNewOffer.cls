/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    controller class to display Tender Location New Offer details
 *                 and MSDS PDF files(email attachments).

 * history
 * 01/December/2017  George       Created
 * 08/June/2018      srnandan     Modified - AR-3504 added code comments as per standards
 * 22/June/2018      srnandan     Modified - AR-3527 updateRecord with extra param linItems
 *                                added new method updateChildRecords
 * 03/Dec/2018      Shweta        Modified - AR-4644 -- Update the method getTableData to get the accounts related to the TLLI record
 * 05/Dec/2018      Anusha        Modified - AR-4718 -- updated the method for price all no quote value
 * 12/Dec/2018      Shweta        Modified -AR-4644  -- updated the code for delivery point functionality
 * 07/January/2019  srnandan      Modified - cloneRecords method to remove unnecessary code and refactored to use clone method
 * 17/january/2019  Shweta        Modified - AR-4907 - Updated the method updateDeliveryRecords
 * 22/January/2019  srnandan      Modified - AR-4915 Refactored method deleteRecords
 * 31/January/2019  Shweta        Modified - AR-4955/A-4940 Updated the clone record method for setting the flag as true
 * 31/January/2019  srnandan      Modified - AR-4955 moved DML operation insert clone record to LocationsDao
 * 14/February/2019  Shweta       Modified - AR- 4981 Updated delivery point method is modified
 * 04/March/2019     Shweta       Modified - AR-4620 - Updated the method getFieldsAccess && updateDeliveryRecords to get the CA/GA delegates 
 * 06/March/2019     srnandan     Modified - AR-5009 Updated the method getTableData to call method getAccountsByTenderLocationLineItemAccountId
 * 								  of TenderAccountLineItemDao class
 * 28/March/2019     Ravi         Modified - AR-5116 created new method updateTaxesandFeesToAllTLLI for apply all taxes and fees checkbox
 * 02/April/2019     Ravi         Modified - AR-5028 added currency and UOM to populate to TLLI in updateDeliveryDetails
 *************************************************************************/
public with sharing class AITM_TenderLocationNewOffer {

    public static final String VALUE_TYPE_DOUBLE = 'DOUBLE';
    public static final String VALUE_TYPE_PERCENT = 'PERCENT';
    public static final String VALUE_TYPE_INTEGER = 'INTEGER';
    public static final String VALUE_TYPE_DATE = 'DATE';
    public static final String SHARING_REASON = 'Sharing_To_Pricing_Delegates__c';
    public final static Set<String> PROFILES_ALLOWED_TO_UPDATE = new Set<String>{
    'System Administrator',
    'Air_TMAccount Manager',
    'Air_TMLABP',
    'Air_TMLABPLogin'
    };
    private static final ID ID_TLLI_RECORD_TYPE_DEFAULT = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();

   /**
    * @description gets table data
    * @param tenderLocationId of type Id
    * @return Map<String, List<sObject>>
    */
    @AuraEnabled
    public static Map<String, List<sObject>> getTableData(Id tenderLocationId) {
        List<AITM_Tender_Location_Line_Item__c> lineItems = new AITM_LocationsDao().getTenderLocationLineItemsByRecordType(tenderLocationId, ID_TLLI_RECORD_TYPE_DEFAULT);
        List<AITM_Tender_Location_Line_Item__c> lineItemAcc = new AITM_LocationsDao().getTenderLocationLineItemsGroupedByAccount(tenderLocationId, ID_TLLI_RECORD_TYPE_DEFAULT);
        AITM_Tender_Location__c tenderLocation = new AITM_LocationsDao().getTenderLocation(tenderLocationId);
        Set<Id> setAccountName = new Set<Id>() ;
        for(Integer i = 0; i < lineItemAcc.size(); i++) {
            setAccountName.add(lineItemAcc[i].AITM_Account__c);
        }
        List<Account> acc = new AITM_AccountDao.TenderAccountLineItemDao().getAccountsByTenderLocationLineItemAccountId(setAccountName);  
        Map<String, List<sObject>> tableData = new Map<String, List<sObject>>();
        tableData.put('lineItems', lineItems);
        tableData.put('tenderLocation', new List<AITM_Tender_Location__c>{tenderLocation});
        tableData.put('acc',acc);

        return tableData;
    }

   /**
    * @description deletes the record
    * @param lstRecordId of type List
    * @return error message
    */
    @AuraEnabled
    public static String deleteRecords(List<String> lstRecordId) {   
        String oErrorMsg = '';
        List <AITM_Tender_Location_Line_Item__c> lstDeleteRec = new AITM_LocationsDao().getTenderLocationLineItemsByIds(lstRecordId);
        Set<Id> accounts = new Set<Id>();
        for(AITM_Tender_Location_Line_Item__c tenderLocation : lstDeleteRec) {
            accounts.add(tenderLocation.AITM_Account__c);
        }
        if(accounts.size() > 1) {
            oErrorMsg = 'Please select the records to be deleted under one customer only';    
        } else {
            Id accId = (lstDeleteRec.size() > 0 ? lstDeleteRec[0].AITM_Account__c : null);
            Id tenderLocationId = (lstDeleteRec.size() > 0 ? lstDeleteRec[0].AITM_Tender_Location__c : null);
            List<AITM_Tender_Location_Line_Item__c> allRecords = new AITM_LocationsDao().getTenderLocationLineItemsBytenderLocationAndAccountId(tenderLocationId,accId);
            Integer allRecordsCount = allRecords.size();
            Integer selectedRecordsCount = lstDeleteRec.size();

            if(allRecordsCount > selectedRecordsCount) {
                oErrorMsg = new AITM_LocationsDao().deleteTenderLocationLineItems(lstDeleteRec);       
            } else {
                oErrorMsg ='Each customer must have atleast one tender Location Line Item record';
            }
        }
        return oErrorMsg;
    }

   /**
    * @description return the Tender location line items selected for including in new offer
    * @param revisionRecordId of type List
    * @return list of tender location line item
    */
    @AuraEnabled
    public static List <AITM_Tender_Location_Line_Item__c> getIdsForRevision(List<String> revisionRecordId) {  
        List <AITM_Tender_Location_Line_Item__c> revisionRec = new AITM_LocationsDao().getTenderLocationLineItemsByIds(revisionRecordId);
        return revisionRec;
    } 

   /**
    * @description clone the selected tender location lineitem
    * @param cloneRecordId of type Id
    * @return error mesaage of type String
    */
    @AuraEnabled
    public static String cloneRecords(Id cloneRecordId) { 
        String error = '';
        AITM_Tender_Location_Line_Item__c cloneRec = new AITM_LocationsDao().getTenderLocationLineItem(cloneRecordId);
        AITM_Tender_Location_Line_Item__c clonedLineItem = cloneRec.clone(false);
        clonedLineItem.AITM_Is_Clone__c = true;

        try {
            new AITM_LocationsDao().insertCloneRecord(clonedLineItem);
        } catch(Dmlexception dmlError) { 
            error = dmlError.getMessage();
        } 
        return error;
    }

   /**
    * @description update the delivery point of the tender location line item
    * @param deliveryRecordId of type String
    * @param lineItemId of type String
    * @return error mesaage of type String
    */
    @AuraEnabled         
    public static String updateDeliveryRecords(String deliveryRecordId,String lineItemId) {        
        String error = '';
        AITM_Tender_Location_Line_Item__c tenderLineItem = new AITM_LocationsDao().getTenderLocationLineItem(lineItemId);
        List<AITM_Delivery_Point__c> deliveryRecords = [SELECT AITM_Currency__c,AITM_Unit_Of_Measure__c,AITM_Delivery_Method__c,AITM_Pricing_Basis_CA__r.AITM_Type__c,AITM_Delivery_By__c,AITM_Product_Specification__c,AITM_Location_Manager1__c,AITM_Location__r.OwnerId,AITM_Default_Delivery_Point__c,AITM_CA_Pricing_Responsibility1__c,AITM_GA_Pricing_Responsibility1__c,AITM_Product_Default__c,AITM_Additional_Refueling_Information__c,AITM_Taxes_Fees__c,AITM_Measure__c,AITM_Pricing_Basis_CA__c,AITM_Pricing_Basis_GA__c,AITM_Pricing_Basis_GA__r.AITM_Type__c FROM AITM_Delivery_Point__c WHERE Id=:deliveryRecordId];
        Set<String> pricingDelegates = new Set<String>();
        List<User> pricingUsers = new List<User>();

        if(deliveryRecords.size() > 0) {
            if(deliveryRecords[0].AITM_Default_Delivery_Point__c != null) {
                if (tenderLineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'CA' && (deliveryRecords[0].AITM_Default_Delivery_Point__c == 'CA' || deliveryRecords[0].AITM_Default_Delivery_Point__c == 'BOTH')) {
                    error = validateCADifferential(deliveryRecords[0], tenderLineItem);
                    if(!String.isBlank(error)){
                        return error;
                    } else{
                        tenderLineItem.AITM_Pricing_Basis__c = deliveryRecords[0].AITM_Pricing_Basis_CA__c;
                    }
                    tenderLineItem = setOwnerId(deliveryRecords[0],tenderLineItem,'CA');  
                    String delegatesCA = tenderLineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c;
                    if(delegatesCA != null) {
                        pricingDelegates.addAll(delegatesCA.toLowerCase().split(';'));
                    }                                             
                } else if(tenderLineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'GA' && (deliveryRecords[0].AITM_Default_Delivery_Point__c == 'GA' || deliveryRecords[0].AITM_Default_Delivery_Point__c == 'BOTH')) {
                    error = validateGADifferential(deliveryRecords[0], tenderLineItem);
                    if(!String.isBlank(error)){
                        return error;
                    }else{
                        tenderLineItem.AITM_Pricing_Basis__c = deliveryRecords[0].AITM_Pricing_Basis_GA__c;
                    }                     
                
                    tenderLineItem = setOwnerId(deliveryRecords[0],tenderLineItem,'GA');
                    String delegatesGA = tenderLineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c;
                    if(delegatesGA!= null) {
                        pricingDelegates.addAll(delegatesGA.toLowerCase().split(';'));
                    } 
                }
            } else if(tenderLineItem.AITM_Pricer_No_Default_Delivery_Points__c !=null) {
                 tenderLineItem.OwnerId = tenderLineItem.AITM_Pricer_No_Default_Delivery_Points__c;
            }
            pricingUsers = new AITM_UsersDao().getPricingUsersAndDelegatesAll(pricingDelegates);
            tenderLineItem = setLineItemFields(deliveryRecordId, tenderLineItem, deliveryRecords[0]);
            
            try {
                Database.SaveResult sr = Database.update(tenderLineItem ,false);
                AITM_LightningSharing.revokePermissionForDelegates(tenderLineItem.Id, SHARING_REASON); 
                AITM_LightningSharing.grantPermissionForDelegates(pricingUsers, tenderLineItem.Id, 'Edit');
                }catch(Dmlexception dmlError) {
                    error = dmlError.getMessage();
                } 
        }    
        return error;
    } 

    /**
     * @description set the field values of line item as per delivery point record field values
     * @param deliveryRecordId
     * @param tenderLineItem
     * @param deliveryRecord
     * @return AITM_Tender_Location_Line_Item__c
     */
     public static AITM_Tender_Location_Line_Item__c setLineItemFields(String deliveryRecordId, AITM_Tender_Location_Line_Item__c tenderLineItem, AITM_Delivery_Point__c deliveryRecord) {
        tenderLineItem.AITM_Location_Delivery_Point__c = deliveryRecordId ;     
        tenderLineItem.AITM_Delivery_Method__c = deliveryRecord.AITM_Delivery_Method__c;
        tenderLineItem.AITM_Delivery_By__c = deliveryRecord.AITM_Delivery_By__c;
        tenderLineItem.AITM_Product_Default__c = deliveryRecord.AITM_Product_Default__c;
        tenderLineItem.AITM_Measure__c  = deliveryRecord.AITM_Measure__c;
        tenderLineItem.AITM_Taxes_Fees__c = deliveryRecord.AITM_Taxes_Fees__c;
        tenderLineItem.AITM_Additional_Refueling_Information__c = deliveryRecord.AITM_Additional_Refueling_Information__c;
        tenderLineItem.AITM_Product_Specification__c = deliveryRecord.AITM_Product_Specification__c; 
        tenderLineItem.AITM_Unit_Of_Measure__c = deliveryRecord.AITM_Unit_of_Measure__c;
        tenderLineItem.AITM_Currency__c = deliveryRecord.AITM_Currency__c;
        return tenderLineItem;           
    }

    /**
     * @description Method to validate pricing basis for CA Sector
     */
    public static String validateCADifferential(AITM_Delivery_Point__c deliveryPoint, AITM_Tender_Location_Line_Item__c tenderLineItem) {
        String errorMessage = '';
        if(deliveryPoint.AITM_Pricing_Basis_CA__r.AITM_Type__c == 'D' && tenderLineItem.AITM_Offered_Differential__c  == null) {
            errorMessage  = System.Label.AITM_Add_Offered_Differential;
        } else if(deliveryPoint.AITM_Pricing_Basis_CA__r.AITM_Type__c == 'C' && tenderLineItem.AITM_Current_Value__c  == null) {
            errorMessage = System.Label.AITM_Add_Current_Value;
        }
        return errorMessage;
    }

    /**
     * @descriptionMethod to validate pricing basis for GA Sector
     */
    public static String validateGADifferential(AITM_Delivery_Point__c deliveryPoint, AITM_Tender_Location_Line_Item__c tenderLineItem) {
        String errorMessage = '';
        if(deliveryPoint.AITM_Pricing_Basis_GA__r.AITM_Type__c == 'D' && tenderLineItem.AITM_Offered_Differential__c  == null) {
            errorMessage = System.Label.AITM_Add_Offered_Differential;
        } else if(deliveryPoint.AITM_Pricing_Basis_GA__r.AITM_Type__c == 'C' && tenderLineItem.AITM_Current_Value__c  == null) {
            errorMessage = System.Label.AITM_Add_Current_Value;
        }
        return errorMessage;
    }

   /**
    * @description Method to set for the owner
    */
    public static AITM_Tender_Location_Line_Item__c setOwnerId(AITM_Delivery_Point__c deliveryPoint, AITM_Tender_Location_Line_Item__c lineItem, String sector) {
        if(sector == 'CA') {
            if(deliveryPoint.AITM_CA_Pricing_Responsibility1__c !=null) {
                lineItem.OwnerId = deliveryPoint.AITM_CA_Pricing_Responsibility1__c;
            } else if(deliveryPoint.AITM_Location_Manager1__c !=null) {
                lineItem.OwnerId = deliveryPoint.AITM_Location_Manager1__c;
            } else {
                lineItem.OwnerId = deliveryPoint.AITM_Location__r.OwnerId;
            }
        }else {
            if(deliveryPoint.AITM_GA_Pricing_Responsibility1__c !=null) {
                lineItem.OwnerId = deliveryPoint.AITM_GA_Pricing_Responsibility1__c;
            } else if(deliveryPoint.AITM_Location_Manager1__c !=null) {
                lineItem.OwnerId = deliveryPoint.AITM_Location_Manager1__c;
            } else {
                lineItem.OwnerId = deliveryPoint.AITM_Location__r.OwnerId;
            }
        }
        return lineItem;
    }


    /**
     * @description get the list of delivery point of a location
     * @param lineItemRecord  of type AITM_Tender_Location_Line_Item__c
     * @return List of AITM_Delivery_Point__c
     */
    @AuraEnabled
    public static List<AITM_Delivery_Point__c> getDeliveryRecords(AITM_Tender_Location_Line_Item__c lineItemRecord) {        
        Id locationId = lineItemRecord.AITM_Location__c;        
        List<AITM_Delivery_Point__c> deliveryPoints =  new AITM_LocationsDao().getDeliveryPointRelatedLocation(locationId);
        return deliveryPoints;
    }

    /**
     * @description updates the record
     * @param objectName of type string
     * @param recordId of type string
     * @param fieldName of type string
     * @param value of type string
     * @param lineItems value of type List collection AITM_Tender_Location_Line_Item__c
     * @return sObject
     */
    @AuraEnabled
    public static sObject updateRecord(String objectName, String recordId, String fieldName, String value, List<AITM_Tender_Location_Line_Item__c> lineItems) {
        sObject obj  = getRecord(objectName, recordId);
        String valueType = AITM_BaseUtils.getFieldValueType(objectName, fieldName);

        if(value == null){
            obj.put(fieldName, value);
        }else if(valueType == VALUE_TYPE_DOUBLE || valueType == VALUE_TYPE_PERCENT){
            Decimal convertedValue = Decimal.valueOf(value);
            obj.put(fieldName, convertedValue);
        } else if(valueType == VALUE_TYPE_INTEGER){
            Integer convertedValue = Integer.valueof(value);
            obj.put(fieldName, convertedValue);
        } else if(valueType == VALUE_TYPE_DATE){
            Date convertedValue = Date.valueOf(value);
            obj.put(fieldName, convertedValue);
        } else {
            obj.put(fieldName, value);
        }

        try {
            if(lineItems != null){
            updateChildRecords(lineItems, fieldName, value);
            }
            update obj;
            
        }catch(DMLException dmlError) {
            throw new AuraHandledException(dmlError.getMessage() + '-' + dmlError.getStackTraceString());   
        }

        return obj;
    }

   /**
    * @description updates the status of all related child items of tender location 
    * @param lineItems of type List<AITM_Tender_Location_Line_Item__c>
    * @param fieldName of type String
    * @param value of type String
    * @return null
    */
    private static void updateChildRecords(List<AITM_Tender_Location_Line_Item__c> lineItems, String fieldName, String value) {
        for(AITM_Tender_Location_Line_Item__c lineItem : lineItems) {
            if(fieldName == 'AITM_Status__c') {
                lineItem.AITM_Status__c = value;    
            }
        }
        if(!lineItems.isEmpty()){
                update lineItems;    
        }   
    }

   /**
    * @description gets record data
    * @param objectName of type string
    * @param recordId of type string
    * @return sObject
    */
    public static sObject getRecord(String objectName, String recordId){
        sObject obj;
        if (objectName == 'AITM_Tender_Location__c'){
            obj = new AITM_LocationsDao().getTenderLocation(recordId);
        } else if(objectName == 'AITM_Tender_Location_Line_Item__c'){
            obj = new AITM_LocationsDao().getTenderLocationLineItem(recordId);
        }
        return obj;
    }

   /**
    * @description gets picklist values data
    * @param objectName of type string
    * @param fieldName of type string
    * @return List<String>
    */
    @AuraEnabled
    public static List<String> getPickValues(String objectName, String fieldName){ 
        List<SelectOption> selectOptions = AITM_BaseUtils.getPickValues(objectName, fieldName, NULL);
        List<String> stringValues = new List<String>();
        for(SelectOption so : selectOptions){
            stringValues.add(so.getValue());
        }
        return stringValues;
    }

   /**
    * @description gets picklist values data
    * @param objectName of type string
    * @param fieldName of type string
    * @return void
    */
    @AuraEnabled
    public static void updateTenderLocationPricingBasis(AITM_Tender_Location__c tenderLocation){ 
        AITM_Tender_Location_Line_Item__c tendetLocationLineItem = [SELECT AITM_Tender_Location__c,AITM_Pricing_Basis__c,AITM_Offered_Differential__c,AITM_Current_Value__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Location_Delivery_Point__c, AITM_Unit_Of_Measure__c, AITM_Currency__c, AITM_Rebate__c, AITM_Unit_Of_Measure_Rebate__c, AITM_Currency_Rebate__c, AITM_Duration__c, AITM_Quantity__c, AITM_Exchange__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c=:tenderLocation.Id AND AITM_Pricing_Basis__c!=null ORDER BY LastModifiedDate DESC LIMIT 1];
        List<AITM_Tender_Location_Line_Item__c> tendetLocationLineItemList = new List<AITM_Tender_Location_Line_Item__c>();

        for(AITM_Tender_Location_Line_Item__c singleLineItem  : [SELECT AITM_Tender_Location__c,AITM_Current_Value__c,AITM_Pricing_Basis__c, AITM_Offered_Differential__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Location_Delivery_Point__c, AITM_Unit_Of_Measure__c, AITM_Currency__c, AITM_Rebate__c, AITM_Unit_Of_Measure_Rebate__c, AITM_Currency_Rebate__c, AITM_Duration__c, AITM_Quantity__c, AITM_Exchange__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c=:tenderLocation.Id]) {    
            if(singleLineItem.Id != tendetLocationLineItem.Id) {
                singleLineItem.AITM_Pricing_Basis__c = tendetLocationLineItem.AITM_Pricing_Basis__c ;
                singleLineItem.AITM_Offered_Differential__c = tendetLocationLineItem.AITM_Offered_Differential__c;
                singleLineItem.AITM_Current_Value__c = tendetLocationLineItem.AITM_Current_Value__c;
                singleLineItem.AITM_Start_Date__c = tendetLocationLineItem.AITM_Start_Date__c;
                singleLineItem.AITM_End_Date__c = tendetLocationLineItem.AITM_End_Date__c;
                singleLineItem.AITM_End_Date__c = tendetLocationLineItem.AITM_End_Date__c;
                singleLineItem.AITM_Location_Delivery_Point__c = tendetLocationLineItem.AITM_Location_Delivery_Point__c;
                singleLineItem.AITM_Unit_Of_Measure__c = tendetLocationLineItem.AITM_Unit_Of_Measure__c;
                singleLineItem.AITM_Currency__c = tendetLocationLineItem.AITM_Currency__c;
                singleLineItem.AITM_Rebate__c = tendetLocationLineItem.AITM_Rebate__c;
                singleLineItem.AITM_Unit_Of_Measure_Rebate__c = tendetLocationLineItem.AITM_Unit_Of_Measure_Rebate__c;
                singleLineItem.AITM_Currency_Rebate__c = tendetLocationLineItem.AITM_Currency_Rebate__c;
                singleLineItem.AITM_Duration__c = tendetLocationLineItem.AITM_Duration__c;
                singleLineItem.AITM_Quantity__c = tendetLocationLineItem.AITM_Quantity__c;
                singleLineItem.AITM_Exchange__c = tendetLocationLineItem.AITM_Exchange__c;

                tendetLocationLineItemList.add(singleLineItem);
            }
        }
        Database.update(tendetLocationLineItemList);
    }



   /**
    * @description gets picklist values data
    * @param objectName of type string
    * @param fieldName of type string
    * @return void
    */
    @AuraEnabled
    public static void updateTaxesandFeesToAllTLLI(AITM_Tender_Location__c tenderLocation){
        AITM_Tender_Location_Line_Item__c tenderLocationLineItem = [SELECT AITM_Taxes_Fees__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c=:tenderLocation.Id ORDER BY LastModifiedDate DESC LIMIT 1];
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItemList = new List<AITM_Tender_Location_Line_Item__c>();

        for(AITM_Tender_Location_Line_Item__c singleLineItem  : [SELECT AITM_Taxes_Fees__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c=:tenderLocation.Id]) {    
            if(singleLineItem.Id != tenderLocationLineItem.Id) {
                singleLineItem.AITM_Taxes_Fees__c = tenderLocationLineItem.AITM_Taxes_Fees__c ;

                tenderLocationLineItemList.add(singleLineItem);
            }
        }
        Database.update(tenderLocationLineItemList);
    }

   /**
    * @description gets details from Tender Location Line Items
    * @param recordId of type string
    * @return AITM_Tender_Location_Line_Item__c
    */
    @AuraEnabled 
    public static AITM_Tender_Location_Line_Item__c getDetailsFromTLLI(string recordId){
        AITM_Tender_Location_Line_Item__c tenderLocationLineItems = [SELECT AITM_Account__c,AITM_Start_Date__c,AITM_End_Date__c,AITM_Delivery_Point__c,AITM_Pricing_Basis__c,AITM_Description__c,AITM_Volume__c,AITM_Offered_Volume__c,AITM_Percentage_Volume_Offered__c,AITM_Previous_Round_Differential__c,AITM_Currency__c,AITM_Unit_Of_Measure__c  FROM AITM_Tender_Location_Line_Item__c WHERE Id = :recordId LIMIT 1];
        return tenderLocationLineItems;
    }

   /**
    * @description gets table data
    * @param null
    * @return List<AITM_Table_Tender_Location_New_Offer__mdt>
    */
    @AuraEnabled
    public static List<AITM_Table_Tender_Location_New_Offer__mdt> getTableMetadata() {
        List<AITM_Table_Tender_Location_New_Offer__mdt> result = [
            SELECT 
                MasterLabel, 
                AITM_Label_Text__c,
                AITM_Field_Name__c, 
                AITM_Field_Type__c, 
                AITM_Format__c, 
                AITM_Is_Editable__c, 
                AITM_Is_Table_Footer_Field__c, 
                AITM_Default_Value__c, 
                AITM_Target_Object__c, 
                AITM_Sort_Order__c
            FROM 
                AITM_Table_Tender_Location_New_Offer__mdt 
            ORDER BY AITM_Sort_Order__c ASC NULLS LAST
            LIMIT 100
        ];
        return result;
    }

    /**
     * @description gets fields access info
     * @param objectName of type string
     * @param tenderLocationId of type Id
     * @return Map<String, Map<String, Boolean>>
     */
    @AuraEnabled
    public static Map<String, Map<String, Boolean>> getFieldsAccess(String objectName, Id tenderLocationId){
        AITM_Tender_Location__c tenderLocation = new AITM_LocationsDao().getTenderLocation(tenderLocationId);
        List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems = new AITM_LocationsDao().getTenderLocationLineItemsWithDeliveryPointInfo(tenderLocationId);
        Set<Id> pricingResponsibilities = new Set<Id>();
        Set<String> pricingDelegates = new Set<String>();
        for(AITM_Tender_Location_Line_Item__c lineItem : tenderLocationLineItems) {
            if(lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'CA') {
                pricingResponsibilities.add(lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c);
                String delegatesCA = lineItem.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_ResponsibilityDeligates1__c;
                if(delegatesCA != null ) {
                    pricingDelegates.addAll(delegatesCA.toLowerCase().split(';'));
                }
            } else if(lineItem.AITM_Tender__r.AITM_Tender_Sector__c == 'GA') {
                pricingResponsibilities.add(lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c);
                String delegatesGA = lineItem.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_ResponsibilityDeligates1__c;
                if(delegatesGA != null ) {
                    pricingDelegates.addAll(delegatesGA.toLowerCase().split(';'));
                }
            }
        }
        Map<Id,User> pricingUsersMap = new AITM_UsersDao().getPricingUsersAndDelegates(pricingResponsibilities, pricingDelegates);        
        Id currentUserId = UserInfo.getUserId();
        Id locationManagerId = tenderLocation.AITM_Location_Manager__c;
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        Map<String, Map<String, Boolean>> fieldsAccess = new Map<String, Map<String, Boolean>>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldsMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        for(String fieldName : fieldsMap.keySet()) {
            Map<String, Boolean> fieldAccess = new Map<String, Boolean>();
            Boolean isUpdateable = fieldsMap.get(fieldName).getDescribe().isUpdateable();
            Boolean isCreateable = fieldsMap.get(fieldName).getDescribe().isCreateable();
            Boolean isAccessible = fieldsMap.get(fieldName).getDescribe().isAccessible();
            if(!pricingUsersMap.containsKey(currentUserId) && currentUserId != locationManagerId && !AITM_TenderLocationNewOffer.PROFILES_ALLOWED_TO_UPDATE.contains(profileName)){
                isUpdateable = false;
            }
            fieldAccess.put('isUpdateable', isUpdateable);
            fieldAccess.put('isCreateable', isCreateable);
            fieldAccess.put('isAccessible', isAccessible);
            fieldsAccess.put(fieldName, fieldAccess);
        }
        return fieldsAccess;
    }
}