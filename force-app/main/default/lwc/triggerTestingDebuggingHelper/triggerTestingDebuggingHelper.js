import { LightningElement, track } from 'lwc';
import runTriggerTest from '@salesforce/apex/TriggerTestingDebuggingController.runTriggerTest';

export default class TriggerTestingDebuggingHelper extends LightningElement {
    @track objectName = 'Account';
    @track recordCount = 10;
    @track executionLogs = [];
    @track isLoading = false;

    handleObjectNameChange(event) {
        this.objectName = event.target.value;
    }

    handleRecordCountChange(event) {
        this.recordCount = event.target.value;
    }

    handleTriggerTest() {
        this.isLoading = true;
        runTriggerTest({ objectName: this.objectName, count: this.recordCount })
            .then((logs) => {
                this.executionLogs = JSON.parse(logs);
            })
            .catch((error) => {
                console.error('Error running trigger test:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}