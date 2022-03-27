public with sharing class IntegrationUtility {

    private APIIntegration__mdt callout;
    public IntegrationUtility(String APIIntegrationName ) {
        this.callout = [SELECT Id, Endpoint__c, HTTPMethod__c, DeveloperName, RequestBody__c, RequestHeaders__c, Timeout__c 
                               FROM APIIntegration__mdt 
                               WHERE DeveloperName = :APIIntegrationName];
    }

    /**
    * @description Creates HTTPRequest with the basic information in API Integration metadata record without headers
    * @author Nitish Yadav | 03-28-2021 
    * @return HttpRequest 
    **/
    public HttpRequest getHTTPRequestWithoutHeaders(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.callout.Endpoint__c);
        request.setTimeout(Integer.valueOf(this.callout.Timeout__c));
        request.setMethod(this.callout.HTTPMethod__c);        
        return request;
    }

    /**
    * @description Creates HTTPRequest with the basic information in API Integration metadata record with headers
                   Specified in metadata record
    * @author Nitish Yadav | 03-28-2021 
    * @return HttpRequest 
    **/
    public HttpRequest getHTTPRequestWithHeaders(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.callout.Endpoint__c);
        request.setTimeout(Integer.valueOf(this.callout.Timeout__c));
        request.setMethod(this.callout.HTTPMethod__c);
        setRequestHeaders(request);
        return request;
    }

    /**
    * @description Builds the request body 
    * @author Nitish Yadav | 03-27-2021 
    * @param objectMap - Map of name used in request body and the corresponding record
    * @return Map<String,Object>
    **/
    public Map<String,Object> buildRequestBody(Map<String,SObject> objectMap){
        String requestString = this.callout.RequestBody__c;

        // Build the request map
        Map<String,Object> requestMap = new Map<String,Object>();
        for(String row : requestString.trim().split('\n')){
            String key = row.substringBefore(':').trim();
            String value = row.substringAfter(':').trim();
            System.debug('key : '+ key +', value : ' + value);
            List<String> tokens = value.split('\\.');
            if(value == 'null'){
                requestMap.put(key,null);
            }else if(value == 'true' || value == 'false'){
                requestMap.put(key,Boolean.valueOf(value));
            }else if(isNumber(value)){
                requestMap.put(key,Decimal.valueOf(value));
            }else if(Pattern.matches('DATETIME\\(.*\\)', value)){
                String dateFormat = value.substringBetween('(',')');
                requestMap.put(key, String.isBlank(dateFormat) ? DateTime.now().format() :  DateTime.now().format(dateFormat));
            }else if(value.startsWith('\"') && value.endsWith('\"')){
                requestMap.put(key,value.substringBetween('"'));
            }else if(value.contains('.') && tokens.size() == 2){
                requestMap.put(key,objectMap.get(tokens[0]).get(tokens[1]));
            }else if(value.contains('.') && tokens.size()==3){
                requestMap.put(key,objectMap.get(tokens[0]).getSObject(tokens[1]).get(tokens[2]));
            }
        }
        return requestMap;
    }

    /**
    * @description Sets the request headers for an HTTPRequest
    * @author Nitish Yadav | 03-27-2021 
    * @param request - Reference to HTTP Request for which headers are to be set
    **/
    public void setRequestHeaders(HttpRequest request){
        // Set the headers
        if(String.isNotBlank(this.callout.RequestHeaders__c)){
            for(String header : this.callout.RequestHeaders__c.trim().split('\n')){
                request.setHeader(header.substringBefore(':').trim(), header.substringAfter(':').trim());
            }
        }
    }
    
    private static Boolean isNumber(String input){
        Boolean returnValue;
        try{
            Decimal.valueOf(input);
            returnValue =  true;
        }catch(Exception ex){
            returnValue = false;
        }
        System.debug(input + ' isNumber : ' + returnValue);
        return returnValue;
    }
}