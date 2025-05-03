import { LightningElement, track } from 'lwc';
import getErrorLogs from '@salesforce/apex/TG_AdminController.getErrorLogs';

export default class TriggerGuardianErrorPanel extends LightningElement {
    @track errors = [];
    @track isLoading = false;
    @track errorMessage = '';

    get showNoErrors() {
        return !this.isLoading && this.errors.length === 0 && !this.errorMessage;
    }

    connectedCallback() {
        this.loadErrorLogs();
    }

    async loadErrorLogs() {
        this.isLoading = true;
        try {
            const data = await getErrorLogs();
            this.errors = JSON.parse(JSON.stringify(data));
            this.errorMessage = '';
        } catch (error) {
            this.errorMessage = 'Failed to load error logs.';
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }
}