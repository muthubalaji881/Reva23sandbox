@Istest
public class TT_ViewSchedule_SectionCls_Test 
{
    Public static testmethod Void SectionMethod()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
        Account objAcc = TT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        Contact objCon = TT_TestDataFactory.createContact('Test');
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        objcon.Nationality__c = 'Indian';
        Insert objCon;
        
        hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        obj_Cour.hed__Course_ID__c ='123';
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();        
        hed__Term__c obj_Term = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();        
        hed__Course_Enrollment__c obj_CourEnroll = TT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
        obj_CourEnroll.RecordTypeId= enrollRecTypeId;
        obj_CourEnroll.Section__c = obj_Term.id;
        Insert obj_CourEnroll;
        
        hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.hed__Start_Time__c = system.now().time();
        objcourseSch.hed__End_Time__c = system.now().time();
        insert objcourseSch;
        
        TT_ViewSchedule_SectionCls.SlotTimeWrp slwrap = new TT_ViewSchedule_SectionCls.SlotTimeWrp(string.valueof(system.now().time()),string.valueof(system.now().time()));
        slwrap.eTime = string.valueof(system.now().time());
        slwrap.sTime = string.valueof(system.now().time());
        
        TT_ViewSchedule_SectionCls.SlotWrp stwarp = new TT_ViewSchedule_SectionCls.SlotWrp('test','test course',2);
        stwarp.slotname ='test';
        stwarp.courseNames='test course';
        stwarp.colLen=2;
        
        list<TT_ViewSchedule_SectionCls.SlotWrp> lst_stwrap = new list<TT_ViewSchedule_SectionCls.SlotWrp>();
        lst_stwrap.add(stwarp);
        
        TT_ViewSchedule_SectionCls.ScheduleWrp schwrap = new TT_ViewSchedule_SectionCls.ScheduleWrp('monday',lst_stwrap);
        schwrap.dayName ='monday';
        schwrap.lst_Slots = lst_stwrap;
        
        TT_ViewSchedule_SectionCls.FacultyWrp fwrap = new TT_ViewSchedule_SectionCls.FacultyWrp(obj_CourEnroll.id,'123','test course','test faculty');
        fwrap.connectionId=obj_CourEnroll.Id;
        fwrap.courseCode='123';
        fwrap.coursename='test course';
        fwrap.facultyName='test faculty';
        
        test.starttest();
        TT_ViewSchedule_SectionCls.getTimeTableRecords(obj_Term.Id);
        TT_ViewSchedule_SectionCls.getTimeTableRecords('');
        TT_ViewSchedule_SectionCls.getFaculties(obj_Term.Id);
        test.stopTest();
        system.assertEquals(obj_Term.Id, objcourseSch.Section__c);
    }
    Public static testmethod Void SectionMethod1()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
        Account objAcc = TT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        Contact objCon = TT_TestDataFactory.createContact('Test');
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;    
        objcon.Nationality__c = 'Indian';        
       // objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        obj_Cour.hed__Course_ID__c ='123';
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();        
        hed__Term__c obj_Term = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();        
        hed__Course_Enrollment__c obj_CourEnroll = TT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
        obj_CourEnroll.RecordTypeId= enrollRecTypeId;
        obj_CourEnroll.Section__c = obj_Term.id;
        Insert obj_CourEnroll;
        
        hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.hed__Monday__c =false;
        objcourseSch.hed__Tuesday__c =true;
        objcourseSch.hed__Wednesday__c =true;
        objcourseSch.hed__Thursday__c = true;
        objcourseSch.hed__Friday__c =true;
        objcourseSch.hed__Saturday__c =true;
        objcourseSch.hed__Sunday__c =true;
        objcourseSch.hed__Start_Time__c = system.now().time();
        objcourseSch.hed__End_Time__c = system.now().time();
        insert objcourseSch;
        
        TT_ViewSchedule_SectionCls.SlotTimeWrp slwrap = new TT_ViewSchedule_SectionCls.SlotTimeWrp(string.valueof(system.now().time()),string.valueof(system.now().time()));
        slwrap.eTime = string.valueof(system.now().time());
        slwrap.sTime = string.valueof(system.now().time());
        
        TT_ViewSchedule_SectionCls.SlotWrp stwarp = new TT_ViewSchedule_SectionCls.SlotWrp('test','test course',2);
        stwarp.slotname ='test';
        stwarp.courseNames='test course';
        stwarp.colLen=2;
        
        list<TT_ViewSchedule_SectionCls.SlotWrp> lst_stwrap = new list<TT_ViewSchedule_SectionCls.SlotWrp>();
        lst_stwrap.add(stwarp);
        
        TT_ViewSchedule_SectionCls.ScheduleWrp schwrap = new TT_ViewSchedule_SectionCls.ScheduleWrp('monday',lst_stwrap);
        schwrap.dayName ='monday';
        schwrap.lst_Slots = lst_stwrap;
        
        TT_ViewSchedule_SectionCls.FacultyWrp fwrap = new TT_ViewSchedule_SectionCls.FacultyWrp(obj_CourEnroll.id,'123','test course','test faculty');
        fwrap.connectionId=obj_CourEnroll.Id;
        fwrap.courseCode='123';
        fwrap.coursename='test course';
        fwrap.facultyName='test faculty';
        
        test.starttest();
        TT_ViewSchedule_SectionCls.getTimeTableRecords(obj_Term.Id);       
        test.stopTest();
        system.assertEquals(obj_Term.Id, objcourseSch.Section__c);
    }
}