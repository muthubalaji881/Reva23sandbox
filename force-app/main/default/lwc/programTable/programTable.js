import programTable from '@salesforce/apex/programTableController.programTable';
import { LightningElement,api,wire,track } from 'lwc';

export default class ProgramTable extends LightningElement {
    @api table;
    @track data;
    @track columns = [
        {label: 'School', fieldName: 'School_Name__c', type:'Text'},
        {label: 'Program Level', fieldName: 'Program_Type__c', type:'Text'},
        {label: 'Program', fieldName: 'Program_Name_Display__c', type:'Text'}

    ];

    @wire (programTable) 
    programTableRecords({error,data}){
        if(data){
            this.table = data;
        }
        else if (error){
            this.data = undefined;
        }
    }
}