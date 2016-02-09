/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */


/**
HTTPRequestHandler: the protocol that request handlers have to implement. 
This does not take into account any form of chaining (that is left 
for the request handlers to implement at initialisation and call 
time) or routing (which is a higher-level mechanism).
*/

public protocol HTTPRequestHandler {
    /** Handle a HTTP request asynchronously, returning the response in a Future. */
    func handleRequest(request: HTTPRequest) -> Future<HTTPResponse>
}