public with sharing class BulkDataOperationController {
    @AuraEnabled(cacheable=false)
    public static String runBulkOperation(Integer count, String operation) {
        List<Map<String, Object>> logs = new List<Map<String, Object>>();
        Datetime startTime = Datetime.now();
        String limitsInfo = '';

        try {
            List<Account> accounts = new List<Account>();
            for (Integer i = 0; i < count; i++) {
                accounts.add(new Account(Name = 'Test Account ' + i));
            }

            if (operation == 'insert') {
                insert accounts;
            } else if (operation == 'update') {
                for (Account acc : accounts) {
                    acc.Name += ' (Updated)';
                }
                update accounts;
            } else if (operation == 'delete') {
                delete accounts;
            }

            limitsInfo = 'DML Rows: ' + Limits.getDmlRows() + ' / ' + Limits.getLimitDmlRows() + ', ' +
                          'CPU Time: ' + Limits.getCpuTime() + ' / ' + Limits.getLimitCpuTime() + ' ms';

            logs.add(new Map<String, Object>{
                'id' => String.valueOf(Datetime.now().getTime()),
                'operation' => operation,
                'executionTime' => Datetime.now().getTime() - startTime.getTime(),
                'limits' => limitsInfo
            });

            return JSON.serialize(logs);
        } catch (Exception e) {
            System.debug('Error performing bulk operation: ' + e.getMessage());
            throw new AuraHandledException('Error performing bulk operation: ' + e.getMessage());
        }
    }
}