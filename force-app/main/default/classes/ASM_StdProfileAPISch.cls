global class ASM_StdProfileAPISch  implements Schedulable{
    global void execute(SchedulableContext sc){
        Database.executeBatch(new ASM_StdProfileAPIBatch(),100);
    }
}