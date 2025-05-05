import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TriggerGuardianAdminPanel extends LightningElement {
    @track activeTabValue = 'logs'; // Default selected tab

    // Handle tab change event from lightning-tabset
    handleTabChange(event) {
        this.activeTabValue = event.target.value;
    }

    // Error handler (can be used inside child components via events)
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