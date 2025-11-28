public with sharing class ResolveRequestInput {

    @AuraEnabled @InvocableVariable public Id serviceRequestId;
    @AuraEnabled @InvocableVariable public String resolutionNotes;

}