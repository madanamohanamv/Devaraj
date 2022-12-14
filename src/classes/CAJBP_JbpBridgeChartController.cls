/**
 * @author          Jan Majling
 * @date            17/09/2018
 * @group           CAJBP
 * @description     controller for lightning component CAJBP_JbpBridgeChart
 *
 * history
 * 17/09/2018   Jan Majling         Created 
 */
public with sharing class CAJBP_JbpBridgeChartController {
    /**
     * @description Record Data inner class
     */
    public class ChartData {
        @AuraEnabled
        public Integer previousYear;
        @AuraEnabled
        public Integer currentYear;
        @AuraEnabled
        public Decimal previousYearVolume;
        @AuraEnabled
        public Decimal targetValueVolume;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public List<CAJBP_JBP_Activity__c> activities;
    }   
    
    /**
     * @description gets chart data
     * @param jbpId of type Id
     * @return ChartData
     */
    @AuraEnabled
    public static ChartData getChartData(Id jbpId) {
        CAJBP_Joint_Business_Plan__c jbp = [
            SELECT RecordTypeId, CAJBP_Sell_In_YTD_Volume_Actuals_Exit_No__c, CAJBP_Year__c, CAJBP_Account__r.Name,
                (SELECT CAJBP_Sell_In_Volume_Plan__c, CAJBP_Total_Volume_Sell_In_Target__c
                FROM CAJBP_Scorecards__r),
                (SELECT Id FROM Objectives__r)
            FROM CAJBP_Joint_Business_Plan__c
            WHERE Id = :jbpId
        ].get(0);

        CAJBP_Scorecard__c scorecard = jbp.CAJBP_Scorecards__r.get(0);
        Boolean isIndirect = CAJBP_JbpBridgeChartController.isIndirectJbp(jbp.RecordTypeId);

        ChartData chartData = new ChartData();
        chartData.previousYearVolume = jbp.CAJBP_Sell_In_YTD_Volume_Actuals_Exit_No__c;
        chartData.currentYear = Integer.valueOf(jbp.CAJBP_Year__c);
        chartData.previousYear = chartData.currentYear - 1;
        chartData.targetValueVolume = isIndirect ? scorecard.CAJBP_Total_Volume_Sell_In_Target__c : scorecard.CAJBP_Sell_In_Volume_Plan__c;
        chartData.accountName = jbp.CAJBP_Account__r.Name;
        chartData.activities = CAJBP_JbpBridgeChartController.getActivities(jbp.Objectives__r);
        return chartData;
    }
    
    /**
     * @description gets activities from the provided objectives
     * @param objectives of type List<CAJBP_Objective__c>
     * @return List<CAJBP_JBP_Activity__c>
     */
    private static List<CAJBP_JBP_Activity__c> getActivities(List<CAJBP_Objective__c> objectives) {
        Set<Id> objectiveIds = new Set<Id>();
        String [] jbpActivitiesFields = new String []{'Name',
                                                       'CAJBP_Estimated_Volume__c',
                                                       'CAJBP_Estimated_Cost__c',
                                                       'CAJBP_Actual_Volume__c',
                                                       'CAJBP_Actual_Cost__c'
        
                                                    };
        String fieldlabel;                                            
        
        for(CAJBP_Objective__c objective : objectives) {
            objectiveIds.add(objective.Id);
        }
        
        Map<String,Schema.SObjectField> m = Schema.SObjectType.CAJBP_JBP_Activity__c.fields.getMap();
        for (String fieldToCheck : jbpActivitiesFields) {
          
          if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
             
             fieldlabel = m.get(fieldToCheck).getDescribe().getLabel();
             throw new AuraHandledException('Insufficient access to' + fieldlabel + ' field.');
          }
        }
            
         return [
                SELECT Name, CAJBP_Estimated_Volume__c, CAJBP_Estimated_Cost__c, CAJBP_Actual_Volume__c, CAJBP_Actual_Cost__c
                FROM CAJBP_JBP_Activity__c
                WHERE CAJBP_Objective__c IN :objectiveIds
                ORDER BY CAJBP_Start_Date__c
            ];
        
    }

    /**
     * @description checks whether the provided record type Id belongs to indirect JBP
     * @param recordTypeId of type Id
     * @return Boolean
     */
    private static Boolean isIndirectJbp(Id recordTypeId) {
        RecordTypeInfo recordTypeInfo = CAJBP_Joint_Business_Plan__c.sObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId);
        return recordTypeInfo.getDeveloperName().contains('Indirect');
    }
}