import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import JOOBLEJOB_ACTIVE_CHANNEL from '@salesforce/messageChannel/JoobleJobActive__c';

export default class JoobleJobCard extends LightningElement {
    subscription = null;
    jobDetails = {
        title: '',
        location: '',
        salary: '',
        company: '',
        source: '',
        type: ''
    };

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            JOOBLEJOB_ACTIVE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        this.jobDetails = message.jobDetails;
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }
}