public without sharing class RegistrationProcessUtility {
    private static final Integer APPLICATION_NUMBER_SEQ_LENGTH = 5;
    private static final String APPLICATION_NUMBER_PAD_STRING = '0';
    private static final String CACHE_NAME = 'local.DefaultCache';
    private static final String COUNSELOR_INDEX_KEY = 'CounselorIndex';
    private static final Integer CACHE_TTL_48_Hours = 48 * 60 * 60;

    public static String generateApplNoSequence(String applNoPrefix){
        return  getApplNumSeqStr(getNextSequence(applNoPrefix));
    }

    public static String getApplNumSeqStr(Integer seq) {
        String seqStr = seq + ''; //convert number to string
        return(seqStr.leftPad(APPLICATION_NUMBER_SEQ_LENGTH, APPLICATION_NUMBER_PAD_STRING));
    }

    public static Integer getNextSequence(String applicationNumberPrefix) {
        Integer nextSequence;
        //Query and lock the object
        List<Sequence_Number__c> seqNums = [select Integer_Five__c
                                            from Sequence_Number__c
                                            where Key_Field__c = :applicationNumberPrefix
                                            FOR UPDATE];
        if (seqNums.size() < 1) {
        //Handle error
        }

        nextSequence = (Integer)seqNums[0].Integer_Five__c + 1;
        seqNums[0].Integer_Five__c = nextSequence;
        update(seqNums);

        return nextSequence;
    }
    
    /*
    * This method uses Platform Cache to get index of the counselor
    * to whom the next Lead or Contact has to be assigned. 
    */
    public static Integer getCounselorIndex() {
      Cache.OrgPartition orgPartition = Cache.Org.getPartition(CACHE_NAME);
      Integer counselorIndex = (Integer)orgPartition.get(COUNSELOR_INDEX_KEY);

      if (counselorIndex == null) {
        System.debug('>>>> Cache miss. Returning default counselorIndex -1');
        counselorIndex = -1;
        RegistrationProcessUtility.setCounselorIndex(counselorIndex);
      }
      return counselorIndex;
    }

    /*
    * This method uses Platform Cache to set index of the counselor
    * to whom the last Lead or Contact was assigned. 
    */
    public static void setCounselorIndex(Integer counselorIndex) {
      Cache.Org.getPartition(CACHE_NAME).put(COUNSELOR_INDEX_KEY, counselorIndex, CACHE_TTL_48_Hours);
    }
}