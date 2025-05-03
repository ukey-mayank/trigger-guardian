import { LightningElement, wire, track } from 'lwc';
import getLogs from '@salesforce/apex/TG_AdminController.getLogs';

export default class TriggerGuardianExecutionLog extends LightningElement {
    @track logs = [];
    @track searchTerm = '';
    @track isLoading = false;
    @track errorMessage = '';
    @track hasMoreData = true;
    @track nextPage = 0;
    
    // Debounce the search input
    searchTimeout;

    @wire(getLogs, { searchKey: '$searchTerm' })
    wiredLogs({ data, error }) {
        if (data) {
            this.logs = data;
            this.isLoading = false;
            this.errorMessage = '';
            this.hasMoreData = data.length === 100; // Assuming 100 records per page
        } else if (error) {
            this.isLoading = false;
            this.errorMessage = 'Error fetching logs: ' + error.body.message;
        }
    }

    handleSearch(event) {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            this.searchTerm = event.target.value;
            this.isLoading = true;
            this.nextPage = 0; // Reset to first page
            this.logs = []; // Clear existing logs
        }, 500); // Debounce time of 500ms
    }

    loadMoreLogs() {
        if (!this.hasMoreData) return;

        this.isLoading = true;
        this.nextPage++;

        // Call Apex method to fetch the next set of logs
        getLogs({ searchKey: this.searchTerm, pageNumber: this.nextPage })
            .then((data) => {
                if (data && data.length) {
                    this.logs = [...this.logs, ...data];
                } else {
                    this.hasMoreData = false; // No more data available
                }
                this.isLoading = false;
            })
            .catch((error) => {
                this.isLoading = false;
                this.errorMessage = 'Error loading more logs: ' + error.body.message;
            });
    }

    // Getter for conditionally rendering "No logs found" message
    get noLogsFound() {
        return this.logs.length === 0 && !this.isLoading;
    }
}