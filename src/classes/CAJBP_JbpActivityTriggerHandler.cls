/**
 * @author			Jana Cechova
 * @date			10/09/2018
 * @group			CAJBP
 * @description		handle triggers on CAJBP_JbpActivityTrigger
 *
 * history
 * 10/09/2018		Jan Cechova			Created
 * 03/10/2018		Jan Majling			Updated to set records in constructor
 */
public with sharing class CAJBP_JbpActivityTriggerHandler {
	private final List<CAJBP_JBP_Activity__c> newRecords;
	private final List<CAJBP_JBP_Activity__c> oldRecords;
	private final Map<Id,CAJBP_JBP_Activity__c> newMap;
	private final Map<Id,CAJBP_JBP_Activity__c> oldMap;

	/**
	 * @description constructor
	 * @param newRecords of type List<CAJBP_JBP_Activity__c>
	 * @param oldRecords of type List<CAJBP_JBP_Activity__c>
	 * @param newMap of type Map<Id,CAJBP_JBP_Activity__c>
	 * @param oldMap of type Map<Id,CAJBP_JBP_Activity__c>
	 */
	public CAJBP_JbpActivityTriggerHandler(List<CAJBP_JBP_Activity__c> newRecords, List<CAJBP_JBP_Activity__c> oldRecords, Map<Id,CAJBP_JBP_Activity__c> newMap, Map<Id,CAJBP_JBP_Activity__c> oldMap) {
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.newMap = newMap;
		this.oldMap = oldMap;
	}
	/**
	 * @description handles JBP activites on before insert
	 */
    public void handleBeforeInsert() {
        String errorMsg = '';
        set<ID> setJBPids= new set<ID>();
        set<ID> setObjectiveIDs = new set<ID>();
        list<CAJBP_Objective__c> lstObjectives = new list<CAJBP_Objective__c>();
        list<CAJBP_Distributor_Joint_Activity_Fund__c> lstDJAFs = new list<CAJBP_Distributor_Joint_Activity_Fund__c>();
        
        for(CAJBP_JBP_Activity__c objJBP : this.newRecords){
           
            setObjectiveIDs.add(objJBP.CAJBP_Objective__c);
        
        }
        
       lstObjectives = [SELECT ID, CAJBP_Joint_Business_Plan__c 
                        FROM CAJBP_Objective__c
                        WHERE Id IN:setObjectiveIDs
                       ];
       
         
        if(!lstObjectives.isEmpty()){
            for(CAJBP_Objective__c objObjective : lstObjectives){
                setJBPids.add(objObjective.CAJBP_Joint_Business_Plan__c );
            }
            
            
            lstDJAFs = [SELECT Id, CAJBP_Joint_Business_Plan__c
                        FROM CAJBP_Distributor_Joint_Activity_Fund__c
                        WHERE CAJBP_Joint_Business_Plan__c IN: setJBPids
                       ];
            
            for(CAJBP_JBP_Activity__c  obJBPActivity : this.newRecords){
                if(lstDJAFs.isEmpty() && obJBPActivity.CAJBP_Paid_for_by__c== 'JAF'){
                
                    errorMsg='Distributor Joint Activity Fund does not exist.';
                    obJBPActivity.addError(errorMsg); 
                        
                }else if(lstDJAFs.size()==1 && obJBPActivity.CAJBP_Paid_for_by__c== 'JAF' && obJBPActivity.CAJBP_Distributor_Joint_Activity_Fund__c == null){
                            
                    obJBPActivity.CAJBP_Distributor_Joint_Activity_Fund__c = lstDJAFs[0].id;
                         
                }
                                     
            }
                        
        }  
        
    }

}