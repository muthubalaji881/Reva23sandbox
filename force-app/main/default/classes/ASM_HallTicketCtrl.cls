public without sharing class ASM_HallTicketCtrl {
    
    @AuraEnabled
    public static wrapperClass GetStudentDetails()
    {
        decimal Eligibility_Percent = decimal.Valueof(System.Label.ASM_AttendancePercentage);
        wrapperClass objWrapper = new wrapperClass();        
        user usr =[select id,Name,ContactId from User where Id =: userinfo.getUserId()]; //
        objWrapper.EnableHallTicket = false;
        List<StudentFee> lst_StuFee = new List<StudentFee>();
        List<SurveyWrp> lstSurvWrp = new List<SurveyWrp>();
        
        List<hed__Program_Enrollment__c> lst_ProgramEnroll = [select Id,Pending_Survey__c,SRN_Number__c,hed__Contact__c,Issue_Hall_Ticket__c
                                                              from hed__Program_Enrollment__c where hed__Contact__c =: usr.ContactId and Active__c =: true];
        
        if(lst_ProgramEnroll.size() > 0) 
        {            
            if(lst_ProgramEnroll[0].SRN_Number__c != null)  objWrapper.SRNNumber = lst_ProgramEnroll[0].SRN_Number__c;
            if(lst_ProgramEnroll[0].Pending_Survey__c > 0 && lst_ProgramEnroll[0].Pending_Survey__c != null) 
            { 
                objWrapper.SurveyPending = 'Pending';               
            }
            else 
            {
                objWrapper.SurveyPending = 'No Pending';
            }
            
            if(lst_ProgramEnroll[0].Issue_Hall_Ticket__c == true)
            {
                objWrapper.EnableHallTicket = true;
            }
        }
        
        
        if(objWrapper.SurveyPending == 'Pending')
        {
            for(SurveyInvitation objSurv : [select Id,SurveyId,Survey.Name from SurveyInvitation  where ResponseStatus != 'Completed' 
                                            and ParticipantId =: usr.ContactId])
            {
                SurveyWrp objSurvWrp = new SurveyWrp();
                objSurvWrp.SurveyName = objSurv.Survey.Name;
                lstSurvWrp.add(objSurvWrp);
            }
        }
        
        
        List<AttendanceWrapper> lst_Att = new List<AttendanceWrapper>();
        for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,Course_Offering_Section_ID__r.Name,
                                                   hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c
                                                   where hed__Program_Enrollment__c =: lst_ProgramEnroll[0].Id  and Classes_Attended__c <: Eligibility_Percent])
            
        {
            AttendanceWrapper objAtt = new AttendanceWrapper();
            objAtt.CourseName = objCourse.Course_Offering_Section_ID__r.Name;             
            if(objCourse.Total_Classes_Completed__c != null) objAtt.Total_Classes = objCourse.Total_Classes_Completed__c; else objAtt.Total_Classes = 0;
            if(objCourse.Total_Classes_Completed__c != null) objAtt.Attended_Classes = objCourse.Total_Classes_Attended__c; else objAtt.Attended_Classes = 0;
            if(objCourse.Classes_Attended__c != null) objAtt.TotalPercentAttend = objCourse.Classes_Attended__c; else objAtt.TotalPercentAttend = 0;
            
            lst_Att.add(objAtt);
        }
        
        
        try
        {
            for(Student_Fee__c objFee : [select Id,Name,Amount_Pending__c,Due_Date__c from Student_Fee__c where Contact__c =: usr.ContactId
                                         and Due_Date__c <=: system.today() and Amount_Pending__c > 0])
            {
                StudentFee objStuFee = new StudentFee();
                objStuFee.FeeName = objFee.Name;
                objStuFee.PendingAmount = objFee.Amount_Pending__c;
                objStuFee.DueDate = objFee.Due_Date__c;
                lst_StuFee.add(objStuFee);
            }
        }
        catch(exception ex)
        {
            system.debug('====>>>>'+ex.getStackTraceString());
        }
        objWrapper.lstSurveyPending = lstSurvWrp;
        objWrapper.AttendanceWrapper = lst_Att;
        objWrapper.StudentFee = lst_StuFee;
        
        if(objWrapper.EnableHallTicket == false)
        {            
            if(objWrapper.SurveyPending == 'Pending' || lst_Att.size() > 0 || lst_StuFee.size() > 0) 
            {                  
                objWrapper.EnableHallTicket = false;
            }
            else objWrapper.EnableHallTicket = true;
        }
        return objWrapper;
    }
    @AuraEnabled
    public static errorWrap DowloadHallTicket(string StudentSRN)
    {
        errorWrap objError = new errorWrap();
        //  StudentSRN = 'R17AR057';
        JsonSRN objJson = new JsonSRN();
        objJson.regno = StudentSRN;
        String jsonBody = Json.serialize(objJson);
        
        
        //Map Http Request
        HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_HallTicketCtrl',jsonBody);
        
        //Send Request
        Http http = new Http();
        HttpResponse hRsp = http.send(hReq);                
        string hallTicketURL;
        if(hRsp.getStatusCode() == 200)
        {                        
            responseWrap objWrap = (responseWrap) Json.deserialize(hRsp.getBody(), responseWrap.class);             
            if(objWrap.data.url != null && objWrap.status != 'Failure')
            {
                objError.url = objWrap.data.url;
                return objError;                
            }    
            else
            {
                objError.error = 'error';
                objError.message = objWrap.data.msg;
                return objError;
            }
        }
        else
        {
            objError.error = 'error';
            objError.message = 'Please try after some time';
            return objError;
            
        }
    }
    
    public class JsonSRN
    {
        public string regno;
    }
    
    public class wrapperClass
    {
        @AuraEnabled public List<AttendanceWrapper> AttendanceWrapper {get;set;}
        @AuraEnabled public string SurveyPending {get;set;}
        @AuraEnabled public string SRNNumber {get;set;}
        @AuraEnabled public boolean EnableHallTicket {get;set;}
        @AuraEnabled public List<StudentFee> StudentFee {get;set;}
        @AuraEnabled public List<SurveyWrp> lstSurveyPending {get;set;}
        
    }
    public class AttendanceWrapper
    {        
        @AuraEnabled  public string CourseName {get;set;}
        @AuraEnabled  public string Eligibility {get;set;}
        @AuraEnabled  public decimal Total_Classes {get;set;}
        @AuraEnabled  public decimal Attended_Classes {get;set;}
        @AuraEnabled  public decimal TotalPercentAttend {get;set;}
    }    
    public class StudentFee
    {
        @AuraEnabled  public string FeeName {get;set;}
        @AuraEnabled  public decimal PendingAmount {get;set;}
        @AuraEnabled  public Date DueDate {get;set;}
    }
    
    public class responseWrap 
    {
        @AuraEnabled  public Integer error_code {get;set;}
        @AuraEnabled  public String status {get;set;}
        @AuraEnabled  public Data data {get;set;}
    }    
    public class Data 
    {
        @AuraEnabled  public String regno {get;set;}
        @AuraEnabled  public String url {get;set;}
        @AuraEnabled  public String msg {get;set;}
    }
    public class SurveyWrp
    {
        @AuraEnabled public string SurveyName {get;set;}
    }
    public class errorWrap
    {
        @AuraEnabled  public String error {get;set;}
        @AuraEnabled  public String message {get;set;}
        @AuraEnabled  public String url {get;set;}
    }
}