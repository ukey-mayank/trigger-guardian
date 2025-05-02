public without sharing class TG_TriggerGuardianDispatcher {
    public static void dispatch(String objectName, TriggerOperation operation) {
        // Fetch metadata
        Map<String, Trigger_Config__mdt> configs = new Map<String, Trigger_Config__mdt>(
            [SELECT Object_Name__c, Is_Enabled__c, Trigger_Order__c 
             FROM Trigger_Config__mdt 
             WHERE Object_Name__c = :objectName]
        );

        if (configs.isEmpty() || !configs.values()[0].Is_Enabled__c) {
            TG_TriggerGuardianLogger.logExecution(objectName, operation.name(), 'Skipped', 'Trigger disabled via metadata');
            return;
        }

        // Dynamically invoke handler
        TG_AbstractTriggerHandler handler = getHandlerInstance(objectName);
        if (handler == null) {
            TG_TriggerGuardianLogger.logExecution(objectName, operation.name(), 'Failed', 'Handler not found');
            return;
        }

        try {
            switch on operation {
                when BEFORE_INSERT  { handler.beforeInsert(Trigger.new); }
                when BEFORE_UPDATE  { handler.beforeUpdate(Trigger.new, Trigger.oldMap); }
                when BEFORE_DELETE  { handler.beforeDelete(Trigger.old); }
                when AFTER_INSERT   { handler.afterInsert(Trigger.new); }
                when AFTER_UPDATE   { handler.afterUpdate(Trigger.new, Trigger.oldMap); }
                when AFTER_DELETE   { handler.afterDelete(Trigger.old); }
                when AFTER_UNDELETE { handler.afterUndelete(Trigger.new); }
            }
            // TG_TriggerGuardianLogger.logExecution(objectName, operation.name(), 'Success', null);
        } catch (Exception e) {
            TG_TriggerGuardianLogger.logExecution(objectName, operation.name(), 'Failed', e.getMessage());
        }
    }

    private static TG_AbstractTriggerHandler getHandlerInstance(String objectName) {
        if (objectName == 'Account') {
            return new AccountTriggerHandler();
        } else if (objectName == 'Contact') {
            return new ContactTriggerHandler();
        }
        return null;
    }
}