public without sharing class LeadStatusToUnqualify {
    @InvocableMethod(Label = 'Lead Status to Unqualify')
    public static void LeadToUnqualify(List<Id> recordId) {
        Lead recToUnqualify = [Select Id, Name, Status, Email From Lead Where Id =: recordId[0]];
        recToUnqualify.Status = 'Unqualified';
        update recToUnqualify;
    }
}