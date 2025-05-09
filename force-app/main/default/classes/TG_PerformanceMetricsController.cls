public with sharing class TG_PerformanceMetricsController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPerformanceMetrics() {
        try {
            List<Map<String, Object>> metricsData = new List<Map<String, Object>>();
            
            // Average Execution Time
            Map<String, Object> avgExecutionTime = new Map<String, Object>();
            avgExecutionTime.put('metric', 'Average Execution Time');
            avgExecutionTime.put('value', 150); // Placeholder, replace with actual calculation
            metricsData.add(avgExecutionTime);
            
            // High-Latency Triggers
            Map<String, Object> highLatency = new Map<String, Object>();
            highLatency.put('metric', 'High-Latency Triggers');
            highLatency.put('value', 300); // Placeholder, replace with actual calculation
            metricsData.add(highLatency);
            
            return metricsData;
        } catch (Exception e) {
            System.debug('Error fetching performance metrics: ' + e.getMessage());
            throw new AuraHandledException('Error fetching performance metrics');
        }
    }
}