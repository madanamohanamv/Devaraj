/*
* This class provides helper methods to test apex callouts.
*/
@IsTest
public class BPG_CalloutMockService implements HttpCalloutMock {
    //If you don't want to match by base url, then use this to map to full endpoint.
    private Boolean ignoreQuery = true;
    private Boolean returnAny = false;
    private Map<String, List<IMockResponse>> handlers = new Map<String, List<IMockResponse>>();

    public BPG_CalloutMockService addMock(String endpoint, IMockResponse mock) {
        endpoint = getEndpoint(endpoint, mock.getMethod());

        if (!handlers.containsKey(endpoint)) {
            handlers.put(endpoint, new List<IMockResponse>());
        }

        handlers.get(endpoint).add(mock);
        return this;
    }

    /*
    * If you add multiple IMockResponse objects they will return 1 at time in the order you added them.
    * This is useful when you are doing multiple callouts in a single method, but also know how many callouts are done.
    * If you don't know, then add 1 IMockResponse object and do the logic in the getResponse method.
    */
    public HttpResponse respond(HttpRequest req) {
        HttpResponse response = null;

        if (returnAny) {
            response = handlers.values().remove(0).remove(0).getResponse(req);
        } else {
            String endpoint = getEndpoint(req.getEndpoint(), req.getMethod());
            response = handlers.get(endpoint).remove(0).getResponse(req);
        }

        return response;
    }

    public BPG_CalloutMockService setIgnoreQuery(Boolean ignore) {
        ignoreQuery = ignore;
        return this;
    }

    public BPG_CalloutMockService setReturnAny(Boolean returnAny) {
        this.returnAny = returnAny;
        return this;
    }

    public BPG_CalloutMockService clear() {
        handlers.clear();
        return this;
    }

    private String getEndpoint(String endpoint, String method) {
        if (ignoreQuery) {
            endpoint = getBaseUrl(endpoint);
        }

        //Append method so same url with different methods, can get different responses.
        endpoint = endpoint + '#method#' + method;
        System.debug(endpoint);
        return endpoint;
    }

    private String getBaseUrl(String endpoint){
        Url baseUrl = new URL(endpoint);
        return baseUrl.getHost() + baseUrl.getPath();
    }

    public interface IMockResponse {
        HttpResponse getResponse(HttpRequest req);
        String getMethod();
    }
}