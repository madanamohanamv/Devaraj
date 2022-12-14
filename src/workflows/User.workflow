<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>REIDP_Consent_to_General_Marketing_Time</fullName>
        <field>REIDP_General_Marketing_TimeStamp__c</field>
        <formula>NOW()</formula>
        <name>REIDP Consent to General Marketing Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>REIDP_Consent_to_Personal_Marketing_Time</fullName>
        <field>REIDP_Personal_Marketing_TimeStamp__c</field>
        <formula>now()</formula>
        <name>REIDP Consent to Personal Marketing Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>REIDP_Drive_Carbon_Neutral_Time</fullName>
        <field>REIDP_Drive_Carbon_Neutral_Timestamp__c</field>
        <formula>NOW()</formula>
        <name>REIDP Drive Carbon Neutral Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>REIDP_T_C_Accepted_Time</fullName>
        <field>REIDP_T_C_Accepted__c</field>
        <formula>NOW()</formula>
        <name>RE IDP T&amp;C Accepted Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>REIDP Consent to General Marketing</fullName>
        <actions>
            <name>REIDP_Consent_to_General_Marketing_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( REIDP_General_Marketing_Info__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>REIDP Consent to Personal Marketing</fullName>
        <actions>
            <name>REIDP_Consent_to_Personal_Marketing_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( REIDP_Personal_Marketing_Info__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>REIDP Drive Carbon Neutral</fullName>
        <actions>
            <name>REIDP_Drive_Carbon_Neutral_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( REIDP_Drive_Carbon_Neutral__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>REIDP Drive Carbon Neutral Timestamp</fullName>
        <actions>
            <name>REIDP_Drive_Carbon_Neutral_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( REIDP_Drive_Carbon_Neutral_Timestamp__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>REIDP T%26C Accepted Timestamp</fullName>
        <actions>
            <name>REIDP_T_C_Accepted_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( REIDP_T_C_Accepted__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
