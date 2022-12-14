<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>REIDP_Set_Unique_Id</fullName>
        <description>Sets Unique Id as in the example: UserId_ApplicationId_ConsentType</description>
        <field>Unique_ID__c</field>
        <formula>User__c + &quot;_&quot; +  Application__c + &quot;_&quot; + TEXT(Type__c)</formula>
        <name>REIDP Set Unique Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>REIDP Set Unique Id</fullName>
        <actions>
            <name>REIDP_Set_Unique_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(Unique_ID__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
