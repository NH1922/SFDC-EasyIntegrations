# SFDC-Easy Integrations


A metadata driven approach to simplify integration with other systems. The goal is to build reusable solution that can build requests without having to write lot of apex (wrappers) for each integration. 

# Implementation so far 

  - Supports request building based on objects and their field values/parent record's field values
  - Supports named credentials and their merge fields
  - Builds requests without any wrappers involved 
  - Can build requests using multiple records at once
  - Direct support for all JSON data types except Array and Object 

### Get started

Clone the repository and deploy the metadata to your org
Make a sameple post request to  https://enld0ffhayqonxl.m.pipedream.net
```sh
String APIIntegrationName = 'Sample_Callout';
IntegrationUtility requestBuilder = new IntegrationUtility(APIIntegrationName);
HttpRequest request = requestBuilder.getHTTPRequestWithoutHeaders();
        
// Set Headers
requestBuilder.setRequestHeaders(request);

// Fetch the records required to build the request body
Opportunity opp = [SELECT Id, name, Account.Name FROM Opportunity ORDER BY CreatedDate ASC LIMIT 1];
Account acc = [SELECT Name FROM Account ORDER BY CreatedDate DESC LIMIT 1];

// Build the request body
Map<String,SObject> objectMap = new Map<String,SObject>{'Opportunity' => opp, 'Account' => acc};
Map<String,Object> requestMap = requestBuilder.buildRequestBody(objectMap);
request.setBody(JSON.serialize(requestMap));

// Make the callout
Http http = new Http();
HttpResponse response = http.send(request);
System.debug('Response : ' + response.getBody());
```
