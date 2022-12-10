public class FEE_StudentFeeTriggerHandler 
{
    public static void updateFeePaymentCriteria(List<Student_Fee__c> lst_studntfee,Map<Id,Student_Fee__c> map_Oldstdntfee)
    {
        set<string> set_Feetype = new set<string>();
        List<Student_Fee__c> lst_flteredfee = new List<Student_Fee__c>();
        Map<string,Fee_Payment_Criteria__c> map_feepayment = new Map<string,Fee_Payment_Criteria__c>();
            
        for(Student_Fee__c objStudentfee : lst_studntfee)
        {
           if((map_Oldstdntfee == null && objStudentfee.Fee_Type__c != null)||(map_Oldstdntfee != null && 
                                 map_Oldstdntfee.get(objStudentfee.Id).Fee_Type__c != objStudentfee.Fee_Type__c && objStudentfee.Fee_Type__c != null)) 
           {
             set_Feetype.add(objStudentfee.Fee_Type__c);  
             lst_flteredfee.add(objStudentfee);
           }
        }
        
        if(!set_Feetype.IsEmpty())
        {
            for(Fee_Payment_Criteria__c objFeepayment : [select Id,Name,Fee_Type__c,Maximum_Number_of_Installments__c from Fee_Payment_Criteria__c where 
                                                         Fee_Type__c In :set_Feetype])
            {
                map_feepayment.put(objFeepayment.Fee_Type__c,objFeepayment);
            }
            for(Student_Fee__c objstdFee : lst_flteredfee)
            {
                if(map_feepayment.get(objstdFee.Fee_Type__c) != null)
                {
                  objstdFee.Fee_Payment_Criteria__c = map_feepayment.get(objstdFee.Fee_Type__c).Id;
                  objstdFee.Number_of_Installments__c = map_feepayment.get(objstdFee.Fee_Type__c).Maximum_Number_of_Installments__c;
                    
                }
                else
                {
                   objstdFee.Fee_Payment_Criteria__c = null; 
                   objstdFee.Number_of_Installments__c = 0;                    
                }
            }  
        }
    }
    
    public static void updateStudentFeeProgramEnrollment(List<Student_Fee__c> lst_studntfee,Map<Id,Student_Fee__c> map_Oldstdntfee)
    {
        set<Id> set_ContactIds = new set<Id>();
        Map<Id,hed__Program_Enrollment__c> map_ProgEnroll = new Map<Id,hed__Program_Enrollment__c>();
        List<Student_Fee__c> lst_filteredstdntfee = new List<Student_Fee__c>();
        
        for(Student_Fee__c objstudent : lst_studntfee)
        {
            if((map_Oldstdntfee == null && objstudent.Contact__c != null) || (map_Oldstdntfee != null &&
                                  map_Oldstdntfee.get(objstudent.Id).Contact__c != objstudent.Contact__c && objstudent.Contact__c != null))
            {
              set_ContactIds.add(objstudent.Contact__c); 
              lst_filteredstdntfee.add(objstudent);
            }
        }
        
        if(!set_ContactIds.IsEmpty())
        {
            for(hed__Program_Enrollment__c objProgEnroll : [select Id,Name,Active__c,hed__Contact__c from hed__Program_Enrollment__c where hed__Contact__c In: set_ContactIds
                                                           and Active__c = true])
            {
               map_ProgEnroll.put(objProgEnroll.hed__Contact__c,objProgEnroll); 
            }
            
            for(Student_Fee__c objstudent : lst_filteredstdntfee)
            {
              if(map_ProgEnroll.get(objstudent.Contact__c) != null)
              {
                objstudent.Program_Enrollment__c =  map_ProgEnroll.get(objstudent.Contact__c).Id; 
              }
              else
              {
                 objstudent.Program_Enrollment__c = null; 
              }
           }
        }
    }
    
    public static void displayOrderNoMapping(List<Student_Fee__c> lst_studntfee){
    
        for(Student_Fee__c stu : lst_studntfee){
            if(stu.Fee_Type__c == 'University Fee' && stu.Session__c == '1st Year'){
                stu.Display_No__c = 1;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Session__c == '1st Year'){
                stu.Display_No__c = 2;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Session__c == '2nd Year'){
                stu.Display_No__c = 3;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Session__c == '2nd Year'){
                stu.Display_No__c = 4;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Session__c == '3rd Year'){
                stu.Display_No__c = 5;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Session__c == '3rd Year'){
                stu.Display_No__c = 6;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Session__c == '4th Year'){
                stu.Display_No__c = 7;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Session__c == '4th Year'){
                stu.Display_No__c = 8;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Session__c == '5th Year'){
                stu.Display_No__c = 9;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Session__c == '5th Year'){
                stu.Display_No__c = 10;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Session__c == '6th Year'){
                stu.Display_No__c = 11;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Session__c == '6th Year'){
                stu.Display_No__c = 12;
            }
        }
    }
}