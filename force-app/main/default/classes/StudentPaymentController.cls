global class StudentPaymentController {

  public Student_Payment__c studentPayment {get;set;}
  public String paymentId {get; set;}
  public String transactionId {get; set;}
  public String paymentGateway {get; set;}
  
  //public Datetime TransactionDateTime{get;set;}
 // public string ISTTransactionDateTime{get;set;}
 // public Date studentPaymentDate
  

  global void processPayment() {
      
    paymentId = ApexPages.CurrentPage().getparameters().get('id');
    transactionId = ApexPages.CurrentPage().getparameters().get('transactionId');
    paymentGateway = ApexPages.CurrentPage().getparameters().get('paymentGateway');
   //	paymentDate = ApexPages.CurrentPage().getparameters().get('paymentDate');
  
    this.studentPayment = [Select Id,Transaction_ID__c, Payment_Gateway__c,Payment_Date_Time__c,Payment_Mode_Type__c,Amount__c, Payment_Date__c, Contact__r.Application_Number__c,contact__r.Name,contact__r.FirstName,contact__r.Email,
                            Contact__r.Program_Name__c,Contact__r.School_Name__c, Application_Number__c from Student_Payment__c 
                            Where Id =:paymentId]; 
      //ISTTransactionDateTime = ApexPages.CurrentPage().getparameters().get('ISTTransactionDateTime');
     
      //ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');
      // studentPaymentDate = system.today();

   //this.studentPayment.Payment_Date_Time__c = paymentDate;
   
    this.studentPayment.Transaction_ID__c = transactionId;
    this.studentPayment.Payment_Gateway__c = paymentGateway;
    this.studentPayment.Payment_Mode_Type__c = 'Online'; 
   
    system.debug('....'+this.studentPayment);
    }
}