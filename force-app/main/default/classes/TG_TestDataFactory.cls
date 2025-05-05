public with sharing class TG_TestDataFactory {
    public static void insertDummyLogs(Integer count) {
        List<Trigger_Execution_Log__c> logs = new List<Trigger_Execution_Log__c>();

        for (Integer i = 0; i < count; i++) {
            logs.add(new Trigger_Execution_Log__c(
                Object_Name__c = 'Account',
                Trigger_Name__c = 'AccountTrigger',
                Execution_Status__c = 'Success',
                Timestamp__c = System.now(),
                Error_Message__c = '',
                Event_Type__c = 'before insert'
            ));
        }

        insert logs;
    }
}