global class ScheduledApexPOC implements Schedulable{
 	//public static String CRON_EXP = '0 0 6 */2 * ?';

      global void execute(SchedulableContext sc) {
      BatchApexPOC batchApexPoc = new BatchApexPOC(); 
      database.executeBatch(batchApexPoc, 200);
   }
}