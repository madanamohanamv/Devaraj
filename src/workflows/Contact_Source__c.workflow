<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CALCF_SetContactSourceCommentsToNULL</fullName>
        <description>CA:LCF - Sets Contact Source Review Comments to null</description>
        <field>Review_Comments__c</field>
        <name>CALCF_SetContactSourceCommentsToNULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CALCF_SetContactSourceReviewToFALSE</fullName>
        <description>CA:LCF - Sets the Contact Source Review Flag to False</description>
        <field>Review__c</field>
        <literalValue>0</literalValue>
        <name>CALCF_SetContactSourceReviewToFALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CALCF_RemoveContactSourceReviewFlag</fullName>
        <actions>
            <name>CALCF_SetContactSourceCommentsToNULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CALCF_SetContactSourceReviewToFALSE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>CA:LCF - Removes the review flag from a Contact Source when a Contact is populated</description>
        <formula>NOT(ISBLANK(Contact__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
