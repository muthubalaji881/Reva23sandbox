public without sharing class SMS_Task_Creation {
    public static void CreateMultipleTask(List<Map<String,String>> phonewithSMSTemplates){

    List<Task> taskCollection = new List<Task>();
    List<SObject> recordcollection = new List<SObject>();
    List<String> descrption = new List<String>();
    
    /*List<String> keys = new List<String>();
    for(List<String> subList: phonewithSMSTemplates.keySet())keys.addAll(subList);
    System.debug('keys: '+keys);*/
    for(Integer i=0;i<phonewithSMSTemplates.size();i++){
    recordcollection.addAll([Select id, ownerid, mobilePhone from Lead Where mobilePhone IN :phonewithSMSTemplates[i].keyset()]);
    recordcollection.addAll([Select id, ownerid, mobilePhone from Contact Where mobilePhone in: phonewithSMSTemplates[i].keyset()]);
    descrption.addAll(phonewithSMSTemplates[i].values());
    }

    //recordcollection.addAll([Select id, ownerid, mobilePhone from Lead Where mobilePhone IN :phonewithSMSTemplates[i].keyset()]);
    //recordcollection.addAll([Select id, ownerid, mobilePhone from Contact Where mobilePhone in: phonewithSMSTemplates[i].keyset()]);
    
   // List<String> descrption = phonewithSMSTemplates[0].values();
   // List<String> des = descrption[0];
    System.debug(descrption);

    
    System.debug(recordcollection.size());
/* 
    for(List<String> phones :phonewithSMSTemplates.keySet()){
        for(String descp : phonewithSMSTemplates.get(phones)){
            system.debug(' Map keyset phone Value' + phones );
            system.debug(' list values : '+ descp);
        }
    } */

    for(Map<String,String> phoneMap :phonewithSMSTemplates){
        for(SObject currentrecord: recordcollection){
            //if((String)currentrecord.get('mobilePhone')=keys){
                String mobilePhone =(String) currentrecord.get('mobilePhone');
                Task singleTask = new Task();
                singleTask.Description=phoneMap.get(mobilePhone);
                singleTask.Subject='SMS Sent Successfully';
                singleTask.Status='Completed';
                singleTask.WhoId= currentrecord.id;
                singleTask.OwnerId=(Id)currentrecord.get('ownerid');
                singleTask.ActivityDate=system.today();
                taskCollection.add(singleTask);
            
       
        }
    }

       
/*     for(SObject currentrecord: recordcollection){
            //if((String)currentrecord.get('mobilePhone')=keys){
                Task singleTask = new Task();
                singleTask.Description=phonewithSMSTemplates.get(Currentrecord.mobilePhone);
                singleTask.Subject='SMS Sent Successfully';
                singleTask.Status='Completed';
                singleTask.WhoId= currentrecord.id;
                singleTask.OwnerId=(Id)currentrecord.get('ownerid');
                singleTask.ActivityDate=system.today();
                taskCollection.add(singleTask);
            
       
        } */
            insert taskCollection;
            System.debug(taskCollection);

    }
    public static void CreateSingleTask(Map<String,String> phonewithSMSTemplate){

        List<Task> taskCollection = new List<Task>();
        List<SObject> recordcollection = new List<SObject>();

        recordcollection.addAll([Select id, ownerid, mobilePhone from Lead Where mobilePhone in: phonewithSMSTemplate.keySet()]);
        recordcollection.addAll([Select id, ownerid, mobilePhone from Contact Where mobilePhone in: phonewithSMSTemplate.keySet()]);
       
        List<String> descrption = phonewithSMSTemplate.values();

        for(SObject currentrecord: recordcollection){
            Task singleTask = new Task();
            singleTask.Description=descrption[0];
            singleTask.Subject='SMS Sent Successfully';
            singleTask.Status='Completed';
            singleTask.WhoId= currentrecord.id;
            singleTask.OwnerId=(Id)currentrecord.get('ownerid');
            singleTask.ActivityDate=system.today();
            taskCollection.add(singleTask);
            System.debug(taskCollection);
        }
        insert taskCollection;
    }
}