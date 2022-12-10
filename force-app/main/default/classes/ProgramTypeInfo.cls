public class ProgramTypeInfo {
     //@AuraEnabled
  //public static List<Account> getRelatedschools(String selectedProgramType){
   //system.debug([select name ,ParentId__c.Name, Program_Type__c from Account where Program_Type__c =:selectedProgramType ]);
   // return [select name ,ParentId__r.Name, Program_Type__c from Account where Program_Type__c =:selectedProgramType ];
   Set<Fee_Master__c>duplicateschool = new Set<Fee_Master__c>();
   @AuraEnabled
  public static List<Fee_Master__c> getRelatedschools(String selectedProgramType){
      system.debug([select Program_Name__c , Program_Type__c , School_Name__c from Fee_Master__c where Program_Type__c =:selectedProgramType ]);
      return [select Program_Name__c , Program_Type__c , School_Name__c from Fee_Master__c where Program_Type__c =:selectedProgramType ];
  }
    
}