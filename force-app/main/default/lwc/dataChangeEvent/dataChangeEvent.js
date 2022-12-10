import { LightningElement } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class DataChangeEvent extends LightningElement {

 channelName = '/data/LeadChangeEvent';
  subscription;


  connectedCallback() {
    this.handleSubscribe();
  }

  //Called when change is deteced
  //1. Check if the change that happened is relevant, i.e. should we remove rows from datatable
  //2. If yes, filter out those records
  //3. If the impacted records includes a selected record - deselect the record
  //   > removing a selected row throwing error even if programmatically deselecting
  //   > hence selecting the first available record id in the refreshed list. 
  handleNotification(response) {
    if (response.data.payload.Email_OTP_Verified__c && response.data.payload.Email_OTP_Verified__c == true) {
      const recordIds = response.data.payload.ChangeEventHeader.recordIds;

      const refreshCallList = this.callList.filter(item => {
        return !recordIds.includes(item.recordId);
      })

      //Check if one of the impacted records is selected
      if (recordIds.includes(this.selectedRecord)) {
        if (refreshCallList.length > 0) {
          this.selectedRows = [refreshCallList[0]];
        } else {
          this.selectedRows = [];
        }
        
        console.log('Selected row does not meet criteria any more'); //could also send a Toast message
      }
      
      console.log(refreshCallList);
      this.callList = refreshCallList;
    }
  }

  handleSubscribe() {
    // Callback invoked whenever a new event message is received
    const messageCallback = (response) => {
      console.log('New message received: ', JSON.stringify(response));
      // Response contains the payload of the new message received
      this.handleNotification(response);
    };

    // Invoke subscribe method of empApi. Pass reference to messageCallback
    subscribe(this.channelName, -1, messageCallback).then(response => {
        // Response contains the subscription information on subscribe call
        console.log('Subscription request sent to: ', JSON.stringify(response.channel));
        this.subscription = response;
        //this.handleNotification(response);
    });
  }
}