/*********************************************
* TThis class to generate Json for IA Marks Data
* And it'll send the same to Logisys API
* It's called from:
* ********************************************/
public class ASM_IAMarksFomSfAPI {
    @future(callout=true)
    public static void sendIAMarks_future(Set<Id> set_IamIds, String reqType){
        Debug_Log__c dLog = sendIAMarks(set_IamIds,reqType);
        Insert dLog;
    }
    
    public static Debug_Log__c sendIAMarks(Set<Id> set_IamIds, String reqType){
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_IAMarksFomSfAPI';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'IA Marks Data to Logisys';
        dLog.Object_Name__c = 'IA_Marks__c';
        dLog.No_of_Records__c = set_IamIds.size();
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        
        try{
            Map<String,IA_Marks__c> map_IAMarks = new Map<String,IA_Marks__c>();
            List<reqWpr> list_reqWpr = new List<reqWpr>();
            for(IA_Marks__c iam : [SELECT Id,SRN_Number__c,Program_Code__c,Program__c,Course_Code__c,IA_Type__c,
                                   Course_Name__c,Course_Type__c,Course_Connection__r.Semester__c,
                                   Course_Offering__r.hed__Course__r.Seminar_Maximum_Marks__c,
                                   Course_Offering__r.hed__Course__r.Quiz_Maximum_Marks__c,
                                   Course_Offering__r.hed__Course__r.Theory_Maximum_Marks__c,
                                   Course_Offering__r.hed__Course__r.Analysis_and_Synthesis_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Literature_Survey_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Ethical_Attitude_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Independent_Learning_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Oral_Presentation_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Report_Writing_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Continuous_Learning_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Selection_of_Topic_Max_marks__c,
                                   Course_Offering__r.hed__Course__r.Knowledge_of_Exercise_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Execution_of_Exercise_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Description_of_Experiment_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Viva_Voce_Practical_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Punctuality_Max_Marks__c,
                                   Course_Offering__r.hed__Course__r.Results_Max_Marks__c,
                                   Theory_Secured_Marks__c,Seminar_Secured_Marks__c,Quiz_Secured_marks__c,
                                   Analysis_and_Synthesis_Secured_Marks__c,Continuous_Learning_Secured_Marks__c,
                                   Ethical_Attitude_Secured_Marks__c,Independent_Learning_Secured_Marks__c,
                                   Literature_Survey_Secured_Marks__c,Selection_of_Topic_Secured_Marks__c,
                                   Oral_Presentation_Secured_Marks__c,Report_Writing_Secured_Marks__c,
                                   Knowledge_of_Exercise_Secured_Marks__c,Execution_of_Exercise_Secured_Marks__c,
                                   Description_of_Experiment_Secured_Mark__c,Viva_Voce_Practical_Secured_Marks__c,
                                   Punctuality_Secured_Marks__c,Results_Secured_Marks__c,
                                   School__c,Active_Semester_Number__c
                                   FROM IA_Marks__c WHERE Id IN: set_IamIds])
            {
                String key = iam.SRN_Number__c+'_'+iam.Course_Code__c+'_'+iam.IA_Type__c;
                iam.Logisys_Integration__c = 'Yes';
                map_IAMarks.put(key,iam);
                
                reqWpr rWpr = new reqWpr();
                rWpr.regno = String.isNotBlank(iam.SRN_Number__c) ? iam.SRN_Number__c : '';
                rWpr.degcode = String.isNotBlank(iam.Program_Code__c) ? iam.Program_Code__c : '';
                rWpr.degname = String.isNotBlank(iam.Program__c) ? iam.Program__c : '';
                rWpr.sem = String.isNotBlank(string.valueof(iam.Active_Semester_Number__c)) ? string.valueof(iam.Active_Semester_Number__c) : '';
                rWpr.collcode =String.isNotBlank(iam.School__c) ? iam.School__c : '';
                rWpr.subcode = String.isNotBlank(iam.Course_Code__c) ? iam.Course_Code__c : '';
                rWpr.subname = String.isNotBlank(iam.Course_Name__c) ? iam.Course_Name__c : '';
                rWpr.subtype = String.isNotBlank(iam.Course_Type__c) ? iam.Course_Type__c : '';
                rWpr.iatype = String.isNotBlank(iam.IA_Type__c) ? iam.IA_Type__c : '';
                rWpr.rtype = reqType;
                
                rWpr.maxTheorymarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Theory_Maximum_Marks__c);
                rWpr.secTheorymarks = String.valueof(iam.Theory_Secured_Marks__c);
                rWpr.maxQuizmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Quiz_Maximum_Marks__c);
                rWpr.secQuizmarks = String.valueof(iam.Quiz_Secured_marks__c);
                rWpr.maxSeminarmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Seminar_Maximum_Marks__c);
                rWpr.secSeminarmarks = String.valueof(iam.Seminar_Secured_Marks__c);
                
