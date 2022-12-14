<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CASFO_Email3MonthOpportunityExpiryReminder</fullName>
        <description>CASFO_Email3MonthOpportunityExpiryReminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Castrol_Sales/Contract_Expiry_Reminder_3_Months</template>
    </alerts>
    <alerts>
        <fullName>CASFO_Email6MonthOpportunityExpiryReminder</fullName>
        <description>CASFO_Email6MonthOpportunityExpiryReminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Castrol_Sales/Contract_Expiry_Reminder_6_Months</template>
    </alerts>
    <fieldUpdates>
        <fullName>CASFO_SetCommitToPlanningToTrue</fullName>
        <description>CA:SFO - set the Commit to Planning checkbox to true on the Opportunity</description>
        <field>Commit_to_Planning__c</field>
        <literalValue>1</literalValue>
        <name>CASFO_SetCommitToPlanningToTrue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CASFO_SetCommitToPlanningOnCloseWon</fullName>
        <actions>
            <name>CASFO_SetCommitToPlanningToTrue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>CA:SFO - Ensures that Commit to Planning is set when an Opportunity is set to Closed Won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
