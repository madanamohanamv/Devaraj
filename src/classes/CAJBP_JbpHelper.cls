/**
 * @author 			Jan Majling
 * @date 			25/07/2018
 * @group			CAJBP
 * @description     helper class for JBP object
 * 
 * history
 * 25/07/2018	Jan Majling			Created
 */
public with sharing class CAJBP_JbpHelper {
	private static final Map<String,String> TYPES_BY_CODE = new Map<String,String>{
		'ZMHI' => Label.CAJBP_CustomerGroup,
		'ZMSP' => Label.CAJBP_SoldToParty
	};
    /**
     * @description creates name for JBP
     * @param jbp of type CAJBP_Joint_Business_Plan__c
     * @param account of type Account
     * @return String
     */
    public static String createName(CAJBP_Joint_Business_Plan__c jbp, Account account) {
        return String.format(
            '{0} {1} JBP {2}',
            new String[]{
                account.Name,
                TYPES_BY_CODE.get(account.Type),
                jbp.CAJBP_Year__c != null ? jbp.CAJBP_Year__c : ''
            }
        );
    }
    
     /**
     * @description creates Scorecard record for JBP
     * @param jbp of type CAJBP_Joint_Business_Plan__c
     * @return 
     */
     public void createScorecardRecord(List<CAJBP_Joint_Business_Plan__c> lstNewJBPs) {
     
        list<CAJBP_Scorecard__c> lstScorecardToInsert = new list<CAJBP_Scorecard__c>();
        set<Id> setJBPid = new set<Id>();
        
        // Get the list of relevant JBPs
        for (CAJBP_Joint_Business_Plan__c objJBP: lstNewJBPs){
            setJBPid.add(objJBP.id);
        }
        
        list<CAJBP_Joint_Business_Plan__c > lstJBPs = new list<CAJBP_Joint_Business_Plan__c >([SELECT Id, CAJBP_Account__r.Name, CAJBP_Year__c
        	FROM CAJBP_Joint_Business_Plan__c
        	WHERE Id IN:setJBPid]
        );
        for(CAJBP_Joint_Business_Plan__c objJBP : lstJBPs){
            
            lstScorecardToInsert.add(new CAJBP_Scorecard__c(
                Name =  objJBP.CAJBP_Account__r.Name +' Scorecard ' + objJBP.CAJBP_Year__c,
                CAJBP_Joint_Business_Plan__c = objJBP.Id
            
            ));
        }
       
        if(!lstScorecardToInsert.isEmpty()){
            
            try{
                insert lstScorecardToInsert;
            
            }catch (DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                
            } 
        
        }
    
    }
    
    
}