import { LightningElement, track } from 'lwc';
import runBulkOperation from '@salesforce/apex/BulkDataOperationController.runBulkOperation';

export default class BulkDataOperationHelper extends LightningElement {
    @track recordCount = 100;
    @track operation = 'insert';
    @track executionLogs = [];
    @track isLoading = false;

    operationOptions = [
        { label: 'Insert', value: 'insert' },
        { label: 'Update', value: 'update' },
        { label: 'Delete', value: 'delete' }
    ];

    handleRecordCountChange(event) {
        this.recordCount = event.target.value;
    }

    handleOperationChange(event) {
        this.operation = event.target.value;
    }

    handleBulkOperation() {
        this.isLoading = true;
        runBulkOperation({ count: this.recordCount, operation: this.operation })
            .then((logs) => {
                this.executionLogs = JSON.parse(logs);
            })
            .catch((error) => {
                console.error('Error performing bulk operation:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}