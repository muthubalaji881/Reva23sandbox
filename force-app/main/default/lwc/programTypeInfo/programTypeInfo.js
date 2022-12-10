import { LightningElement,wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Program_Type__c from '@salesforce/schema/Account.Program_Type__c';
 //import  Name from '@salesforce/schema/Account.Name';
 import getRelatedschools from '@salesforce/apex/ProgramTypeInfo.getRelatedschools';
//import getProfiles from '@salesforce/apex/PicklistHelper.getProfiles';
export default class PickListExample extends LightningElement {
    //selectedValue;
    activeSectionMessage = 'UG';
    selectedProgramType = 'UG';
    selectedName;
    relatedSchools;

    
    
    /*retrieve picklist values from Account Program Type Field */
    @wire(getPicklistValues, {
        recordTypeId: '0125j000000uuRhAAI',
        fieldApiName: Program_Type__c
    }) programTypeValues;
  
    /*hadle selected type for Account Type Field*/
    handleProgramTypesChange(event){
        this.selectedProgramType  = event.target.value;
        getRelatedschools({selectedProgramType:this.selectedProgramType})
        .then((result) => {
            console.log(result);
            this.relatedSchools = result;
        })
    }

    /*hadle selected type for Account Type Field*/
    handleselectedNameChange(event){
        this.selectedName  = event.target.value;
    }



}