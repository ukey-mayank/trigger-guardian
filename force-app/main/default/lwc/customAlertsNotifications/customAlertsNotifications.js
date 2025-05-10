import { LightningElement, track } from 'lwc';
import saveAlert from '@salesforce/apex/CustomAlertsNotificationsController.saveAlert';
import getAlerts from '@salesforce/apex/CustomAlertsNotificationsController.getAlerts';
import removeAlert from '@salesforce/apex/CustomAlertsNotificationsController.removeAlert';

export default class CustomAlertsNotifications extends LightningElement {
    @track errorPattern = '';
    @track threshold = 10;
    @track alerts = [];
    @track isLoading = false;

    connectedCallback() {
        this.loadAlerts();
    }

    handleErrorPatternChange(event) {
        this.errorPattern = event.target.value;
    }

    handleThresholdChange(event) {
        this.threshold = event.target.value;
    }

    handleSaveAlert() {
        this.isLoading = true;
        saveAlert({ pattern: this.errorPattern, threshold: this.threshold })
            .then(() => {
                this.loadAlerts();
                this.errorPattern = '';
                this.threshold = 10;
            })
            .catch((error) => {
                console.error('Error saving alert:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    loadAlerts() {
        getAlerts()
            .then((data) => {
                this.alerts = JSON.parse(data);
            })
            .catch((error) => {
                console.error('Error loading alerts:', error);
            });
    }

    handleRemoveAlert(event) {
        const alertId = event.target.dataset.id;
        removeAlert({ alertId: alertId })
            .then(() => {
                this.loadAlerts();
            })
            .catch((error) => {
                console.error('Error removing alert:', error);
            });
    }
}