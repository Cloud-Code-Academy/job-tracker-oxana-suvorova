import { LightningElement, track, wire, api } from 'lwc';
import getNewJobPositions from '@salesforce/apex/JoobleJobBoardController.getNewJobPositions'
// Import message service features for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import JOOBLE_SEARCH_RESULT_CHANNEL from '@salesforce/messageChannel/JoobleSearchResult__c';

export default class JoobleJobBoard extends LightningElement {
    keywords = 'salesforce developer';
    location = 'Boston MA';
    datecreatedfrom;

    @wire(MessageContext)
    messageContext;

    @track error;

    handleKeywordsChange(event) {
        this.keywords = event.target.value;
    }

    handleLocationChange(event) {
        this.location = event.target.value;
    }

    handleDateChange(event) {
        this.datecreatedfrom = event.target.value;
    }

    async handleSearchClick() {
        // Check if required field were filled out
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            this.error = undefined;
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        // If all valid, request new positions
        if (allValid) {
            getNewJobPositions({ keywords: this.keywords, location: this.location, dateFrom: this.datecreatedfrom })
            .then(data => {
                const payload = { searchResult: data };
                publish(this.messageContext, JOOBLE_SEARCH_RESULT_CHANNEL, payload);
            })
            .catch(error => {
                this.error = error;
                crossOriginIsolated.log(' error ', this.error);
            })
        } else {
            this.error = 'Please fill all required fields out';
        }
    }

    handleSaveSelectedJobsClick() {
        this.dispatchEvent(
            new CustomEvent('saveselected', {
                detail: { saveselected: true }
            })
        );
    }
}