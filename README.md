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
Make a sample post request to  https://enld0ffhayqonxl.m.pipedream.net
```java
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

For production environments...

```sh
$ npm install --production
$ NODE_ENV=production node app
```

### How to set up integrations

##### Setup the metadata records
To set up integrations, create records of the **API Integration metadata** with following information
| Field | Notes |
|-------| ------ |
| Endpoint | URI of the endpoint. Named credentials can be used |
| HTTP Method | Method to be used - GET/POST/PUT/PATCH/DELETE |
| Request Headers | Key:Value pairs to be set in the request header. Key and value are both strings |
| Request Body | Key:Value pairs to form the JSON request. Each on a seperate line | 
| Timeout | Timeout period in milliseconds |

**Request body can contain field references**. eg. Opportunity.Name, Opportunity.Account.Name, Account.Name etc. To set these values in the record, a map of type <String, SObject> has to be passed in the buildRequestBody() function. This map should have the base object as the key and the corresponding record as the value. 

Eg. **if Opportunity.Name, Account.Name** are used in the request body, fetch the required Opportunity and Account record and build a map such that **'Opportunity' => Opportunity record and 'Account' => Account record**

If the mapping is  as **Opp.Name, Acc.Name** in the request body, then fetch the required Opportunity and Accoutn record and build the map such that **'Opp'=> Opportunity record and 'Acc' => Account record**

#### Sample requests
**Metadata** : Uses {!$Credential.Password} and {!$Credential.Username from named credentials 
![image](https://user-images.githubusercontent.com/31303415/112880616-4aff7480-90e8-11eb-8665-9a372a34b646.png)

**Generated Request Headers** : 
```JSON
{
	"host": "enld0ffhayqonxl.m.pipedream.net",
	"x-amzn-trace-id": "Root=1-606184d5-10534a2f5096def72ec8e0c5",
	"content-length": "312",
	"authorization": "Basic Tkg6bmg=",
	"user-agent": "SFDC-Callout/51.0",
	"sfdc_stack_depth": "1",
	"password": "nh",
	"cache-control": "no-cache",
	"pragma": "no-cache",
	"accept": "text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2",
	"content-type": "application/x-www-form-urlencoded"
}
```

**Generated Request Body** : 
```JSON
{
	"numericValue2": 100.2356,
	"numericValue1": 10,
	"booleanValue": true,
	"date": "2021-03-29",
	"datetime": "03/29/2021 13:12:12",
	"nullField": null,
	"username": "NH",
	"additionalAccount": "Push Account Test GG Chart Refresh",
	"isActive": "TRUE",
	"accountName": "United Oil & Gas Corp.",
	"name": "United Oil Office Portable Generators"
}
```
