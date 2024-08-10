import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNewJobPositions from '@salesforce/apex/JoobleJobBoardController.getNewJobPositions'
// Import message service features for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import JOOBLE_SEARCH_RESULT_CHANNEL from '@salesforce/messageChannel/JoobleSearchResult__c';

export default class JoobleJobBoard extends LightningElement {
    keywords = 'salesforce developer';
    location = 'Boston MA';
    datecreatedfrom;
    page = 1;

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

    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1;
            handleSearchClick();
        }
    }

    handleNext() {
        this.page = this.page + 1;
        handleSearchClick();
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
            const PARAMS = {
                keywords: this.keywords,
                location: this.location,
                datecreatedfrom: this.datecreatedfrom,
                page: this.page,
                resultonpage: '20'
            };
            getNewJobPositions({ paramsMap: PARAMS })
            .then(data => {
                const payload = { searchResult: data };
                publish(this.messageContext, JOOBLE_SEARCH_RESULT_CHANNEL, payload);
            })
            .catch(error => {
                this.error = error.body.message;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while requesting the Jooble Service',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
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