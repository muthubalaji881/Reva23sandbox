global class Fee_DueDateEmailAlert_Batch implements Database.Batchable<sObject> 
{
    global database.QueryLocator start(Database.BatchableContext bc)
    {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        date todayDt = system.today();
        integer yr = Integer.Valueof( system.Label.Due_Date_Email_Alert_Year_Filter);
        return DataBase.getQueryLocator([Select id,Name,Active__c,ReportsToid,Email,Program_Batch__r.hed__Start_Date__c,hed__WorkEmail__c,
                                         (select id,Name,Due_Date__c,Fee_Type__c,Amount_Paid__c,Amount__c,Amount_Pending__c,Contact__r.RecordTypeId
                                          FROM Student_Fees__r where Due_Date__c !=null And Due_Date__c <=: todayDt And Amount_Pending__c >:0 )
                                         FROM Contact where Student_Status__c =: 'Pursuing' and  RecordTypeId=:ContactRecTypeId and 
                                         Program_Batch__r.hed__Start_Date__c != null and 
                                         CALENDAR_YEAR(Program_Batch__r.hed__Start_Date__c) !=: yr]);
    }
    global void execute(Database.BatchableContext Bc,List<Contact> lstCon)
    {           
        for(Contact con : lstCon)
        {            
            if(con.Student_Fees__r.size() > 0)
            {
                Id ConParentTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
                string strDateOfconf; 
                set<id> set_Reportid = new set<id>();
                list<string> lst_CCEmail = new list<string>();
                list<string> lst_ToEmail = new list<string>();
                List<Messaging.SingleEmailMessage> lst_Email = new List<Messaging.SingleEmailMessage>();
                string TextBody='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head><body>'+
                    'Dear '+lstCon[0].Name+
                    '<p><b>A gentle reminder for your University outstanding fees</b></p>'+            
                    '<table border="1" cellpadding="0" cellspacing="0" width="800px"  >'+
                    '<tr><td style="color:#f57f26;"> <center><b>Fee Name</b></center></td>'+'<td style="color:#f57f26;"> <center><b>Fee Type </b></center></td>'+'<td style="color:#f57f26;"><center><b>Due Date</b></center></td>'+'<td style="color:#f57f26;"><center><b>Total Amount</b></center></td>'+'<td style="color:#f57f26;"><center><b>Amount Paid</b></center></td>'+'<td style="color:#f57f26;"><center><b>Amount Pending</b></center></td>';
                
                set_Reportid.add(con.id);
                if(con.Email != null)  lst_ToEmail.add(con.Email); //
                if(con.hed__WorkEmail__c != null) lst_ToEmail.add(con.hed__WorkEmail__c);
                
                for(Student_Fee__c objstu : con.Student_Fees__r)
                {
                    strDateOfconf = Datetime.newInstance(objstu.Due_Date__c.Year(),
                                                         objstu.Due_Date__c.Month(),
                                                         objstu.Due_Date__c.day()).format('dd/MM/yyyy'); 
                    
                    Textbody = Textbody + '<tr><td>'+ ' ' + objstu.Name +'</td>'+'<td>'+' ' +objstu.Fee_Type__c +'</td>'+'<td>'+' ' +strDateOfconf +'</td>'+'<td style="text-align:Right;">'+objstu.Amount__c +'</td>'+'<td style="text-align:Right;">'+objstu.Amount_Paid__c +'</td>'+ '<td style="text-align:Right;">'+objstu.Amount_Pending__c +'</td>';
                }
                
                Textbody = Textbody +'</tr></table><br>'+
                    ' <p dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt; text-align:center; background-color:#eee; padding:10px 0;"><span style="font-size:'+
                    '13pt; font-family: Calibri, sans-serif;  vertical-align: baseline; white-space: pre-wrap;">For any support request contact us at <a href="mailto:ictsupport@reva.'+
                    'edu.in" style="color:#f57f26;">ictsupport@reva.edu.in.</a></span></p>'+
                    '</body></html>';
                if(set_Reportid.size()>0)
                {     
                    for(Contact objcon : [Select Id,Name,Email,ReportsToid from contact where ReportsToid in:set_Reportid and RecordTypeId=:ConParentTypeId])
                    {
                        if(objcon.Email != null) lst_CCEmail.add(objcon.Email);                
                    }
                }
                OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'REVA Alerts'];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
                if ( owea.size() > 0 ) 
                {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                
                if(lst_ToEmail.size()>0) email.SetToAddresses(lst_ToEmail);                    
                if(lst_CCEmail.size()>0) email.setCCAddresses(lst_CCEmail);
                    
                email.setSubject('Fee Remainder'); 
                email.setHtmlBody(TextBody);
                lst_Email.add(email);
                if(lst_Email.size()> 0 && lst_ToEmail.size() > 0 )
                {
                    Messaging.sendEmail(lst_Email);
                }
            }
        }
    }     
    global void finish(DataBase.BatchableContext bc)
    {
        //BatchClass_Utility.sendBatchClassFailureMail('Fee Module', bc.getJobId(), 'Fee Due Date','Student Fees');
    }
}