<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Credit_Assessment_Notification_to_Requester</fullName>
        <description>Credit Assessment Notification to Requester</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/OLCM_Credit_Assessment_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>AITM_Set_Account_Owner_Role</fullName>
        <description>Set custom field to value of the current account owner&apos;s role</description>
        <field>AITM_Owner_Role__c</field>
        <formula>Owner.UserRole.Name</formula>
        <name>AITM Set Account Owner Role</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CA_UpdateBillingStreetAddress</fullName>
        <description>CA: SFO - Updates the Billing Street Address with a concatenation of custom fields  Billing_Address_Line_1__c and Billing_Address_Line_2__c</description>
        <field>BillingStreet</field>
        <formula>IF(
		AND(
			NOT(ISBLANK(Billing_Address_Line_1__c)),
			ISBLANK(Billing_Address_Line_2__c)
		),
	Billing_Address_Line_1__c,
	IF(
		AND(
			ISBLANK(Billing_Address_Line_1__c),
			NOT(ISBLANK(Billing_Address_Line_2__c))
		),
	Billing_Address_Line_2__c,
	IF(
		AND(
			NOT(ISBLANK(Billing_Address_Line_1__c)),
			NOT(ISBLANK(Billing_Address_Line_2__c))
		),
	Billing_Address_Line_1__c + &apos;, &apos; + Billing_Address_Line_2__c, &apos;&apos;
	)))</formula>
        <name>CA_UpdateBillingStreetAddress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Disable_Credit_Request_Send</fullName>
        <field>OLCM_Credit_Request_Send__c</field>
        <literalValue>0</literalValue>
        <name>Disable Credit Request Send</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Disable_Marked_For_Deletion</fullName>
        <field>Marked_for_Deletion__c</field>
        <literalValue>0</literalValue>
        <name>Disable Marked For Deletion</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Enable_Credit_Request_Send</fullName>
        <field>OLCM_Credit_Request_Send__c</field>
        <literalValue>1</literalValue>
        <name>Enable Credit Request Send</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Enable_Marked_For_Deletion</fullName>
        <field>Marked_for_Deletion__c</field>
        <literalValue>1</literalValue>
        <name>Enable Marked For Deletion</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_To_Customer_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Customer</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update To Customer Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>disable_Credit_Check</fullName>
        <field>OLCM_Credit_Request_Check__c</field>
        <literalValue>0</literalValue>
        <name>disable Credit Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>disable_Credit_Request_Check</fullName>
        <field>OLCM_Credit_Request_Check__c</field>
        <literalValue>0</literalValue>
        <name>disable Credit Request Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>CreditRequest</fullName>
        <apiVersion>43.0</apiVersion>
        <endpointUrl>https://sfdcutils.appspot.com/ombin?endpoint=http://inspectb.in/255ba0f</endpointUrl>
        <fields>BillingCity</fields>
        <fields>BillingCountry</fields>
        <fields>BillingPostalCode</fields>
        <fields>BillingStreet</fields>
        <fields>Customer_Since__c</fields>
        <fields>Id</fields>
        <fields>Name</fields>
        <fields>OLCM_BP_Annual_Margin_Forecast__c</fields>
        <fields>OLCM_Credit_Segment__c</fields>
        <fields>OLCM_Gross_Requested_Credit__c</fields>
        <fields>OLCM_Recoverable_MOT_Percent__c</fields>
        <fields>OLCM_Recoverable_VAT_Percentage__c</fields>
        <fields>OLCM_Unique_identifier__c</fields>
        <fields>Salesforce_ID1__c</fields>
        <fields>Tax_Number__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>satyam.naib@bp.com</integrationUser>
        <name>CreditRequest</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>SendCreditRequest</fullName>
        <apiVersion>43.0</apiVersion>
        <endpointUrl>http://reuxgbux439.bp.com.advanctco:50000/Account</endpointUrl>
        <fields>AITM_Alliance__c</fields>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>satyam.naib@bp.com</integrationUser>
        <name>SendCreditRequest</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Send_Credit_Request</fullName>
        <apiVersion>44.0</apiVersion>
        <endpointUrl>https://bp-ds-fscmrca-papi-v1-dev.ir-e1.cloudhub.io/api/creditAssesmentReq/0011j000004o9DQ</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>satyam.naib@bp.com</integrationUser>
        <name>Send Credit Request</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>sendcreditrequestV2</fullName>
        <apiVersion>43.0</apiVersion>
        <endpointUrl>https://putsreq.com/zjTDAl90Zun1oio4qjpp</endpointUrl>
        <fields>Id</fields>
        <fields>Type</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>satyam.naib@bp.com</integrationUser>
        <name>sendcreditrequest</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>AITM Account Owner Changes</fullName>
        <actions>
            <name>AITM_Set_Account_Owner_Role</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Stores the role of the account owner</description>
        <formula>AND(OR(ISCHANGED(OwnerId), IsNew()), OR(RecordType.Name = &apos;Accounting Details&apos;,RecordType.Name = &apos;AirBP Customer&apos;,RecordType.Name = &apos;Legal Entity&apos;,RecordType.Name = &apos;Billing Details&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CA_UpdateAccountBillingStreet</fullName>
        <actions>
            <name>CA_UpdateBillingStreetAddress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>CA: SFO - Concatenates &quot;hidden&quot; Billing_Address_Line_1__c and Billing_Address_Line_2__c fields to the Account Billing Street field - used in integration / migration of data from Siebel.</description>
        <formula>AND(  	OR(  		ISCHANGED( Billing_Address_Line_1__c ),  		ISCHANGED( Billing_Address_Line_2__c ),  		AND(  			ISNEW(),  			OR( 				NOT(ISBLANK(Billing_Address_Line_1__c)),  				NOT(ISBLANK(Billing_Address_Line_2__c))  			) 	 	)  	 ),  	OR(  		RecordType.DeveloperName = &apos;Customer&apos;,  		RecordType.DeveloperName = &apos;Prospect&apos; )  	)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OLCM Convert To Customer Record Type</fullName>
        <actions>
            <name>Update_To_Customer_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Account_ERP_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Converts Prospect to Customer if ERP ID is populated</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OLCM_Credit Assessment Notification to Requester</fullName>
        <actions>
            <name>Credit_Assessment_Notification_to_Requester</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Rule to send notification to Requestor once credit status description is updated</description>
        <formula>ISCHANGED( OLCM_Credit_Status_Description__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OLCM_CreditRequest</fullName>
        <actions>
            <name>disable_Credit_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.OLCM_Credit_Request_Check__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Rule to disable credit check,if credit request is send</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OLCM_Disable Marked for Deletion</fullName>
        <actions>
            <name>Disable_Credit_Request_Send</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Disable_Marked_For_Deletion</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rule to disable Marked for Deletion</description>
        <formula>AND( OLCM_Fuels_Card_Customers__c = True, Marked_for_Deletion__c = True,OR( ISCHANGED(OLCM_Total_Forecast_Sales__c), ISCHANGED(OLCM_Payment_Term_Number__c), ISCHANGED(OLCM_Invoice_Frequency_Number__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OLCM_Enable Marked for Deletion</fullName>
        <actions>
            <name>Enable_Marked_For_Deletion</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Rule to enable Marked for Deletion</description>
        <formula>AND( OLCM_Fuels_Card_Customers__c = True, Marked_for_Deletion__c = False, TODAY() - DATEVALUE( LastModifiedDate ) &gt;= 60)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OLCM_Send Credit Assessment</fullName>
        <actions>
            <name>Enable_Credit_Request_Send</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>disable_Credit_Request_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Send_Credit_Request</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR( 2 AND 3 AND 4)</booleanFilter>
        <criteriaItems>
            <field>Account.OLCM_Credit_Request_Check__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OLCM_Fuels_Card_Customers__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OLCM_Credit_Request_Send__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Marked_for_Deletion__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
