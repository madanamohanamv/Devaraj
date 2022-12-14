<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CAJBP_Change_JBP_Activity_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CAJBP_JBP_Activity_Completed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change JBP Activity RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAJBP_Set_RT_JBP_Activity_without_DJAF</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CAJBP_JBP_Activity_without_DJAF</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CAJBP- Set RT JBP Activity without DJAF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAJBP_Update_Record_Type</fullName>
        <description>Change RT for JBP Activity from JBP Activity RT to JBP Activity DJAF</description>
        <field>RecordTypeId</field>
        <lookupValue>CAJBP_JBP_Activity_DJAF</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CAJBP- Change JBP Activity RT</fullName>
        <actions>
            <name>CAJBP_Change_JBP_Activity_RT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CAJBP_JBP_Activity__c.CAJBP_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CAJBP- Change JBP Activity RT on DJAF RT</fullName>
        <actions>
            <name>CAJBP_Update_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CAJBP_JBP_Activity__c.CAJBP_Paid_for_by__c</field>
            <operation>equals</operation>
            <value>JAF</value>
        </criteriaItems>
        <description>When you select Paid for by equals JAF, record type will be change from JBP Activity RT to JBP Activity DJAF.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CAJBP- Change JBP Activity RT to JBP Activity without DJAF</fullName>
        <actions>
            <name>CAJBP_Set_RT_JBP_Activity_without_DJAF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>CAJBP_JBP_Activity__c.CAJBP_Paid_for_by__c</field>
            <operation>equals</operation>
            <value>Castrol</value>
        </criteriaItems>
        <criteriaItems>
            <field>CAJBP_JBP_Activity__c.CAJBP_Paid_for_by__c</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <description>If you select in Pay for by Castrol/Partner JBP Activity RT will be changed to JBP Activity without DJAF.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
