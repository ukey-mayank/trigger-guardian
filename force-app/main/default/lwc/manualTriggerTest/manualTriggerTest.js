import { LightningElement, track } from 'lwc';
import runManualTest from '@salesforce/apex/TG_AdminController.runManualTest';

export default class ManualTriggerTest extends LightningElement {
    @track selectedObject = '';
    @track result = '';
    @track isLoading = false;

    // Getter for the disabled attribute
    get isButtonDisabled() {
        return this.isLoading || !this.selectedObject;
    }

    handleObjectChange(event) {
        this.selectedObject = event.target.value;
    }

    handleRunTest() {
        this.isLoading = true;
        runManualTest({ objectName: this.selectedObject })
            .then(response => {
                this.result = response;
                this.isLoading = false;
            })
            .catch(error => {
                this.result = error.body.message;
                this.isLoading = false;
            });
    }
}