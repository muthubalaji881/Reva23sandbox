public without sharing class SchoolProgramInfo {
  private static final String FEE_TYPE_APPLICATION = 'Application Fee';
  @AuraEnabled(cacheable=true) 
  public static List<String> getProgramTypes() {
    List<String> picklistValuesList = new List<String>();
    List<Schema.PicklistEntry> picklistValues = Account.Program_Type__c.getDescribe().getPicklistValues();

    for (Schema.PicklistEntry pickListVal : picklistValues){
      picklistValuesList.add(picklistVal.getValue());
    }

    return (picklistValuesList);
  }

  @AuraEnabled(cacheable=true)
  public static List<Fee_Master__c> getSchoolPrograms() {
    String enrolmentYear = [select Text_Value__c 
                              from General_Setting__mdt
                              where DeveloperName = 'Enrolment_Year'
                              limit 1].Text_Value__c;

    List<Fee_Master__c> enrollmentYearPrograms =[select School_Name__c, Program_Name__c, Program_Name_Display__c, Program_Type__c
                                                  from Fee_Master__c
                                                  where Enrolment_Year__c = '2023'
                                                  and Fee_Type__c = 'Application Fee' 
                                                  order by School_Name__c,Program_Type__c, Program_Name__c];
           return enrollmentYearPrograms;
  }
}