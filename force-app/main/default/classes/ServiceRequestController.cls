public with sharing class ServiceRequestController {

    private static final String STATUS_NEW = 'New';
    private static final String STATUS_RESOLVED = 'Resolved';

    public class CreateRequestInput {
        @AuraEnabled public String customerEmail { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String priority { get; set; }
    }

    @InvocableMethod(
        label='Resolve Service Requests with Notes'
        description='Resolves Service Requests and stores the provided resolution notes.'
    )
    public static void resolveRequests(List<ResolveRequestInput> requests) {
        resolveServiceRequests(requests);
    }

    public static void resolveServiceRequests(List<ResolveRequestInput> inputs) {
        if (inputs == null || inputs.isEmpty()) {
            throw new AuraHandledException('At least one resolve input is required.');
        }

        List<Service_Request__c> updates = new List<Service_Request__c>();

        for (ResolveRequestInput input : inputs) {
            if (input == null || input.serviceRequestId == null) {
                continue;
            }

            updates.add(new Service_Request__c(
                Id = input.serviceRequestId,
                Status__c = STATUS_RESOLVED,
                Resolution_Notes__c = input.resolutionNotes
            ));
        }

        if (updates.isEmpty()) {
            throw new AuraHandledException('No valid Service Request Ids provided.');
        }

        update updates;
    }


    @AuraEnabled
    public static List<Service_Request__c> createServiceRequests(List<CreateRequestInput> inputs) {
        if (inputs == null || inputs.isEmpty()) {
            throw new AuraHandledException('At least one Service Request input is required.');
        }

        List<Service_Request__c> toInsert = new List<Service_Request__c>();

        Pattern emailPattern = Pattern.compile('^.+@.+\\..+$');

        for (CreateRequestInput input : inputs) {
            if (input == null) {
                continue;
            }

            if (String.isBlank(input.customerEmail)) {
                throw new AuraHandledException('Customer email is required.');
            }
            if (String.isBlank(input.description)) {
                throw new AuraHandledException('Description is required.');
            }
            if (String.isBlank(input.priority)) {
                throw new AuraHandledException('Priority is required.');
            }

            if (!emailPattern.matcher(input.customerEmail).matches()) {
                throw new AuraHandledException('Customer email is not valid.');
            }

            Service_Request__c sr = new Service_Request__c();
            sr.Customer_Email__c = input.customerEmail;
            sr.Description__c = input.description;
            sr.Priority__c = input.priority;
            sr.Status__c = STATUS_NEW;

            toInsert.add(sr);
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }

        return toInsert;
    }

    @AuraEnabled(cacheable=true)
    public static List<Service_Request__c> getRecentServiceRequests() {
        return [
            SELECT Id, Name, Customer_Email__c, Status__c, Priority__c
            FROM Service_Request__c
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
    }
}
