<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CALCF_High_Score_Alert</fullName>
        <description>CALCF High Score Alert</description>
        <protected>false</protected>
        <recipients>
            <field>CALCF_Operations_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>castrolcustomerfeedb@bp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Live_Customer_Feedback_Templates/High_Survey_Score_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>CALCF_Fire_Email_To_False</fullName>
        <field>CALCF_Fire_Email__c</field>
        <literalValue>0</literalValue>
        <name>CALCF Fire Email To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CALCF Fire Email</fullName>
        <actions>
            <name>CALCF_High_Score_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CALCF_Fire_Email_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CALCF_High_Scoring_Digest__c.CALCF_Fire_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