                rWpr.maxSelofTopicmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Selection_of_Topic_Max_marks__c);
                rWpr.secSelofTopicmarks = String.valueof(iam.Selection_of_Topic_Secured_Marks__c);
                rWpr.maxAnaandSyntmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Analysis_and_Synthesis_Max_Marks__c);
                rWpr.secAnaandSyntmarks = String.valueof(iam.Analysis_and_Synthesis_Secured_Marks__c);
                rWpr.maxLitandSvymarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Literature_Survey_Max_Marks__c);
                rWpr.secLitandSvymarks = String.valueof(iam.Literature_Survey_Secured_Marks__c);
                rWpr.maxEthicAttmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Ethical_Attitude_Max_Marks__c);
                rWpr.secEthicAttmarks = String.valueof(iam.Ethical_Attitude_Secured_Marks__c);
                rWpr.maxIndLearnmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Independent_Learning_Max_Marks__c);
                rWpr.secIndLearnmarks = String.valueof(iam.Independent_Learning_Secured_Marks__c);
                rWpr.maxOralmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Oral_Presentation_Max_Marks__c);
                rWpr.secOralmarks = String.valueof(iam.Oral_Presentation_Secured_Marks__c);
                rWpr.maxRepwritemarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Report_Writing_Max_Marks__c);
                rWpr.secRepwritemarks = String.valueof(iam.Report_Writing_Secured_Marks__c);
                rWpr.maxContLearnmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Continuous_Learning_Max_Marks__c);
                rWpr.secContLearnmarks = String.valueof(iam.Continuous_Learning_Secured_Marks__c);
                
                rWpr.maxKnowExermarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Knowledge_of_Exercise_Max_Marks__c);
                rWpr.secKnowExercisemarks = String.valueof(iam.Knowledge_of_Exercise_Secured_Marks__c);
                rWpr.maxExecExercisemarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Execution_of_Exercise_Max_Marks__c);
                rWpr.secExecExercisemarks = String.valueof(iam.Execution_of_Exercise_Secured_Marks__c);
                rWpr.maxDescExpmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Description_of_Experiment_Max_Marks__c);
                rWpr.secDescExpmarks = String.valueof(iam.Description_of_Experiment_Secured_Mark__c);
                rWpr.maxVivamarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Viva_Voce_Practical_Max_Marks__c);
                rWpr.secVivamarks = String.valueof(iam.Viva_Voce_Practical_Secured_Marks__c);
                rWpr.maxPunctualmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Punctuality_Max_Marks__c);
                rWpr.secPunctualmarks = String.valueof(iam.Punctuality_Secured_Marks__c);
                rWpr.maxPracResultsmarks = String.valueof(iam.Course_Offering__r.hed__Course__r.Results_Max_Marks__c);
                rWpr.secPracResultsmarks = String.valueof(iam.Results_Secured_Marks__c);
                
                list_reqWpr.add(rWpr);
            }
            String jsonBody = Json.serialize(list_reqWpr);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
            
            //Map Http Request
            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_IAMarksFomSfAPI',jsonBody);
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            
            String response = hRsp+' ::: '+hRsp.getBody();
            dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
            if(hRsp.getStatusCode() == 200){
                String resBody = hRsp.getBody();
                rspWpr rsp = (rspWpr) Json.deserialize(resBody, rspWpr.class);
                if(reqType == 'I' || reqType == 'D'){
                    for(resdata rwp : rsp.data.resdata){
                        String key = rwp.regno+'_'+rwp.subcode+'_'+rwp.iatype;
                        //System.debug('key=='+key);
                        //System.debug('map_IAMarks=='+map_IAMarks.get(key));
                        if(rwp.status == 'F' && map_IAMarks.get(key) != null && map_IAMarks.get(key).Logisys_Integration__c == 'Yes'){
                            map_IAMarks.get(key).Logisys_Integration__c = 'No';
                        }
                    }
                    Update map_IAMarks.values();
                }
                dLog.Status__c = rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
            }
        }catch(exception e){
            //System.debug('@@==>> Exception: '+e.getMessage()+'. At: '+e.getStackTraceString());
            dLog.Error_Message__c = e.getMessage()+'. At: '+e.getStackTraceString();
        }
        return dLog;
    }
    
    public static reqWpr mapBaseParams(IA_Marks__c iam, String reqType, String subType, Decimal maxMarks, Decimal secMarks){
        reqWpr rWpr = new reqWpr();
        rWpr.regno = String.isNotBlank(iam.SRN_Number__c) ? iam.SRN_Number__c : '';
        rWpr.degcode = String.isNotBlank(iam.Program_Code__c) ? iam.Program_Code__c : '';
        rWpr.degname = String.isNotBlank(iam.Program__c) ? iam.Program__c : '';
        rWpr.sem = String.isNotBlank(iam.Course_Connection__r.Semester__c) ? iam.Course_Connection__r.Semester__c : '';
        rWpr.subcode = String.isNotBlank(iam.Course_Code__c) ? iam.Course_Code__c : '';
        rWpr.subname = String.isNotBlank(iam.Course_Name__c) ? iam.Course_Name__c : '';
        //rWpr.type = String.isNotBlank(iam.Course_Type__c) ? iam.Course_Type__c : '';
        rWpr.subtype = subType;
        rWpr.iatype = String.isNotBlank(iam.IA_Type__c) ? iam.IA_Type__c : '';
        rWpr.rtype = reqType;
        //rWpr.maxmarks = maxMarks;
        //rWpr.secmarks = secMarks;
        return rWpr;
    }
    
    public class reqWpr{
        public String secIndLearnmarks;
        public String maxOralmarks;
        public String maxIndLearnmarks;
        public String secOralmarks;
        public String secEthicAttmarks;
        public String maxRepwritemarks;
        public String maxEthicAttmarks;
        public String secRepwritemarks;
        public String secLitandSvymarks;
        public String maxContLearnmarks;
        public String maxLitandSvymarks;
        public String secContLearnmarks;
        public String secAnaandSyntmarks;
        public String maxKnowExermarks;
        public String maxAnaandSyntmarks;
        public String secKnowExercisemarks;
        public String secSelofTopicmarks;
        public String maxExecExercisemarks;
        public String maxSelofTopicmarks;
        public String secExecExercisemarks;
        public String secSeminarmarks;
        public String maxDescExpmarks;
        public String maxSeminarmarks;
        public String secDescExpmarks;
        public String secQuizmarks;
        public String maxVivamarks;
        public String maxQuizmarks;
        public String secVivamarks;
        public String secTheorymarks;
        public String maxPunctualmarks;
        public String maxTheorymarks;
        public String secPunctualmarks;
        public String subname;
        public String maxPracResultsmarks;
        public String subcode;
        public String secPracResultsmarks;
        public String sem;
        public String subtype;
        public String degname;
        public String iatype;
        public String degcode;
        public String rtype;
        public String regno;
        public String collcode;
    }
    
    
    public class rspWpr{
        public String status;
        public dataWpr data;
        public Integer error_code;
    }
    
    public class resdata{
        public String status{get;set;}
        public String msg{get;set;}
        public String regno;
        public String degcode;
        public String subcode;
        public String iatype;
    }
    public class dataWpr{
        public list<resdata> resdata{get;set;}
    }
}