/*
* This class provides a mechanism to call the Salesforce Tooling API Rest service.
* Currently supports the query api and parsing responses from it.
*/
public class BPG_ToolingApiService {
    private static final String API_VERSION = 'v44.0';
    private static final String BASE_URL = '/services/data/{!API_VERSION}/tooling';

    private String apiVersion;
    private String sessionId;

    public BPG_ToolingApiService() {}

    public BPG_ToolingApiService setApiVersion(String version) {
        this.apiVersion = version;
        return this;
    }

    /*
    * Might need to pass in sessionId if calling from Aura.
    * Use Page.BPG_SessionId.getContent() to get valid sessionId.
    */
    public BPG_ToolingApiService setSessionId(String sessionId) {
        this.sessionId = sessionId;
        return this;
    }

    /*
    * Call the query api.
    * @param query - the soql query
    */
    public HttpResponse query(String query) {
        return callout('/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'), 'GET', null);
    }

    /*
    * Main method to do the api callout, the idea is to expose other methods that call this
    * method to do heavy lifting, like the query method.
    */
    @TestVisible
    private HttpResponse callout(String path, String method, String json) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();

        String url = URL.getSalesforceBaseUrl().toExternalForm() + BASE_URL.replace('{!API_VERSION}', String.isNotBlank(apiVersion) ? apiVersion : API_VERSION) + path;
        System.debug(url);

        req.setEndpoint(url);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + (String.isNotBlank(sessionId) ? sessionId : UserInfo.getSessionId()));

        if (String.isNotBlank(json)) {
            req.setBody(json);
        }

        HttpResponse res = http.send(req);
        System.debug(res.getBody());

        if (!String.valueOf(res.getStatusCode()).startsWith('2')) {
            throw new ApiException(res);
        }

        return res;
    }

    /*
    * Plucks the records from the json query response and parses to a particular apex type.
    * @param classType - the apex type this result/records should be converted to
    * @param json - the query response
    */
    public Object getRecords(Type classType, String json) {
         Map<String, Object> data = (Map<String, Object>)System.JSON.deserializeUntyped(json);
         return System.JSON.deserialize(System.JSON.serialize(data.get('records')), classType);
    }

    /*
    * List of array messages are returned when an error occurs. This class provides a way to parse them.
    */
    public class ApiException extends Exception {

        public ApiException(HttpResponse res) {
            String message = 'Status Code: ' + res.getStatusCode() + ' \nStatus: ' + res.getStatus();

            if (String.isNotBlank(res.getBody())
                    && res.getBody().containsIgnoreCase('message')) {

                //Grab the json array of messages.
                List<Object> messages = (List<Object>)System.JSON.deserializeUntyped(res.getBody());

                for (Object item :messages) {
                    message += '\n' + ((Map<String, Object>)item).get('message');
                }
            }

            setMessage(message);
        }
    }
}