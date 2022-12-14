<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CAJBP_Change_Direct_JBP_Record_type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CAJBP_Direct_Joint_Business_Plan</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Direct JBP Record type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAJBP_Change_Indirect_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CAJBP_Indirect_Joint_Business_Plan</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Indirect RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CAJBP-Change Direct JBP Record Type</fullName>
        <actions>
            <name>CAJBP_Change_Direct_JBP_Record_type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CAJBP_Joint_Business_Plan__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Direct JBP</value>
        </criteriaItems>
        <description>After create new JBP with record type Direct JBP, after save this record type will be changed to Direct Joint Business Plan</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CAJBP-Change Indirect JBP Record Type</fullName>
        <actions>
            <name>CAJBP_Change_Indirect_RT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CAJBP_Joint_Business_Plan__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Indirect JBP</value>
        </criteriaItems>
        <description>After create new JBP with record type Indirect JBP, after save this record type will be changed to Indirect Joint Business Plan</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
