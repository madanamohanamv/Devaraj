/**
* @author			Jan Majling
* @date			03/10/2018
* @description		handles trigger events on Account object
*
* history
* 03/10/2018	Jan Majling			Created 
*/
public with sharing class AccountTriggerHandler {
    
    private final  List<Account> newRecords;
    private final List<Account> oldRecords;
    private final Map<Id, Account> newMap;
    private final Map<Id, Account> oldMap; 
    /**
* @description constructor
* @param newRecords of type List<Account>
* @param oldRecords of type List<Account>
* @param newMap of type Map<Id,Account>
* @param oldMap of type Map<Id,Account>
   */   
    
    public AccountTriggerHandler(List<Account> newRecords, List<Account>
                                 oldRecords, Map<Id, Account> newMap, Map<Id,Account> oldMap){
                                     this.newRecords = newRecords;
                                     this.oldRecords = oldRecords;
                                     this.newMap = newMap;
                                     this.oldMap = oldMap;
                                 }
    
    
    /**
    * @description handles before insert trigger event
    */
    public void handleBeforeInsert() {
        new SFO_UpdateAccountBUFromCSDDivCode(this.newRecords).setAccountBUFromCSDDivCode();
    }
    
    /**
   * @description handles before update trigger event
   */
    public void handleBeforeUpdate() {
        new SFO_UpdateAccountBUFromCSDDivCode(this.newRecords).setAccountBUFromCSDDivCode();
    }
    
    /**
    * @description handles beforeInsertUpdate trigger event
    */
    public void beforeInsertUpdate() {
        
        OLCM_AccountTriggerHandler.checkValidate(newRecords);   	  
    }
    /**
   * @description handles beforeInsertUpdate sfrecord Id trigger event
   */
    public void beforeInsertUpdatesf() {
        OLCM_AccountTriggerHandler.updateSalesforceID(newRecords);
    }
    
    /**
    * @description handles after update trigger event
    */
    public void handleAfterUpdate() {
        new CAJBP_AccountTriggerHandler(this.newRecords, this.oldMap).handleAfterUpdate();
    }  
}