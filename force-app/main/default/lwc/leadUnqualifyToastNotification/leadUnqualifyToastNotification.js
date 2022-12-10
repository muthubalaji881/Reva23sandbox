import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from "lightning/flowSupport";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class LeadUnqualifyToastNotification extends NavigationMixin(LightningElement) {
    hasRendered = false;
 
    @api recordId;
    @api objectApiName;
    @api title;
    @api variant;
    @api message;
    @api urlLabel;
    @api triggerNavigationNextEvent;

    @api
    availableActions = [];

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            this.showToastMessage();
        }
    }

    async showToastMessage() {
 
        const url = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view',
            },
        })
    
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Some unexpected error',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    
    if (this.triggerNavigationNextEvent) {
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        } else if (this.availableActions.find(action => action === 'FINISH')) {
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
    }
}
}