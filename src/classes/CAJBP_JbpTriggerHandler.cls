/**
 * @author 			Jan Majling
 * @date 			25/07/2018
 * @group			CAJBP
 * @description     handles triggers of JBP object
 * 
 * history
 * 25/07/2018	Jan Majling			Created 
 * 25/08/2018	Jana Cechova		Added check to allow only one JBP In Progress or Draft
 * 18/09/2018	Jan Majling			Refactored handleBeforeUpsert, added docs
 * 03/10/2018	Jan Majling			Set records in constructor
 */
public with sharing class CAJBP_JbpTriggerHandler {
	private static final String STATE_IN_PROGRESS = 'In Progress';
	private static final String STATE_DRAFT = 'Draft';

	private final List<CAJBP_Joint_Business_Plan__c> newRecords;
	private final List<CAJBP_Joint_Business_Plan__c> oldRecords;
	private final Map<Id,CAJBP_Joint_Business_Plan__c> newMap;
	private final Map<Id,CAJBP_Joint_Business_Plan__c> oldMap;

	/**
	 * @description constructor
	 * @param newRecords of type List<CAJBP_Joint_Business_Plan__c>
	 * @param oldRecords of type List<CAJBP_Joint_Business_Plan__c>
	 * @param newMap of type Map<Id,CAJBP_Joint_Business_Plan__c>
	 * @param oldMap of type Map<Id,CAJBP_Joint_Business_Plan__c>
	 */
	public CAJBP_JbpTriggerHandler(List<CAJBP_Joint_Business_Plan__c> newRecords, List<CAJBP_Joint_Business_Plan__c> oldRecords, Map<Id,CAJBP_Joint_Business_Plan__c> newMap, Map<Id,CAJBP_Joint_Business_Plan__c> oldMap) {
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.newMap = newMap;
		this.oldMap = oldMap;
	}

	/**
	 * @description handles before insert and update trigger events
	 */
	public void handleBeforeUpsert() {
		this.setJbpName(this.newRecords);
		this.allowOnlyOneJbpInDraftOrProgress(this.newRecords);
	}
	/**
	 * @description handles after insert trigger event
	 */
	public void handleAfterInsert() {
		new CAJBP_JbpHelper().createScorecardRecord(this.newRecords);
	}
	/**
	 * @description allows only 1 JBP in progress or draft for the same year
	 * @param newRecords of type List<CAJBP_Joint_Business_Plan__c>
	 */
	private void allowOnlyOneJbpInDraftOrProgress(List<CAJBP_Joint_Business_Plan__c> newRecords) {
		Set<Id> accountIds = new Set<Id>();
		Set<String> setYears = new set<String>();
		Set<Id> alreadyProcessed = new Set<Id>();

		for (CAJBP_Joint_Business_Plan__c jbp : newRecords) {
			 if(!alreadyProcessed.contains(jbp.id)){
				alreadyProcessed.add(jbp.Id);
				setYears.add(jbp.CAJBP_Year__c);
				accountIds.add(jbp.CAJBP_Account__c);
			}
		}

		List<AggregateResult> ar = [SELECT CAJBP_Account__c accID, count(Id) jbps
									   FROM CAJBP_Joint_Business_Plan__c
									   WHERE CAJBP_Account__c IN:accountIds
									   AND(CAJBP_State__c =: STATE_IN_PROGRESS
									   OR CAJBP_State__c =: STATE_DRAFT)
									   AND CAJBP_Year__c IN: setYears
									   AND ID NOT IN: alreadyProcessed
									  Group by CAJBP_Account__c
									 ];                    
		for (CAJBP_Joint_Business_Plan__c jbp : newRecords) {
			for(AggregateResult res: ar){
				system.debug(logginglevel.error, 'res' + res);
				if(res.get('accID') != null){
					if(jbp.CAJBP_Account__c == res.get('accID')){
						if(integer.valueOF(res.get('jbps')) >=1 && (jbp.CAJBP_State__c == STATE_IN_PROGRESS || jbp.CAJBP_State__c == STATE_DRAFT)){
								jbp.addError(Label.CAJBP_OnlyOneJbpInProgressOrDraftAllowed);  
							}
					}
				}
			}
		}
	}
	/**
	 * @description sets name for JBPs
	 * @param newRecords of type List<CAJBP_Joint_Business_Plan__c>
	 */
	private void setJbpName(List<CAJBP_Joint_Business_Plan__c> newRecords) {
		Set<Id> accountIds = new Set<Id>();
		Map<Id,Account> accounts;

		for (CAJBP_Joint_Business_Plan__c jbp : newRecords) {
			accountIds.add(jbp.CAJBP_Account__c);
		}
		accounts = new Map<Id,Account>(
			[SELECT Name, Type FROM Account WHERE Id IN :accountIds]
		);

		for (CAJBP_Joint_Business_Plan__c jbp : newRecords) {
			if(jbp.CAJBP_Account__c != null) {
				jbp.CAJBP_Joint_Business_Plan_Name__c = CAJBP_JbpHelper.createName(
					jbp,
					accounts.get(jbp.CAJBP_Account__c)
				);
			}
		}
	}
}