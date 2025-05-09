public with sharing class TG_AdminController {

    @AuraEnabled
    public static void deleteLogRecord(Id recordId) {
        // Validate CRUD permissions for the user
        if (!Schema.sObjectType.Trigger_Execution_Log__c.isAccessible() || !Schema.sObjectType.Trigger_Execution_Log__c.isDeletable()) {
            throwException('You do not have permission to access or delete Trigger Execution Log records.');
        }

        Trigger_Execution_Log__c log = [
            SELECT Id FROM Trigger_Execution_Log__c WHERE Id = :recordId LIMIT 1
        ];
        delete log;
    }

    @AuraEnabled(cacheable=true)
    public static List<Trigger_Config_Runtime__c> getTriggerSettings(Integer pageSize, Integer pageNumber) {
        try{
            return [
                SELECT Id, Object_Name__c, Is_Enabled__c, Trigger_Order__c
                FROM Trigger_Config_Runtime__c
                ORDER BY Trigger_Order__c
                LIMIT :pageSize OFFSET :((pageNumber - 1) * pageSize)
            ];
        }
        catch (Exception ex) {
            System.debug('Error in getTriggerSettings: ' + ex.getMessage());
            throw new AuraHandledException('Failed to fetch trigger settings.');
        }
    }

    @AuraEnabled
    public static void updateTriggerStatus(Id recordId, Boolean isEnabled) {
        try {
            Trigger_Config_Runtime__c setting = [
                SELECT Id, Is_Enabled__c
                FROM Trigger_Config_Runtime__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            setting.Is_Enabled__c = isEnabled;
            update setting;
        } catch (Exception ex) {
            System.debug('Error in updateTriggerStatus: ' + ex.getMessage());
            throw new AuraHandledException('Failed to update trigger status.');
        }
    }

    @AuraEnabled
    public static void updateTriggerOrder(List<Trigger_Config_Runtime__c> updatedOrders) {
        try {
            if (updatedOrders.isEmpty()) return;
            update updatedOrders;
        } catch (Exception ex) {
            System.debug('Error in updateTriggerOrder: ' + ex.getMessage());
            throw new AuraHandledException('Failed to update trigger orders.');
        }
    }

    @AuraEnabled
    public static void syncToMetadata() {
        // Asynchronous execution for large data sets
        try {
            TG_ConfigSyncService.syncToMetadata();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR + e.getMessage());
            throwException('Failed to sync to metadata.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLogsWithErrorFilter(
        String searchTerm,
        String startDate,
        String endDate,
        String statusFilter,
        Integer pageSize,
        Integer pageNumber
    ) {
        List<Trigger_Execution_Log__c> logs = new List<Trigger_Execution_Log__c>();
        Integer offset = (pageNumber - 1) * pageSize;

        Date startDateObj;
        Date endDateObj;

        if (String.isNotBlank(startDate)) {
            try {
                startDateObj = Date.valueOf(startDate);
            } catch (Exception e) {
                throw new AuraHandledException('Invalid start date format.');
            }
        }

        if (String.isNotBlank(endDate)) {
            try {
                endDateObj = Date.valueOf(endDate);
            } catch (Exception e) {
                throw new AuraHandledException('Invalid end date format.');
            }
        }

        Datetime startDt = (startDateObj != null) ? Datetime.newInstance(startDateObj, Time.newInstance(0, 0, 0, 0)) : null;
        Datetime endDt = (endDateObj != null) ? Datetime.newInstance(endDateObj.addDays(1), Time.newInstance(0, 0, 0, 0)) : null;

        // Build base query
        String baseQuery = 'SELECT Id, Object_Name__c, Error_Message__c, Execution_Status__c, CreatedDate FROM Trigger_Execution_Log__c WHERE Name != null';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(searchTerm)) {
            String escapedSearch = String.escapeSingleQuotes(searchTerm);
            conditions.add('(Object_Name__c LIKE \'%' + escapedSearch + '%\' OR Error_Message__c LIKE \'%' + escapedSearch + '%\')');
        }

        if (startDt != null) {
            conditions.add('CreatedDate >= ' + formatForSOQL(startDt));
        }

        if (endDt != null) {
            conditions.add('CreatedDate <= ' + formatForSOQL(endDt));
        }

        if (String.isNotBlank(statusFilter)) {
            String escapedStatus = String.escapeSingleQuotes(statusFilter);
            conditions.add('Execution_Status__c = \'' + escapedStatus + '\'');
        }

        if (!conditions.isEmpty()) {
            baseQuery += ' AND ' + String.join(conditions, ' AND ');
        }

        String fullQuery = baseQuery + ' ORDER BY CreatedDate DESC LIMIT ' + pageSize + ' OFFSET ' + offset;
        logs = Database.query(fullQuery);

        String countQuery = 'SELECT COUNT() FROM Trigger_Execution_Log__c WHERE Name != null';
        if (!conditions.isEmpty()) {
            countQuery += ' AND ' + String.join(conditions, ' AND ');
        }

        Integer totalRecords = Database.countQuery(countQuery);

        return new Map<String, Object>{
            'logs' => logs,
            'totalRecords' => totalRecords
        };
    }

    private static String formatForSOQL(Datetime dt) {
        return '\'' + dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + '\'';
    }

    public class LogFilter {
        @AuraEnabled public String searchKey;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public String executionStatus;
    }

    @AuraEnabled(cacheable=true)
    public static List<Trigger_Execution_Log__c> getErrorLogs(
        Integer pageSize, 
        Integer pageNumber, 
        Date startDate, 
        Date endDate, 
        String executionStatus) {

        Integer offset = (pageNumber - 1) * pageSize;

        // Validate CRUD permissions for the user
        if (!Schema.sObjectType.Trigger_Execution_Log__c.isAccessible()) {
            throwException('You do not have permission to access Trigger Execution Logs.');
        }

        // Build dynamic query to include date range and execution status filtering
        String query = 'SELECT Id, Object_Name__c, Error_Message__c, CreatedDate FROM Trigger_Execution_Log__c WHERE 1 = 1';
        
        if (String.isNotEmpty(executionStatus)) {
            query += ' AND Execution_Status__c = :executionStatus';
        }
        
        if (startDate != null) {
            query += ' AND CreatedDate >= :startDate';
        }

        if (endDate != null) {
            query += ' AND CreatedDate <= :endDate';
        }

        query += ' ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :offset';
        
        List<Trigger_Execution_Log__c> logs = Database.query(query);

        if (logs.isEmpty()) {
            return new List<Trigger_Execution_Log__c>(); // Avoid null return
        }
        
        return logs;
    }

    @AuraEnabled
    public static String runManualTest(String objectName) {
        try {
            // Simulated logic to run test
            return 'Manual trigger test executed for ' + objectName;
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    // to handle exceptions
    private static void throwException(String msg) {
        throw new AuraHandledException(msg);
    }
}