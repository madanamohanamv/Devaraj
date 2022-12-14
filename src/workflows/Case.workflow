<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CA_SetSubjectAsTypeValue</fullName>
        <description>Copy the value from the Type field into the Subject field</description>
        <field>Subject</field>
        <formula>TEXT( Type )</formula>
        <name>CA_SetSubjectAsTypeValue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subject_to_Type_Value</fullName>
        <description>CA:SFO,LCF - Copy the value from the Type field into the Subject field</description>
        <field>Subject</field>
        <formula>TEXT( Type )</formula>
        <name>CA_SetSubjectAsTypeValue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CA_PopulateSubjectOnCase</fullName>
        <actions>
            <name>CA_SetSubjectAsTypeValue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Subject_to_Type_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>CA:SFO, LCF - Populate the Subject on the Case record. This is required when the type is not blank and the subject does not have a value</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
