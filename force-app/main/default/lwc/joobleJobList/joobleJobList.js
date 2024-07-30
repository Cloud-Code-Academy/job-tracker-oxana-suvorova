import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveNewJobPositions from '@salesforce/apex/JoobleJobBoardController.saveNewJobPositions';

// Import message service features for subscribing
import { subscribe, MessageContext } from 'lightning/messageService';
import JOOBLE_SEARCH_RESULT_CHANNEL from '@salesforce/messageChannel/JoobleSearchResult__c';

const COLS = [
    { label: 'Title', fieldName: 'title' },
    { label: 'Location', fieldName: 'location' },
    { label: 'Salary', fieldName: 'salary' },
    { label: 'Type', fieldName: 'type' },
    { label: 'Company', fieldName: 'company' },
    { label: 'Updated', fieldName: 'updated', type: 'date' },
    { label: 'Source', fieldName: 'source' },
    { label: 'Link', fieldName: 'link', type: 'url' }
];

export default class JoobleJobList extends LightningElement {
    @track _saveselected = false;

    columns = COLS;
    subscription = null;
    searchResult;

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            JOOBLE_SEARCH_RESULT_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    // Handler for message received by component
    handleMessage(message) {
        this.searchResult = message.searchResult;
    }

    // Subscribe to message channel from the start
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    @api
    set saveselected(value) {
        this._saveselected = value;
        if (this._saveselected) {
            this.pushSelectedData();
        }
    }

    get saveselected() {
        return this._saveselected;
    }

    async pushSelectedData() {
        const element = this.template.querySelector('lightning-datatable');
        const selectedRows = element.getSelectedRows();

        if (selectedRows.length > 0) {
            try {
                // Pass selected rows to the saveNewJobPositions Apex contriller
                await saveNewJobPositions({ selectedJobs: selectedRows });
    
                // Report success with a toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Job Application records were created',
                        variant: 'success'
                    })
                );
            } catch (error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while inserting selected records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            }
            this._saveselected = false;
        }
    }
}