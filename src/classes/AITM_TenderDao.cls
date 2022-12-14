/***********************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Used for storing queries related to Tenders, Tender Customer, Tender Location Staging, 
 *                   Tender Location and Tender Location Line Item objects which can be reused in all related classes.

 * history
 * 01/December/2017  George          Created
 * 26/March/2018     Ravi Pamidi     Modified - AR-2404 Commented De-brief Executive Summary fields to change from Text to Rich Text
 * 28/March/2018     Shweta          Modified - AR-2808 Updated the method  getTenderWithAwaitingPriceTenderLocationsAndTenderAccounts to include the 
 *                                   field AITM_Requested_Volume_UoM__c in the query 
 * 04/June/2018      srnandan        Modified - AR-3113 Removed AITM_Contract_Is_Sent_To_A_Customer__c field from getTender method
 * 04/July/2018      srnandan        Modified - AR- added contant NOT_REPRESENTED_STATUS 
 *                                   and method getTenderWithAwaitAndNotRepresentTenderLocationsAndTenderAccounts
 * 08/August/2018    srnandan        Modified method getTenderWithAwaitingPriceTenderLocationsAndTenderAccounts(Id tenderId, String locationType) -Added AITM_Unit_Of_Measure in soql
 * 09/August/2018    srnandan        Modified method getTenderWithAwaitingPriceTenderLocationsAndTenderAccounts and
 *                                   getTenderWithAwaitAndNotRepresentTenderLocationsAndTenderAccounts soql AITM_Credit_Days__c to AITM_Credit_Days1__c
 * 12/August/2018    srnandan        AR-3316 - Added method getTenderWithTenderLocationsAndTenderAccounts
 * 18/August/2018    srnandan        AR-3316 - Added method getTenderWithPricedTenderLocations
 * 05/Sep/2018       Saravan         Modified AR-4161 - updated getTender method to include Owner email
 * 21/Oct/2018       srnandan        Modified AR-XXXX - added new methods updateFeedbackSent and updateLABPFeedbackSent
 * 07/January/2019   srnandan        Added method getTenderWithTenderLocations for labp (multiple location check)
 * 18/January/2019   srnandan        Modified the method getTenderWithAwaitAndNotRepresentTenderLocationsAndTenderAccounts, getTender to include AITM_Tender_Information__c in soql
 * 30/January/2019    Shweta         Added method getAwaitingPriceTenderLocations to get the tender locations in the awaiting price status only
 * 09/April/2019     Ravi            Modified - AR-5122 Updated the queries to populate Tender Sector
 * 17/04/2019        srnandan        Modified - AR-   added soql field AITM_Locations_Filter__c to the method getTenderWithTenderLocations
 *******************************************************************************************/
