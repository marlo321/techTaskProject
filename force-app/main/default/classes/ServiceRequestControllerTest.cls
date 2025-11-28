@IsTest
private class ServiceRequestControllerTest {

    @IsTest
    static void testCreateServiceRequests_SingleSuccess() {
        ServiceRequestController.CreateRequestInput input =
            new ServiceRequestController.CreateRequestInput();
        input.customerEmail = 'test@example.com';
        input.description = 'Test description';
        input.priority = 'High';

        List<ServiceRequestController.CreateRequestInput> inputs =
            new List<ServiceRequestController.CreateRequestInput>{
                input,
                null
            };

        Test.startTest();
        List<Service_Request__c> result = ServiceRequestController.createServiceRequests(inputs);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Exactly one Service Request should be created.');
        Service_Request__c sr = result[0];
        System.assertEquals('test@example.com', sr.Customer_Email__c);
        System.assertEquals('Test description', sr.Description__c);
        System.assertEquals('High', sr.Priority__c);
        System.assertEquals('New', sr.Status__c);
    }

    @IsTest
    static void testCreateServiceRequests_BulkSuccess() {
        List<ServiceRequestController.CreateRequestInput> inputs =
            new List<ServiceRequestController.CreateRequestInput>();

        for (Integer i = 0; i < 5; i++) {
            ServiceRequestController.CreateRequestInput input =
                new ServiceRequestController.CreateRequestInput();
            input.customerEmail = 'bulk' + i + '@example.com';
            input.description = 'Bulk description ' + i;
            input.priority = 'Low';
            inputs.add(input);
        }

        Test.startTest();
        List<Service_Request__c> result = ServiceRequestController.createServiceRequests(inputs);
        Test.stopTest();

        System.assertEquals(5, result.size(), 'Five Service Requests should be created.');
        for (Service_Request__c sr : result) {
            System.assertEquals('New', sr.Status__c, 'Status should be New on creation.');
        }
    }

    @IsTest
    static void testCreateServiceRequests_NullInputs() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ServiceRequestController.createServiceRequests(null);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception for null inputs.');
    }

    @IsTest
    static void testCreateServiceRequests_EmptyInputs() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ServiceRequestController.createServiceRequests(
                new List<ServiceRequestController.CreateRequestInput>()
            );
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception for empty inputs.');
    }

    @IsTest
    static void testCreateServiceRequests_BlankEmail() {
        ServiceRequestController.CreateRequestInput input =
            new ServiceRequestController.CreateRequestInput();
        input.customerEmail = '';
        input.description = 'Desc';
        input.priority = 'Low';

        List<ServiceRequestController.CreateRequestInput> inputs =
            new List<ServiceRequestController.CreateRequestInput>{ input };

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ServiceRequestController.createServiceRequests(inputs);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception for blank email.');
    }

    @IsTest
    static void testCreateServiceRequests_BlankDescription() {
        ServiceRequestController.CreateRequestInput input =
            new ServiceRequestController.CreateRequestInput();
        input.customerEmail = 'd@example.com';
        input.description = '';
        input.priority = 'Low';

        List<ServiceRequestController.CreateRequestInput> inputs =
            new List<ServiceRequestController.CreateRequestInput>{ input };

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ServiceRequestController.createServiceRequests(inputs);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception for blank description.');
    }

    @IsTest
    static void testCreateServiceRequests_BlankPriority() {
        ServiceRequestController.CreateRequestInput input =
            new ServiceRequestController.CreateRequestInput();
        input.customerEmail = 'p@example.com';
        input.description = 'Desc';
        input.priority = '';

        List<ServiceRequestController.CreateRequestInput> inputs =
            new List<ServiceRequestController.CreateRequestInput>{ input };

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ServiceRequestController.createServiceRequests(inputs);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception for blank priority.');
    }

    @IsTest
    static void testCreateServiceRequests_InvalidEmailFormat() {
        ServiceRequestController.CreateRequestInput input =
            new ServiceRequestController.CreateRequestInput();
        input.customerEmail = 'invalidEmailWithoutAt';
        input.description = 'Desc';
        input.priority = 'Low';

        List<ServiceRequestController.CreateRequestInput> inputs =
            new List<ServiceRequestController.CreateRequestInput>{ input };

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ServiceRequestController.createServiceRequests(inputs);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception for invalid email format.');
    }

    @IsTest
    static void testResolveServiceRequests_Success() {

        List<Service_Request__c> srs = new List<Service_Request__c>();
        for (Integer i = 0; i < 3; i++) {
            Service_Request__c sr = new Service_Request__c();
            sr.Customer_Email__c = 'resolve' + i + '@example.com';
            sr.Description__c = 'To be resolved ' + i;
            sr.Priority__c = 'Medium';
            sr.Status__c = 'New';
            srs.add(sr);
        }
        insert srs;

        List<ResolveRequestInput> inputs =
            new List<ResolveRequestInput>();

        for (Service_Request__c sr : srs) {
            ResolveRequestInput inp =
                new ResolveRequestInput();
            inp.serviceRequestId = sr.Id;
            inp.resolutionNotes = 'Resolved notes for ' + sr.Id;
            inputs.add(inp);
        }

        Test.startTest();
        ServiceRequestController.resolveServiceRequests(inputs);
        Test.stopTest();

        List<Service_Request__c> updated = [
            SELECT Id, Status__c, Resolution_Notes__c
            FROM Service_Request__c
            WHERE Id IN :srs
        ];

        for (Service_Request__c sr : updated) {
            System.assertEquals('Resolved', sr.Status__c, 'Status should be Resolved.');
            System.assertNotEquals(null, sr.Resolution_Notes__c, 'Resolution_Notes__c should be populated.');
        }
    }

    @IsTest
    static void testResolveServiceRequests_NullInputs() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ServiceRequestController.resolveServiceRequests(null);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception for null resolve inputs.');
    }

    @IsTest
    static void testResolveServiceRequests_EmptyInputs() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ServiceRequestController.resolveServiceRequests(
                new List<ResolveRequestInput>()
            );
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception for empty resolve inputs.');
    }

    @IsTest
    static void testResolveServiceRequests_NoValidIds() {

        List<ResolveRequestInput> inputs =
            new List<ResolveRequestInput>();

        for (Integer i = 0; i < 3; i++) {
            ResolveRequestInput inp =
                new ResolveRequestInput();
            inp.serviceRequestId = null;
            inp.resolutionNotes = 'Will not be used';
            inputs.add(inp);
        }

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            ServiceRequestController.resolveServiceRequests(inputs);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception when no valid ids are provided.');
    }

    @IsTest
    static void testGetRecentServiceRequests() {

        List<Service_Request__c> srs = new List<Service_Request__c>();
        for (Integer i = 0; i < 7; i++) {
            Service_Request__c sr = new Service_Request__c();
            sr.Customer_Email__c = 'recent' + i + '@example.com';
            sr.Description__c = 'Recent desc ' + i;
            sr.Priority__c = 'Low';
            sr.Status__c = 'New';
            srs.add(sr);
        }
        insert srs;

        Test.startTest();
        List<Service_Request__c> recent = ServiceRequestController.getRecentServiceRequests();
        Test.stopTest();

        System.assertEquals(5, recent.size(), 'Should return only 5 records.');
    }
    
}
