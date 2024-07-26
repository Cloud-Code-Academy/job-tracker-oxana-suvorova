import { LightningElement, track } from 'lwc';
import getNewJobPositions from '@salesforce/apex/JoobleJobBoardController.getNewJobPositions'

export default class JoobleJobBoard extends LightningElement {
    keywords;
    location;

    searchResult = [];
    someResult;

    @track error;

    handleKeywordsChange(event) {
        this.keywords = event.target.value;
    }

    handleLocationChange(event) {
        this.location = event.target.value;
    }

    async handleSearchClick() {
        getNewJobPositions({ keywords: this.keywords, location: this.location })
        .then(data => {
            console.log('Status code:');
            console.log(data);
            this.someResult = 'true';
        })
        .catch(error => {
            this.error = error;
            crossOriginIsolated.log(' error ', this.error);
        })
    }
}