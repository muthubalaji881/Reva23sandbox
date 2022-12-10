import { LightningElement, wire } from 'lwc';
import ApplicationPortalBannerPC from'@salesforce/resourceUrl/ApplicationPortalBannerPC';
import ApplicationPortalBannerMobile from'@salesforce/resourceUrl/ApplicationPortalBannerMobile';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import  getSiteUrl  from '@salesforce/apex/RegistrationFormUtility.getSiteURL';

const UTM_SOURCE_DIRECT = 'Direct';
const UTM_SOURCE_ORGANIC = 'Organic';
const PAYMENT_PAGE_LINKEXT = '/s/payment-page?contactId=';




export default class TestLwc extends NavigationMixin(LightningElement) {
    backgroundImagePC = ApplicationPortalBannerPC;
    backgroundImageMobile = ApplicationPortalBannerMobile;
    referrer;
    utmSource;
    contactId;
    loader = false;
    error;

    @wire(CurrentPageReference)
    getStateParameters(currPage) {
      if (document.referrer !== undefined) {
        this.referrer = document.referrer
      } else {
        this.referrer = '';
      }
  
      if (currPage) {
        if (currPage.state.c__utm_source !== undefined) {
          this.utmSource = currPage.state.c__utm_source;
          console.log('inside utmsource not undefined '+this.utmSource);
        } else {
          console.log('inside else not undefined '+this.utmSource);
          this.setDefaultSource();
        }
      } else {
        this.setDefaultSource();
      }
    }

    @wire(getSiteUrl) wired_getSiteUrl({data, error}){
      if(data){
        this.siteUrl = data;
        this.error = undefined;
      }else if(error){
        this.siteUrl = undefined;
        this.error = error;
      }
    };
  
    setDefaultSource() {
      if (this.referrer === '') {
        this.utmSource = UTM_SOURCE_DIRECT;
      } else {
        this.utmSource = UTM_SOURCE_ORGANIC;
        console.log('Should be organice by now'+this.utmSource);
      }
    }
  
    get showRegistrationFlow() {
      return this.referrer !== undefined && this.utmSource !== undefined;
    }
  
    get flowInputVariables() {
      console.log('referrer '+this.referrer);
      console.log('utm source '+this.utmSource);
      return [
        {
            name: 'varReferrer',
            type: 'String',
            value: this.referrer
            
        },
        {
            name: 'varUtmSource',
            type: 'String',
            value: this.utmSource
        }
      ];
    }
  
    handleStatusChange(event) {
      if (event.detail.status === 'FINISHED') {
        this.loader = true;
        var outputVariables = event.detail.outputVariables;
      console.log(outputVariables);
        
        var outputVar;
        for(var i = 0; i < outputVariables.length; i++) {
           outputVar = outputVariables[i];
           // Pass the values to the component's attributes
           i
           if(outputVar.name === "contactId" && outputVar.value != null) {
                      console.log(outputVar.value);
                      this.contactId=outputVar.value;
                      
                    
                  
        } else if (outputVar.name === "Id" && outputVar.value != null){
          console.log(outputVar.value);
                      this.contactId=outputVar.value;
  
        }
      }
     
   
  
        console.log('Status is FINISHED');
          const navConfig ={
        
          type: 'standard__webPage',
      attributes: {
        
          url: this.siteUrl+ PAYMENT_PAGE_LINKEXT +this.contactId
      }
        }
          this[NavigationMixin.Navigate](navConfig);
      }
    }
}