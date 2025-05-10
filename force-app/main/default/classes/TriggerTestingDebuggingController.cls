public with sharing class TriggerTestingDebuggingController {
    @AuraEnabled(cacheable=false)
    public static String runTriggerTest(String objectName, Integer count) {
        List<Map<String, Object>> logs = new List<Map<String, Object>>();
        Datetime startTime = Datetime.now();
        String debugLogs = '';

        try {
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            if (!globalDescribe.containsKey(objectName)) {
                throw new AuraHandledException('Unsupported object: ' + objectName);
            }
            Schema.SObjectType sObjectType = globalDescribe.get(objectName);
            Schema.SObjectField nameField = sObjectType.getDescribe().fields.getMap().get('Name');
            if (nameField == null) {
                throw new AuraHandledException(objectName + ' does not have a Name field.');
            }

            List<SObject> records = new List<SObject>();
            for (Integer i = 0; i < count; i++) {
                SObject record = sObjectType.newSObject();
                record.put('Name', objectName + ' Test Record ' + i);
                records.add(record);
            }

            insert records;
            debugLogs = 'Trigger executed successfully for ' + objectName;

            logs.add(new Map<String, Object>{
                'id' => String.valueOf(Datetime.now().getTime()),
                'triggerName' => objectName + ' Trigger',
                'executionTime' => Datetime.now().getTime() - startTime.getTime(),
                'debugLogs' => debugLogs
            });

            return JSON.serialize(logs);
        } catch (Exception e) {
            System.debug('Error running trigger test: ' + e.getMessage());
            throw new AuraHandledException('Error running trigger test: ' + e.getMessage());
        }
    }
}