public without sharing class AITM_TenderDao {

    private static final String STATUS_AWAITING_PRICE = 'Awaiting Price';
    private static final String NOT_REPRESENTED_STATUS = 'Not Represented';
    private static final String STATUS_PRICED = 'Priced';
    private static final Set<String> STATUS_AWAIT_AND_NOT_REPRESENTED = new Set<String>{STATUS_AWAITING_PRICE, NOT_REPRESENTED_STATUS};
    public static final String POLISH = 'Polish';
    public static final String NONPOLISH = 'Non Polish';
    
    /**
     * @description gets the tender details
     * @param tenderId of Id
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTender(Id tenderId) {
     return [SELECT Name, Owner.Name, Owner.Email, AITM_ROWC_Previous_Contract__c, AITM_Tender_Sector__c, AITM_ROWC_New_Contract__c, AITM_Price_Perf_Index_Prev_Contract__c, AITM_Price_Perf_Index_New_Contract__c, AITM_Working_Capital_New_Contract__c, AITM_Working_Capital_Previous_Contract__c, AITM_Volume_Previous_Contract__c, AITM_Gross_Profit_Previous_Contract__c, AITM_Gross_Profit_New_Contract__c, AITM_Tender_Process__c, AITM_Tender_Preparation__c, AITM_What_Went_Well__c, AITM_What_Could_Have_Gone_Better__c, AITM_What_Have_We_Learnt__c, AITM_Cust_Talk_Influence_Req_Conducted__c, AITM_Is_Customer_Talk_Infl_Req_Conducted__c, AITM_Is_Multi_Year_Int_Scheme_Offered__c, AITM_Multi_Year_Int_Offered_Comment__c, AITM_Is_Pro_Active_Package_Offered__c, AITM_Pro_Active_Package_Offered_Comment__c, AITM_Start_Date__c, AITM_Offer_Sent_To_A_Customer__c, AITM_End_Date__c, AITM_Stage__c, AITM_Bids_In_By__c, AITM_Email__c, AITM_Gross_Profit_Notes__c, AITM_Volume_Notes__c, AITM_Working_Capital_Notes__c, AITM_Price_Performance_Index_Notes__c, AITM_ROWC_Notes__c, AITM_Volume_New_Contract__c, AITM_Produce_Customer_Email__c, AITM_Notes_On_Feedback__c, AITM_Number_Of_Rounds__c, AITM_Quality_Of_Feedback__c, AITM_Send_Feedback_Notification__c, AITM_Send_LABP_Feedback_Notification__c, AITM_Last_Look_To_Incumbent__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Tender_Context__c, AITM_Notes_For_Tender__c, AITM_Recognition_And_Shout_Outs__c FROM AITM_Tender__c WHERE Id = :tenderId LIMIT 1];
    }
    
    /**
     * @description gets the tender details related to feedback flag fields
     * @param tenderId of Id
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTenderStage(Id tenderId) {
     return [SELECT AITM_Stage__c, AITM_Send_Feedback_Notification__c, AITM_Send_LABP_Feedback_Notification__c, AITM_No_Feedback_Progress_To_De_Brief__c FROM AITM_Tender__c WHERE Id = :tenderId LIMIT 1];
    }
    
    /**
     * @description gets tender email contract sent flag
     * @param tenderId of Id
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTenderEmailContractSent(Id tenderId) {
        return [SELECT AITM_Contract_Is_Sent_To_A_Customer__c, AITM_Stage__c FROM AITM_Tender__c WHERE Id = :tenderId LIMIT 1];
    }

    /**
     * @description update feedback sent
     * @param tenderId of Id
     * @return AITM_Tender__c
     */
    public void updateFeedbackSent(Id tenderId) {
        AITM_Tender__c tender = [SELECT AITM_Stage__c, AITM_Send_Feedback_Notification__c FROM AITM_Tender__c WHERE Id = :tenderId LIMIT 1];
        tender.AITM_Send_Feedback_Notification__c = true;
        update tender;
    }

    /**
     * @description gets the tenderlocations in awaiting price only
     * @param tenderlocations of type List<AITM_Tender_Location__c>
     * @return List<AITM_Tender_Location__c>
     */

    public List<AITM_Tender_Location__c> getAwaitingPriceTenderLocations(List<AITM_Tender_Location__c> tenderlocations){
        return [Select AITM_IATA_ICAO__c,AITM_Location__r.Name from AITM_Tender_Location__c where AITM_Is_Current_Round__c = true AND Id =:tenderlocations AND AITM_Status__c =:STATUS_AWAITING_PRICE];
    }

    /**
     * @description update labp feedback sent
     * @param tenderId of Id
     * @return AITM_Tender__c
     */
    public void updateLABPFeedbackSent(Id tenderId) {
        AITM_Tender__c tender = [SELECT AITM_Stage__c, AITM_Send_LABP_Feedback_Notification__c FROM AITM_Tender__c WHERE Id = :tenderId LIMIT 1];
        tender.AITM_Send_LABP_Feedback_Notification__c = true;
        update tender;
    }

    /**
     * @description multiple locations
     * @param  tenderId of type Id
     * @return Map<String,Boolean>
     */
    public Map<String,Boolean> multipleLocations(Id tenderId) {
        Map<String, Boolean> mapLocations = new Map<String,Boolean>();
        for(AITM_Tender_Location__c location : new AITM_TenderDao().getTenderWithTenderLocations(tenderId).AITM_Tender_Locations__r) {
            if(location.AITM_Locations_Filter__c != null && location.AITM_Locations_Filter__c == POLISH) {
                if(!mapLocations.containsKey('Polish')) {
                    mapLocations.put('Polish', true);
                } 
            } else {
                if(!mapLocations.containsKey('NonPolish')) {
                    mapLocations.put('NonPolish', true);
                }
            }
        }
        return mapLocations;
    }

    /**
     * @description gets tender documents
     * @param tenderId of Id
     * @param documentName of string
     * @return List<ContentVersion>
     */
    public List<ContentVersion> getTenderDocuments(Id tenderId, String documentName) {
        Set<Id> allRelatedToTheTenderDocumentIds = this.getAllRelatedToTheTenderDocumentIds(tenderId);
        Integer hardLimit = getTenderAccountsSizeForTender(tenderId);
        String documentNameSOQL = documentName + '%';
        return this.getLatestVersionOfContentDocument(allRelatedToTheTenderDocumentIds, documentNameSOQL, hardLimit);
    }

    /**
     * @description gets tender with tender locations
     * @param tenderIds Collection list of Id
     * @return List<AITM_Tender__c>
     */
    public List<AITM_Tender__c> getTenderWithTenderLocations(List<Id> tenderIds) {
        return [SELECT AITM_Stage__c, AITM_Send_Invitation_Notification__c, (SELECT AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c FROM AITM_Tender_Locations__r) FROM AITM_Tender__c WHERE Id IN :tenderIds];
    }

    /**
     * @description gets tender with current round tender locations
     * @param tenderIds Set collection of Id
     * @return List<AITM_Tender__c>
     */
    public List<AITM_Tender__c> getTenderWithCurrentRoundTenderLocations(Set<Id> tenderIds) {
        return [SELECT AITM_Stage__c, AITM_Send_Invitation_Notification__c, (SELECT AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true) FROM AITM_Tender__c WHERE Id IN :tenderIds];
    }

    /**
     * @description gets tender with awaiting price tenderlocation and tender accounts
     * @param tenderIds List collection of Id
     * @return List<AITM_Tender__c>
     */
    public List<AITM_Tender__c> getTenderWithAwaitingPriceTenderLocationsAndTenderAccounts(List<Id> tenderIds) {
        return [SELECT Name, Owner.Name, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Sector__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Bids_In_By__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Quality_Of_Feedback__c, AITM_Notes_On_Feedback__c, 
        (SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.Email, AITM_IATA_ICAO__c, AITM_Location__r.AITM_Delegates__c, AITM_Is_Current_Round__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true AND AITM_Status__c =:STATUS_AWAITING_PRICE  ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC), 
        (SELECT AITM_GRN__c, AITM_Customer_Name__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Accounts__r), 
        (SELECT AITM_Tender_Location__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Volume__c, AITM_Offered_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis_Description__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Tender_Result__c,AITM_Requested_Volume_UoM__c,RecordType.Name FROM AITM_Tender_Location_Line_Items__r WHERE AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c =:STATUS_AWAITING_PRICE) 
        FROM AITM_Tender__c WHERE Id IN :tenderIds];
    }

    /**
     * @description gets tender with awaiting price and not represented tenderlocations and tender accounts
     * @param tenderId of Id
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTenderWithAwaitingPriceTenderLocationsAndTenderAccounts(Id tenderId) {
        return [SELECT Name, Owner.Name, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Sector__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Bids_In_By__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Quality_Of_Feedback__c, AITM_Notes_On_Feedback__c, 
        (SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.Email, AITM_IATA_ICAO__c, AITM_Location__r.AITM_Delegates__c, AITM_Is_Current_Round__c, AITM_Country__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true AND AITM_Status__c =:STATUS_AWAITING_PRICE  ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC), 
        (SELECT AITM_GRN__c, AITM_Customer_Name__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Accounts__r), 
        (SELECT AITM_Tender_Location__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Volume__c, AITM_Offered_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis_Description__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Tender_Result__c,AITM_Requested_Volume_UoM__c,RecordType.Name,AITM_History_Line_Item__r.AITM_Account__r.Name,AITM_History_Line_Item__r.AITM_Account__r.AITM_GRN__c,AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Volume__c,AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name,AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c,AITM_History_Line_Item__r.AITM_Delivery_Point_Info__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c,AITM_History_Line_Item__r.AITM_Currency__c,AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c,AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c FROM AITM_Tender_Location_Line_Items__r WHERE AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c =:STATUS_AWAITING_PRICE) 
        FROM AITM_Tender__c WHERE Id = :tenderId];
    }

    /**
     * @description gets tender with priced tenderlocations and tender accounts
     * @param tenderId of Id
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTenderWithPricedTenderLocations(Id tenderId) {
        return [SELECT Name, Owner.Name, AITM_Stage__c, 
        (SELECT AITM_Location__r.Name, AITM_Country__c, AITM_Status__c, AITM_Current_Round__c, AITM_Tender__c, AITM_Is_Current_Round__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true AND AITM_Status__c =:STATUS_PRICED ORDER BY AITM_Country__c ASC), 
        (SELECT AITM_Tender_Location__c  FROM AITM_Tender_Location_Line_Items__r WHERE AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c =:STATUS_PRICED) 
        FROM AITM_Tender__c WHERE Id = :tenderId];
    }

    /**
     * @description gets tender tenderlocations and tender accounts
     * @param tenderId of Id
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTenderWithTenderLocationsAndTenderAccounts(Id tenderId) {
        return [SELECT Name, Owner.Name, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Sector__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Bids_In_By__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Quality_Of_Feedback__c, AITM_Notes_On_Feedback__c, 
        (SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.Email, AITM_IATA_ICAO__c, AITM_Location__r.AITM_Delegates__c, AITM_Is_Current_Round__c, AITM_Country__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC), 
        (SELECT AITM_GRN__c, AITM_Customer_Name__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Accounts__r), 
        (SELECT AITM_Tender_Location__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Volume__c, AITM_Offered_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis_Description__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Tender_Result__c,AITM_Requested_Volume_UoM__c,RecordType.Name,AITM_History_Line_Item__r.AITM_Account__r.Name,AITM_History_Line_Item__r.AITM_Account__r.AITM_GRN__c,AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Volume__c,AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name,AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c,AITM_History_Line_Item__r.AITM_Delivery_Point_Info__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c,AITM_History_Line_Item__r.AITM_Currency__c,AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c,AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c FROM AITM_Tender_Location_Line_Items__r WHERE AITM_Is_Current_Round__c = true) 
        FROM AITM_Tender__c WHERE Id = :tenderId];
    }

    /**
     * @description gets tender tenderlocations
     * @param tenderId of Id
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTenderWithTenderLocations(Id tenderId){
        return [SELECT Name, Owner.Name, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, 
        (SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.Email, AITM_IATA_ICAO__c, AITM_Is_Current_Round__c, AITM_Country__c, AITM_Locations_Filter__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC)
        FROM AITM_Tender__c WHERE Id = :tenderId];        
    }
    
    /**
     * @description gets tender with awaiting price and not represented tenderlocations and tender accounts
     * @param tenderId of Id
     * @param locationType of String
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTenderWithAwaitingPriceTenderLocationsAndTenderAccounts(Id tenderId, String locationType) {
        if(locationType == POLISH) {
            return [SELECT Name, Owner.Name, AITM_Unit_Of_Measure__c, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Sector__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Bids_In_By__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Quality_Of_Feedback__c, AITM_Notes_On_Feedback__c, 
            (SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.Email, AITM_IATA_ICAO__c, AITM_Location__r.AITM_Delegates__c, AITM_Is_Current_Round__c, AITM_Country__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true AND AITM_Status__c =:STATUS_AWAITING_PRICE  AND AITM_Locations_Filter__c =:POLISH ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC), 
            (SELECT AITM_GRN__c, AITM_Customer_Name__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Accounts__r), 
            (SELECT AITM_Tender_Location__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Volume__c, AITM_Offered_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis_Description__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Tender_Result__c,AITM_Requested_Volume_UoM__c,RecordType.Name,AITM_History_Line_Item__r.AITM_Account__r.Name,AITM_History_Line_Item__r.AITM_Account__r.AITM_GRN__c,AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Volume__c,AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name,AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c,AITM_History_Line_Item__r.AITM_Delivery_Point_Info__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c,AITM_History_Line_Item__r.AITM_Currency__c,AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c,AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c,AITM_Location_Delivery_Point__c,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name,AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c,AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name,AITM_Pricer_No_Default_Delivery_Points__r.Name FROM AITM_Tender_Location_Line_Items__r WHERE AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c =:STATUS_AWAITING_PRICE AND AITM_Tender_Location__r.AITM_Locations_Filter__c =:POLISH) 
            FROM AITM_Tender__c WHERE Id = :tenderId];
        }else {
           return [SELECT Name, Owner.Name, AITM_Unit_Of_Measure__c, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Sector__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Bids_In_By__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Quality_Of_Feedback__c, AITM_Notes_On_Feedback__c, 
            (SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.Email, AITM_IATA_ICAO__c, AITM_Location__r.AITM_Delegates__c, AITM_Is_Current_Round__c, AITM_Country__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true AND AITM_Status__c =:STATUS_AWAITING_PRICE  AND AITM_Locations_Filter__c !=:POLISH ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC), 
            (SELECT AITM_GRN__c, AITM_Customer_Name__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Accounts__r), 
            (SELECT AITM_Tender_Location__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Volume__c, AITM_Offered_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis_Description__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Tender_Result__c,AITM_Requested_Volume_UoM__c,RecordType.Name,AITM_History_Line_Item__r.AITM_Account__r.Name,AITM_History_Line_Item__r.AITM_Account__r.AITM_GRN__c,AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Volume__c,AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name,AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c,AITM_History_Line_Item__r.AITM_Delivery_Point_Info__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c,AITM_History_Line_Item__r.AITM_Currency__c,AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c,AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c,AITM_Location_Delivery_Point__c,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name,AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c,AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name,AITM_Pricer_No_Default_Delivery_Points__r.Name FROM AITM_Tender_Location_Line_Items__r WHERE AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c =:STATUS_AWAITING_PRICE AND AITM_Tender_Location__r.AITM_Locations_Filter__c !=:POLISH) 
            FROM AITM_Tender__c WHERE Id = :tenderId]; 
        }
    }

    /**
     * @description gets tender with awaiting price tenderlocation and tender accounts
     * @param tenderId of Id
     * @param locationType of String
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTenderWithAwaitAndNotRepresentTenderLocationsAndTenderAccounts(Id tenderId, String locationType) {
        if(locationType == POLISH) {
            return [SELECT Name, Owner.Name, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Sector__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Bids_In_By__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Quality_Of_Feedback__c, AITM_Notes_On_Feedback__c, 
            (SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.Email, AITM_IATA_ICAO__c, AITM_Location__r.AITM_Delegates__c, AITM_Is_Current_Round__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true AND AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED AND AITM_Locations_Filter__c =:POLISH ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC), 
            (SELECT AITM_GRN__c, AITM_Customer_Name__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Accounts__r), 
            (SELECT AITM_Tender_Location__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Volume__c, AITM_Offered_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis_Description__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Tender_Result__c,AITM_Requested_Volume_UoM__c,RecordType.Name,AITM_History_Line_Item__r.AITM_Account__r.Name,AITM_History_Line_Item__r.AITM_Account__r.AITM_GRN__c,AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Volume__c,AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name,AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c,AITM_History_Line_Item__r.AITM_Delivery_Point_Info__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c,AITM_History_Line_Item__r.AITM_Currency__c,AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c,AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c,AITM_Location_Delivery_Point__c,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name,AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c,AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name,AITM_Pricer_No_Default_Delivery_Points__r.Name FROM AITM_Tender_Location_Line_Items__r WHERE AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED AND AITM_Tender_Location__r.AITM_Locations_Filter__c =:POLISH ORDER BY AITM_Tender_Location__r.AITM_Status__c ASC) 
            FROM AITM_Tender__c WHERE Id = :tenderId];
        } else {
            return [SELECT Name, Owner.Name, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Sector__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Bids_In_By__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Quality_Of_Feedback__c, AITM_Notes_On_Feedback__c, 
            (SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c, AITM_Total_Volume_Offered_To_The_Group__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.Email, AITM_IATA_ICAO__c, AITM_Location__r.AITM_Delegates__c, AITM_Is_Current_Round__c FROM AITM_Tender_Locations__r WHERE AITM_Is_Current_Round__c = true AND AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED AND AITM_Locations_Filter__c !=:POLISH ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC), 
            (SELECT AITM_GRN__c, AITM_Customer_Name__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Accounts__r), 
            (SELECT AITM_Tender_Location__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, AITM_Volume__c, AITM_Offered_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, AITM_Pricing_Basis_Description__c, AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Offered_Differential__c, AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Tender_Result__c,AITM_Requested_Volume_UoM__c,RecordType.Name,AITM_History_Line_Item__r.AITM_Account__r.Name,AITM_History_Line_Item__r.AITM_Account__r.AITM_GRN__c,AITM_History_Line_Item__r.AITM_Tender_Result__c,AITM_History_Line_Item__r.AITM_Volume__c,AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name,AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c,AITM_History_Line_Item__r.AITM_Delivery_Point_Info__c,AITM_History_Line_Item__r.AITM_Offered_Differential__c,AITM_History_Line_Item__r.AITM_Currency__c,AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c,AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c,AITM_Location_Delivery_Point__c,AITM_Tender__r.AITM_Tender_Sector__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c,AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c,AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name,AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c,AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name,AITM_Pricer_No_Default_Delivery_Points__r.Name FROM AITM_Tender_Location_Line_Items__r WHERE AITM_Is_Current_Round__c = true AND AITM_Tender_Location__r.AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED AND AITM_Tender_Location__r.AITM_Locations_Filter__c !=:POLISH ORDER BY AITM_Tender_Location__r.AITM_Status__c ASC) 
            FROM AITM_Tender__c WHERE Id = :tenderId];
        }
    }
    
    /**
     * @description gets tender with awaiting price tenderlocation and tender accounts
     * @param tenderId of Id
     * @param locationType of String
     * @return AITM_Tender__c
     */
    public AITM_Tender__c getTenderWithAwaitAndNotRepresentTenderAndTenderAccounts(Id tenderId, String locationType) {
        if(locationType == POLISH) {
            return [SELECT Name, Owner.Name, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Sector__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Bids_In_By__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Quality_Of_Feedback__c, AITM_Notes_On_Feedback__c,             
            (SELECT AITM_GRN__c, AITM_Customer_Name__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Accounts__r)
            FROM AITM_Tender__c WHERE Id = :tenderId];
        } else {
            return [SELECT Name, Owner.Name, AITM_Stage__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Tender_Sector__c, AITM_Arl_Prfl_And_Tndr_Information__c, AITM_Tender_Information__c, AITM_Bids_In_By__c, AITM_Number_Of_Rounds__c, AITM_Last_Look_To_Incumbent__c, AITM_Quality_Of_Feedback__c, AITM_Notes_On_Feedback__c, 
            (SELECT AITM_GRN__c, AITM_Customer_Name__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Accounts__r) 
            FROM AITM_Tender__c WHERE Id = :tenderId];
        }
    }
    
    public List<AITM_Tender_Location__c> getTenderWithAwaitAndNotRepresentLocations(Id tenderId, String locationType) {
        if(locationType == POLISH) {
            return [SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c, 
            AITM_Total_Volume_Offered_To_The_Group__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, AITM_Location_Manager__r.Email, 
            AITM_IATA_ICAO__c, AITM_Location__r.AITM_Delegates__c, AITM_Is_Current_Round__c FROM AITM_Tender_Location__c 
            WHERE AITM_Tender__c =:tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED 
            AND AITM_Locations_Filter__c =:POLISH ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC];
        } else {
            return [SELECT AITM_Location__r.Name, AITM_Status__c, AITM_Round__c, AITM_Current_Round__c, AITM_Tender__c, 
            AITM_Total_Volume_Offered_To_The_Group__c, AITM_Location_Manager__c, AITM_Location_Manager__r.Name, 
            AITM_Location_Manager__r.Email, AITM_IATA_ICAO__c, AITM_Location__r.AITM_Delegates__c, AITM_Is_Current_Round__c 
            FROM AITM_Tender_Location__c WHERE AITM_Tender__c =:tenderId AND AITM_Is_Current_Round__c = true 
            AND AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED AND AITM_Locations_Filter__c !=:POLISH
            ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC];            
        }
    }
    
    
    public List<AITM_Tender_Location__c> getTenderLocations(Id tenderId, String locationType) {
        if(locationType == POLISH) {
            return [SELECT Id FROM AITM_Tender_Location__c 
            WHERE AITM_Tender__c =:tenderId AND AITM_Is_Current_Round__c = true AND AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED 
            AND AITM_Locations_Filter__c =:POLISH ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC];
        } else {
            return [SELECT Id 
            FROM AITM_Tender_Location__c WHERE AITM_Tender__c =:tenderId AND AITM_Is_Current_Round__c = true 
            AND AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED AND AITM_Locations_Filter__c !=:POLISH 
            ORDER BY AITM_Location_Manager__r.Name ASC, AITM_Country__c ASC];            
        }
    }
    
    /**
     * @description gets tender with awaiting price tenderlocation and tender accounts
     * @param tenderId of Id
     * @param locationType of String
     * @return AITM_Tender__c
     */
    public List<AITM_Tender_Location_Line_Item__c> getTenderWithAwaitAndNotRepresentTenderLocationLineItems(Id tenderId, String locationType) {
        if(locationType == POLISH) {
            return [SELECT AITM_Tender_Location__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, 
                AITM_Volume__c, AITM_Offered_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, 
                AITM_Pricing_Basis_Description__c, AITM_Tender_Location__r.AITM_Status__c, AITM_Tender_Location__r.AITM_Country__c,
                AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Offered_Differential__c, 
                AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Tender_Result__c,AITM_Requested_Volume_UoM__c,
                RecordType.Name,AITM_History_Line_Item__r.AITM_Account__r.Name,
                AITM_History_Line_Item__r.AITM_Account__r.AITM_GRN__c,AITM_History_Line_Item__r.AITM_Tender_Result__c,
                AITM_History_Line_Item__r.AITM_Volume__c,AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name,
                AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c,AITM_History_Line_Item__r.AITM_Delivery_Point_Info__c,
                AITM_History_Line_Item__r.AITM_Offered_Differential__c,AITM_History_Line_Item__r.AITM_Currency__c,
                AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c,AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c,
                AITM_Location_Delivery_Point__c,AITM_Tender__r.AITM_Tender_Sector__c,
                AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c,
                AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name,
                AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c,
                AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name,
                AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c,
                AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name,
                AITM_Pricer_No_Default_Delivery_Points__r.Name FROM AITM_Tender_Location_Line_Item__c 
                WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND 
                AITM_Tender_Location__r.AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED 
                AND AITM_Tender_Location__r.AITM_Locations_Filter__c =:POLISH 
                ORDER BY AITM_Tender_Location__r.AITM_Status__c ASC
            ];
        } else {
            return [SELECT AITM_Tender_Location__c, AITM_Account__r.AITM_GRN__c, AITM_Account__r.Name, AITM_Requested_Volume_USG__c, 
                AITM_Volume__c, AITM_Offered_Volume__c, AITM_Start_Date__c, AITM_End_Date__c, AITM_Pricing_Basis__r.Name, 
                AITM_Pricing_Basis_Description__c, AITM_Tender_Location__r.AITM_Status__c, AITM_Tender_Location__r.AITM_Country__c,
                AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c, AITM_Offered_Differential__c, 
                AITM_Currency__c, AITM_Unit_Of_Measure__c, AITM_Tender_Result__c,AITM_Requested_Volume_UoM__c,
                RecordType.Name,AITM_History_Line_Item__r.AITM_Account__r.Name,
                AITM_History_Line_Item__r.AITM_Account__r.AITM_GRN__c,AITM_History_Line_Item__r.AITM_Tender_Result__c,
                AITM_History_Line_Item__r.AITM_Volume__c,AITM_History_Line_Item__r.AITM_Pricing_Basis__r.Name,
                AITM_History_Line_Item__r.AITM_Pricing_Basis_Description__c,AITM_History_Line_Item__r.AITM_Delivery_Point_Info__c,
                AITM_History_Line_Item__r.AITM_Offered_Differential__c,AITM_History_Line_Item__r.AITM_Currency__c,
                AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c,AITM_History_Line_Item__r.AITM_Requested_Volume_UoM__c,
                AITM_Location_Delivery_Point__c,AITM_Tender__r.AITM_Tender_Sector__c,
                AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c,
                AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name,
                AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c,
                AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name,
                AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c,
                AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name,
                AITM_Pricer_No_Default_Delivery_Points__r.Name FROM AITM_Tender_Location_Line_Item__c 
                WHERE AITM_Tender__c = :tenderId AND AITM_Is_Current_Round__c = true AND 
                AITM_Tender_Location__r.AITM_Status__c in :STATUS_AWAIT_AND_NOT_REPRESENTED 
                AND AITM_Tender_Location__r.AITM_Locations_Filter__c !=:POLISH
                ORDER BY AITM_Tender_Location__r.AITM_Status__c ASC
            ];
        }
    }
    
    /**
     * @description gets sector by id
     * @param tenderId of Id
     * @return string
     */
    public String getSectorById(Id tenderId) {
        List<AITM_Tender__c> tenders = [SELECT AITM_Tender_Sector__c FROM AITM_Tender__c WHERE Id = :tenderId LIMIT 1];
        String result = '';
        if (tenders.size() > 0) {
           result = tenders[0].AITM_Tender_Sector__c;
        }
        return result;
    }

    /**
     * @description gets mapped sector by ids
     * @param tenderIds set collection of Id
     * @return Map<Id, String>
     */
    public Map<Id, String> getMapedSectorsByIds(Set<Id> tenderIds) {
        Map<Id, String> result = new Map<Id, String>();
        for (AITM_Tender__c tender : [SELECT Id, AITM_Tender_Sector__c FROM AITM_Tender__c WHERE Id IN :tenderIds]) {
            result.put(tender.Id, tender.AITM_Tender_Sector__c);
        }
        return result;
    }

    /**
     * @description gets contentversionbody by contentversion id
     * @param contentVersionId of Id
     * @return Blob
     */
    public Blob getContentVersionBodyByContentVersionId(Id contentVersionId) {
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1][0];
        return cv.VersionData;
    }

    /**
     * @description gets contentversionbody by contentversion ids
     * @param contentVersionId of Id
     * @return Map<Id,Blob>
     */
    public Map<Id, Blob> getContentVersionBodyByContentVersionIds(Set<Id> contentVersionIds) {
        Map<Id, Blob> result = new Map<Id, Blob>();
        for (ContentVersion cv : [SELECT Id, VersionData FROM ContentVersion WHERE Id IN :contentVersionIds]) {
            result.put(cv.Id, cv.VersionData);
        }
        return result;
    }

    /**
     * @description gets latestversion of content document
     * @param relatedTenderDocumentIds set collection of Id
     * @param documentName of type string
     * @param hardLimit of type integer
     * @return List<ContentVersion>
     */
    private List<ContentVersion> getLatestVersionOfContentDocument(Set<Id> relatedTenderDocumentIds, String documentName, Integer hardLimit) {
        return [SELECT PathOnClient, ContentModifiedDate, ContentDocumentId FROM ContentVersion WHERE Id IN :relatedTenderDocumentIds AND PathOnClient LIKE :documentName ORDER BY ContentModifiedDate DESC LIMIT :hardLimit];
    }

    /**
     * @description gets all relatedto tenderdocuments ids
     * @param tenderId of type Id
     * @return Set<Id>
     */
    private Set<Id> getAllRelatedToTheTenderDocumentIds(Id tenderId) {
        Set<Id> allRelatedToTheTenderDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId = :tenderId]) {
            allRelatedToTheTenderDocumentIds.add(link.ContentDocument.LatestPublishedVersionId);
        }
        return allRelatedToTheTenderDocumentIds;
    }

    /**
     * @description gets tenderaccounts size for a given tender
     * @param tenderId of type Id
     * @return Integer
     */
    public Integer getTenderAccountsSizeForTender(Id tenderId) {
        return [SELECT Count() FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :tenderId];    
    }

    /**
     * @description gets tenderaccounts for a given tender
     * @param tenderId of type Id
     * @return List of AITM_Tender_Account__c
     */    
    public List<AITM_Tender_Account__c> getTenderAccount(Id tenderId) {
        return [SELECT AITM_Customer_Name__c, AITM_GRN__c, AITM_Invoice_Frequency__c, AITM_Credit_Days1__c, AITM_Security_Type__c, AITM_Customer_Segment__c, AITM_Customer_Type__c, AITM_Tender__r.AITM_Density__c, AITM_Aircraft_Fleet__c FROM AITM_Tender_Account__c WHERE AITM_Tender__c = :tenderId];
    }
}