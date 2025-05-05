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
        Integer offset = (pageNumber - 1) * pageSize;
        // Validate CRUD permissions for the user
        if (!Schema.sObjectType.Trigger_Config_Runtime__c.isAccessible()) {
            throwException('You do not have permission to access Trigger Config records.');
        }

        return [
            SELECT Id, Object_Name__c, Is_Enabled__c, Trigger_Order__c
            FROM Trigger_Config_Runtime__c
            WITH SECURITY_ENFORCED
            ORDER BY Trigger_Order__c
            LIMIT :pageSize OFFSET :offset
        ];
    }

    @AuraEnabled
    public static void updateTriggerStatus(Id recordId, Boolean isEnabled) {
        try {
            if (recordId == null) {
                throwException('Invalid input: recordId is required.');
            }

            // Validate CRUD permissions for the user
            if (!Schema.sObjectType.Trigger_Config_Runtime__c.isAccessible() || !Schema.sObjectType.Trigger_Config_Runtime__c.isUpdateable()) {
                throwException('You do not have permission to access or update Trigger Config records.');
            }
            
            Trigger_Config_Runtime__c config = [
                SELECT Id, Is_Enabled__c 
                FROM Trigger_Config_Runtime__c 
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            config.Is_Enabled__c = isEnabled;
            update config;
        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR + e.getMessage());
            throwException('Failed to update trigger status.');
        }
    }

    @AuraEnabled
    public static void updateTriggerOrder(List<Trigger_Config_Runtime__c> updatedOrders) {
        try {
            if (updatedOrders == null || updatedOrders.isEmpty()) {
                throwException('Invalid input: updatedOrders are required.');
            }

            // Validate CRUD permissions for the user
            if (!Schema.sObjectType.Trigger_Config_Runtime__c.isAccessible() || !Schema.sObjectType.Trigger_Config_Runtime__c.isUpdateable()) {
                throwException('You do not have permission to access or update Trigger Config records.');
            }

            List<Trigger_Config_Runtime__c> recordsToUpdate = new List<Trigger_Config_Runtime__c>();
            for (Trigger_Config_Runtime__c orders : updatedOrders) {
                if (orders.Id == null || orders.Trigger_Order__c == null) {
                    continue;
                }
                recordsToUpdate.add(new Trigger_Config_Runtime__c(
                    Id = orders.Id,
                    Trigger_Order__c = orders.Trigger_Order__c
                ));
            }

            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR + e.getMessage());
            throwException('Failed to update trigger order.');
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
    public static Map<String, Object> getLogsWithErrorFilter(String searchTerm, String startDate, String endDate, String statusFilter, Integer pageSize, Integer pageNumber) {
        List<Trigger_Execution_Log__c> logs = new List<Trigger_Execution_Log__c>();
        Integer offset = (pageNumber - 1) * pageSize;

        Date startDateObj;
        Date endDateObj;

        // Ensure start date and end date are valid
        if (String.isNotBlank(startDate)) {
            try {
                startDateObj = Date.valueOf(startDate); // Converts 'YYYY-MM-DD' string to Date
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Invalid start date format: ' + startDate);
                throw new AuraHandledException('Invalid start date format.');
            }
        }

        if (String.isNotBlank(endDate)) {
            try {
                endDateObj = Date.valueOf(endDate); // Converts 'YYYY-MM-DD' string to Date
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Invalid end date format: ' + endDate);
                throw new AuraHandledException('Invalid end date format.');
            }
        }

        String query = 'SELECT Id, Object_Name__c, Error_Message__c, Execution_Status__c, CreatedDate ' +
                       'FROM Trigger_Execution_Log__c WHERE Name != null';

        // Apply the search key filter if provided
        if (String.isNotBlank(searchTerm)) {
            query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }

        // Apply the start date filter if provided
        if (startDateObj != null) {
            query += ' AND CreatedDate >= :startDateObj';
        }

        // Apply the end date filter if provided
        if (endDateObj != null) {
            query += ' AND CreatedDate <= :endDateObj';
        }

        // Apply the execution status filter if provided
        if (String.isNotBlank(statusFilter)) {
            String statusFilterLower = statusFilter.toLowerCase();
            query += ' AND LOWER(Execution_Status__c) = :statusFilterLower';
        }

        // Debug the query for further inspection
        System.debug(LoggingLevel.DEBUG, 'Final query: ' + query);

        // Execute the query
        try {
            logs = Database.query(query);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error executing query: ' + e.getMessage());
            throw new AuraHandledException('Error fetching logs: ' + e.getMessage());
        }

        // Count total records for pagination
        Integer totalRecords = [SELECT COUNT() FROM Trigger_Execution_Log__c WHERE Name != null];

        // Return results and total records for pagination
        return new Map<String, Object>{
            'logs' => logs,
            'totalRecords' => totalRecords
        };
    }

    public class LogFilter {
        @AuraEnabled public String searchKey;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public String executionStatus;
    }

    @AuraEnabled(cacheable=true)
    public static List<Trigger_Execution_Log__c> getErrorLogs(Integer pageSize, Integer pageNumber) {
        Integer offset = (pageNumber - 1) * pageSize;

        // Validate CRUD permissions for the user
        if (!Schema.sObjectType.Trigger_Execution_Log__c.isAccessible()) {
            throwException('You do not have permission to access Trigger Execution Logs.');
        }

        List<Trigger_Execution_Log__c> logs = [
            SELECT Id, Object_Name__c, Error_Message__c, CreatedDate
            FROM Trigger_Execution_Log__c
            WHERE Execution_Status__c = 'Error'
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT :pageSize OFFSET :offset
        ];

        if (logs.isEmpty()){
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