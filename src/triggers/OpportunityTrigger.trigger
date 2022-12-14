/************************************************************************************************************
* Description : Apex trigger for the Opportunity object. This trigger will send Chatter message whenever there
*               is inactive product and the opportunity is moved from closed to open stage.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-DEC-01   1.0                 Maros Zilka         Initial version 
*
*************************************************************************************************************/

trigger OpportunityTrigger on Opportunity (after update) {
   if(trigger.isAfter && trigger.isUpdate){

        //Send chatter feed for open opportunity with inactive product.
        CASFO_InactiveProductTrigerHandler.sendChatter(trigger.oldMap, trigger.newMap);
    }
}