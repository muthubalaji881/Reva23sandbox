import { LightningElement, wire, api} from 'lwc';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent } 
          from 'lightning/flowSupport';
import getSchoolPrograms from '@salesforce/apex/RegistrationFormUtility.getSchoolPrograms';

export default class SchoolProgramPL extends LightningElement {
  data;
  error;
  @api selectedSchool = '';
  @api selectedProgram = '';
  schools = [];
  programs = [];
  schoolPrograms = new Map(); //Key = School Name, Value = Set() of Program Name (Display)s

  @wire(getSchoolPrograms) wiredSchoolPrograms({data, error}) {
    if (data) {
      //console.log(data);
      data.forEach(item => {
        if (!this.schoolPrograms.has(item.School_Name__c)) {
          this.schoolPrograms.set(item.School_Name__c, new Set());
        }
        this.schoolPrograms.get(item.School_Name__c).add(item.Program_Name_Display__c);
      });
      this.setSchoolOptions();
    }
    if (error) {
      console.log(error);
    }
  }

  connectedCallback() {
   
  }

  onNext() {
    
  }

  setSchoolOptions() {
    this.schools = [];
    this.schools.push({
        value: '',
        label: 'Select a School'
    });
    console.log(this.schoolPrograms.size);
    for (const [school, programs] of this.schoolPrograms) {
      this.schools.push({
        value: school,
        label: school
      });
    };        
  }

  setProgramOptions() {
    this.programs = [];
    this.programs.push({
        value: '',
        label: 'Select a Program'
    });
    // this.schoolPrograms.get(this.selectedSchool).forEach(program => {
    for (const program of this.schoolPrograms.get(this.selectedSchool)) {
      this.programs.push({
          value: program,
          label: program
      });
    };     
    //console.log(this.programs);   
  }

  onSchoolChange(event){
    this.selectedProgram = '';
    this.selectedSchool = event.target.value;
    this.setProgramOptions();
  }

  onProgramChange(event) {
      this.selectedProgram = event.target.value;
      console.log(this.selectedSchool, this.selectedProgram)
      // const nextNavigationEvent = new FlowNavigationNextEvent();       
      // this.dispatchEvent(nextNavigationEvent);
  }    
}