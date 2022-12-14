/**
 * @author          Jan Majling
 * @date            07/09/2018
 * @group           CAJBP
 * @description     controller for lightning component CAJBP_RebateList
 *
 * history
 * 07/09/201    Jan Majling         Created 
 */
public with sharing class CAJBP_RebateListController {
    /**
     * @description gets scorecard record along with its rebates
     * @param jbpId of type Id
     * @return CAJBP_Scorecard__c
     */
    @AuraEnabled
    public static CAJBP_Scorecard__c getScorecardWithRebates(Id jbpId) {
         String [] rabatesFields = new String []{'Name',
                                                       'CAJBP_Rebate_Type_Name__c',
                                                       'CAJBP_Volume_Target__c',
                                                       'CAJBP_Turnover_Target__c',
                                                       'CAJBP_Target_Type__c',
                                                       'CurrencyIsoCode'
        
                                                    };
        String fieldlabel;    
    
        Map<String,Schema.SObjectField> m = Schema.SObjectType.CAJBP_Rebate__c.fields.getMap();
        for (String fieldToCheck : rabatesFields) {
          
          if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
             
             fieldlabel= m.get(fieldToCheck).getDescribe().getLabel();
             throw new AuraHandledException('Insufficient access to' + fieldlabel+ ' field.');
          }
        }
        
        
        List<CAJBP_Scorecard__c> scorecards = [
            SELECT Id, (
                SELECT RecordTypeId, CAJBP_Rebate_Type_Name__c, CAJBP_Volume_Target__c, CAJBP_Turnover_Target__c, CAJBP_Target_Type__c, CurrencyIsoCode
                FROM CAJBP_Rebates__r
            )
            FROM CAJBP_Scorecard__c
            WHERE CAJBP_Joint_Business_Plan__c = :jbpId
        ];
        return scorecards.get(0);
    }   
}