/*
* This class provides a way to create test data that can be mocked or inserted.
* It can also enforce object and field level access, when creating objects.
*/
@IsTest
public class BPG_TestDataService {
    private static Integer IdCount = 0;
    private static Integer RecordCount = 0;
    private static final Map<Schema.SObjectType, Map<String, Schema.SObjectField>> ObjectFieldTokensMap = new Map<Schema.SObjectType, Map<String, Schema.SObjectField>>();


    public class SObjectCreator {
        private Boolean checkPermissions = false;

        public SObject createInstance(Schema.SObjectType sObjectType, Map<String, Object> fieldValueMap) {
            return createInstance(sObjectType, fieldValueMap, false, false);
        }

        public SObject createInstance(Schema.SObjectType sObjectType, Map<String, Object> fieldValueMap, Boolean id) {
            return createInstance(sObjectType, fieldValueMap, id, false);
        }

        /*
        * Creates a single sObject record.
        * [jsonIt] provides a way to create strict sObjects in memory that are otherwise hard to create.
        *
        * @param sObjectType the sObject type i.e. Account.sObjectType,BPG_Deployment__c.sObjectType.
        *
        * @param fieldValueMap a map that contains the field and value collection. You can also pass place holders
        *                       such as {#COUNT} to add uniqueness to field values i.e. 'Name' => 'Tesco LTD {#COUNT}'
        *
        * @param id generate a fake id for this sObject.
        * @param jsonIt used to create sObjects that cannot be inserted or fields being locked.
        */
        public SObject createInstance(Schema.SObjectType sObjectType, Map<String, Object> fieldValueMap, Boolean id, Boolean jsonIt) {
            ++RecordCount;

            SObject record;
            checkObjectPermission(sObjectType);
            record = sObjectType.newSObject();

            if (id) {
                fieldValueMap.put('Id', generateId(sObjectType));
            }

            if (jsonIt) {
                for (String field :fieldValueMap.keySet()) {
                    checkFieldPermission(record, field);
                    fieldValueMap.put(field, getFieldValue(fieldValueMap.get(field)));
                }

                Map<String, Object> attributes = new Map<String, Object>();
                attributes.put('type', String.valueOf(sObjectType));
                fieldValueMap.put('attributes', attributes);

                String jsonRecord = System.JSON.serialize(fieldValueMap);
                record = (SObject)System.JSON.deserialize(jsonRecord, SObject.class);
            } else {
                for (String field :fieldValueMap.keySet()) {
                    putField(record, field, fieldValueMap.get(field));
                }
            }

            return record;
        }

        //General way to create an entity definition for metadata types.
        public EntityDefinition createEntityDefinition(Schema.SObjectType sObjectType) {
            Schema.SObjectType currentSObjectType = EntityDefinition.getSObjectType();

            return (EntityDefinition)createInstance(currentSObjectType,
                new Map<String, Object>{
                    'QualifiedApiName' => String.valueOf(sObjectType)
                }, true, true
            );
        }

        private Object getFieldValue(Object value) {
            try {
                String result = String.valueOf(value);

                if (result.containsIgnoreCase('{#COUNT}')) {
                    result = result.replace('{#COUNT}', String.valueOf(RecordCount));
                    value = result;
                }
            } catch(System.Exception ex) {}

            return value;
        }

        public void putField(SObject record, String field, Object value) {
            checkFieldPermission(record, field);
            value = getFieldValue(value);
            record.put(field, value);
        }

        //This will enforce object and field permission checks will throw exception.
        public void enforcePermissions() {
            checkPermissions = true;
        }

        public void disablePermissions() {
            checkPermissions = false;
        }

        public Integer getRecordCount() {
            return RecordCount;
        }

        public void checkObjectPermission(Schema.SObjectType sObjectType) {
            if (checkPermissions) {
                Schema.DescribeSObjectResult objectDesc = sObjectType.getDescribe();

                if (!objectDesc.isAccessible() || !objectDesc.isCreateable()) {
                    throw new NoSObjectAccessException(objectDesc);
                }
            }
        }

        public void checkFieldPermission(SObject record, String field) {
            if (checkPermissions) {
                Schema.DescribeFieldResult fieldDesc = getFieldTokensMap(record.getSObjectType()).get(field).getDescribe();

                if (!fieldDesc.isAccessible() || !fieldDesc.isUpdateable()) {
                    throw new NoFieldAccessException(fieldDesc);
                }
            }
        }

        public Id generateId(Schema.sObjectType objectName) {
            String result = String.valueOf(IdCount++);
            return objectName.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
        }

        //Cached sObject fields token map.
        private Map<String, Schema.SObjectField> getFieldTokensMap(Schema.SObjectType sObjectType) {
            if (ObjectFieldTokensMap.containsKey(sObjectType)) {
                return ObjectFieldTokensMap.get(sObjectType);
            } else {
                Map<String, Schema.SObjectField> fieldTokensMap = sObjectType.getDescribe().fields.getMap();
                ObjectFieldTokensMap.put(sObjectType, fieldTokensMap);
                return fieldTokensMap;
            }
        }
    }

    /*
    * Provides a way for test classes to create test data models.
    */
    public abstract class DataModel implements IDataModel {
        protected Map<String, Object> models;

        public DataModel() {
            models = new Map<String, Object>();
            assign();
        }

        //Usually used for mock data, nothing committed to the database.
        public virtual void assign() {}

        //Use this when committing to the database i.e. using inserts.
        public virtual void execute() {}

        //Segments creating data for specific test scenarios or classes.
        public virtual void execute(IExecute executor) { executor.run(this); }

        public Object getModel(String model) {
            return models.get(model);
        }

        public Object putModel(String model, Object instance) {
            models.put(model, instance);
            return models.get(model);
        }
    }

    public interface IExecute {
        void run(DataModel model);
    }

    public interface IDataModel {
        void assign();
        void execute();
        void execute(IExecute executor);
        Object getModel(String model);
        Object putModel(String model, Object instance);
    }

    public class NoSObjectAccessException extends Exception {

        public NoSObjectAccessException(Schema.DescribeSObjectResult objectDesc) {
            setMessage('No Access for SObject: ' + objectDesc.getName()
                    + '\nIsAccessible: ' + objectDesc.isAccessible()
                    + '\nIsCreateable: ' + objectDesc.isCreateable());
        }
    }

    public class NoFieldAccessException extends Exception {

        public NoFieldAccessException(Schema.DescribeFieldResult fieldDesc) {
            setMessage('No Access for field: ' + fieldDesc.getName()
                    + '\nIsAccessible: ' + fieldDesc.isAccessible()
                    + '\nIsUpdateable: ' + fieldDesc.isUpdateable());
        }
    }

    public class CreateMethodNotImplementedException extends Exception {}
}