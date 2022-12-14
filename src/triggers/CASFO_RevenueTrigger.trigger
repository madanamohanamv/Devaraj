/************************************************************************************************************
* Description : Apex trigger for the Revenue__c object.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-NOV-22   1.0                 Maros Zilka         Initial version - after insert only 
*
*************************************************************************************************************/

trigger CASFO_RevenueTrigger on Revenue__c (after insert) {
    Revenue__c revenueWithProductCode;
    List<Id> opportunities = new List<Id>();

    // isAfter logic
    if(trigger.isAfter){

        // isAfter and isInsert logic 
        if(trigger.isInsert){
            
            Map<Id, Revenue__c> revenueProductMap = new Map<Id, Revenue__c>([SELECT Id, Product__r.ProductCode    
                                                                             FROM Revenue__c 
                                                                             WHERE Id IN :Trigger.New]);
            
            for (Revenue__c revenue : Trigger.new) {
                revenueWithProductCode = revenueProductMap.get(revenue.id);
                
                if (revenueWithProductCode.Product__r.ProductCode == null || revenueWithProductCode.Product__r.ProductCode != 'EST') {
                    opportunities.add(revenue.Opportunity__c);
                }
            }
            
            if (opportunities.size() > 0) {
                delete [SELECT Id FROM Revenue__c WHERE Opportunity__r.Id IN :opportunities AND Product__r.ProductCode = :'EST'];
            }
        }
    }
}