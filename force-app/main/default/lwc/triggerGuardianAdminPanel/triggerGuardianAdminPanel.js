import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TriggerGuardianAdminPanel extends LightningElement {
    @track currentTab = 'logs';

    // Track which tab is selected
    get isLogs() {
        return this.currentTab === 'logs';
    }

    get isSettings() {
        return this.currentTab === 'settings';
    }

    get isErrorPanel() {
        return this.currentTab === 'errors';
    }

    get isOrderManager() {
        return this.currentTab === 'order';
    }

    get isManualTest() {
        return this.currentTab === 'test';
    }

    // Handler to switch tabs
    handleTabChange(event) {
        this.currentTab = event.target.dataset.tab;
    }

    // Example of async data fetching using wire (can be used in child components for better performance)
    // @wire method would be used in the child components like <c-trigger-execution-log>, <c-trigger-settings-toggle>, etc.
    handleError(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.message,
                variant: 'error',
            }),
        );
    }
}