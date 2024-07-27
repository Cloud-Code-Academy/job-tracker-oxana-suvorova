import { LightningElement, wire } from 'lwc';

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
    { label: 'Link', fieldName: 'link', type: 'url' }
];

export default class JoobleJobList extends LightningElement {
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

    getSelectedData() {
        // const selectedRows = event.detail.selectedRows;
        // for (let i = 0; i < selectedRows.length; i++) {
        //     alert('You selected: ' + selected.Rows[i].Title);
        // }
    }
}