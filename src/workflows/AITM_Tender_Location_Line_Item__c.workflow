<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AITM_Account_Manager_Notes_Instructions</fullName>
        <field>AITM_Account_Manager_Notes_Instructions__c</field>
        <name>AITM Account Manager Notes/Instructions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AITM_Location_Manager_Level_of_Interest</fullName>
        <field>AITM_Location_Manager_Level_of_Interest__c</field>
        <name>AITM Location Manager Level of Interest</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AITM_Location_Manager_Reg_Info</fullName>
        <field>AITM_LM_Context_Strategic_Rationale_Info__c</field>
        <name>AITM_Location Manager Reg &amp; Info</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AITM_Update_Tender_Location_Line_Item</fullName>
        <field>Name</field>
        <formula>AITM_Line_Item_Name_Account__c</formula>
        <name>AITM Update Tender Location Line Item</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>current_round</fullName>
        <field>AITM_Current_Value__c</field>
        <name>current round</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AITM Account%2FLocation Manager Instructions</fullName>
        <actions>
            <name>AITM_Account_Manager_Notes_Instructions</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AITM_Location_Manager_Level_of_Interest</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AITM_Location_Manager_Reg_Info</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>After changing the round from Tender to TLLI, Account/Location Manager fields should get emply</description>
        <formula>!(ISBLANK(AITM_Current_Round__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AITM_Update_Tender_Location_Line_Item_Name</fullName>
        <actions>
            <name>AITM_Update_Tender_Location_Line_Item</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>As per user story AR-1624 the tender location line item should be updated</description>
        <formula>NOT(ISBLANK(AITM_Location__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
