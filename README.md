# Project Overview

This project implements a full Service Request workflow on the Salesforce platform using Lightning Web Components (LWC), Apex services, SOQL-based data operations, and Agentforce AI Actions. The system allows agents to:

- Create new Service Requests
- View the five most recent requests
- Resolve Service Requests with generated resolution notes
- Optionally use Agentforce AI to auto-generate internal notes and automatically resolve the request

The solution is built to be scalable, testable, and aligned with Salesforce platform best practices.

![alt text](https://github.com/marlo321/techTaskProject/blob/main/images/img.png "Service Request Form logo")

## Lightning Web Component (LWC)

Component Name serviceRequestPanel

Main Features:
- Form with fields (Customer Email, Description, Priority)
- List of last 5 Service Requests (wired via Apex)
- Form validation & error messaging

Highlights
- Uses data-name="email" | "description" | "priority" for DRY input handling
- Toasts for success and error feedback

## Apex Service Layer

Main Apex Class ServiceRequestController.cls

Exposed Methods:
- createServiceRequests(List<CreateRequestInput> inputs) -  create Service Requests by Email, Description and Priority
- resolveServiceRequests(List<ResolveRequestInput> inputs) - update Resolution Notes field by Service Request Id 
- getRecentServiceRequests() - return last 5 service request

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
