import { LightningElement, wire } from 'lwc';
import getProgramTypes from '@salesforce/apex/SchoolProgramInfo.getProgramTypes';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Program_Type__c from '@salesforce/schema/Account.Program_Type__c';
import getSchoolPrograms from '@salesforce/apex/SchoolProgramInfo.getSchoolPrograms';
export default class SchoolProgramInfo extends LightningElement {
  programTypes = [];
  programTypeOptions = [];
  selectedProgramType = 'UG';
  relatedSchools;
  allSchoolPrograms = [];
  displayData = [];
  allInfo = new Map();
  value;

  @wire(getPicklistValues, {
    recordTypeId: '0125j000000uuRhAAI',
    fieldApiName: Program_Type__c
  }) programTypeValues;

  handleProgramTypesChange(event) {
    this.selectedProgramType = event.target.value;
    getSchoolPrograms({ selectedProgramType: this.selectedProgramType })
      .then((result) => {
        console.log(result);
        this.relatedSchools = result;
      })
  }
  @wire(getSchoolPrograms) wiredSchoolPrograms({ error, data }) {
    if (data) {
      console.log(data);
      this.allSchoolPrograms = data;
      data.forEach(program => {
        if (!this.allInfo.has(program.Program_Type__c)) {
          this.allInfo.set(program.Program_Type__c, new Map());
        }
        let schoolPrograms = this.allInfo.get(program.Program_Type__c);
        if (!schoolPrograms.has(program.School_Name__c)) {
          schoolPrograms.set(program.School_Name__c, []);
        }
        let programs = schoolPrograms.get(program.School_Name__c);
        if (!programs.includes(program.Program_Name__c)) {
          programs.push(program.Program_Name__c);
        }
      });
      console.log(this.allInfo.get('PG').get('School of Civil Engineering'));
      console.log(this.allInfo.get('PG').get('School of Computer Science and Engineering'));
    }
    if (error) {
      console.error(error);
    }
  };

  get programsForSelectedType() {
    return this.allSchoolPrograms.filter(schoolProgram => {
      return (schoolProgram.programType === this.selectedProgramType);
    })
  }

  handleProgramTypeChange(event) {
    this.selectedProgramType = event.target.value;
    console.log(this.selectedProgramType);
  }
  get getSchoolForProgramTypes() {
    const displayData = [];
    if (this.allInfo.size > 0 && this.allInfo.get(this.selectedProgramType) ) {
      for (const [key, value] of this.allInfo.get(this.selectedProgramType)) {
        console.log(value);
        displayData.push({schoolInfo: `${key} - (${value.length}) `, programs: value})
        
      }
    }
    console.log(displayData);
    return displayData;
  }
  connectedCallback(){
    this.getSchoolForProgramTypes;
  }
}