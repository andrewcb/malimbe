/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */


/**
 A HTTPRequestHandler that handles requests for a specific path and 
 displays the request's details in HTML form, for debugging purposes.
*/
public struct HTTPRequestDebugDumpHandler : HTTPRequestHandler {
    let path: String
    let next: HTTPRequestHandler

    /**
    parameter path: The path for which this handler is to provide responses
    parameter next: The handler to invoke for requests for other paths
    */

    public init(path: String, next: HTTPRequestHandler) {
        self.path = path
        self.next = next
    }

    public func handleRequest(request: HTTPRequest) -> Future<HTTPResponse> {
        if request.path == self.path {
            return Future(immediate: HTTPResponse.OK(
                ["Content-Type": "text/html"], 
                content: HTMLTag.HTML(
                    HTMLTag.HEAD(HTMLTag.TITLE("Request Information")),
                    HTMLTag.BODY(
                        HTMLTag.H2("Basic information:"),
                        HTMLTag.P("Method:", HTMLTag.B(request.method)),
                        HTMLTag.P("Path:", HTMLTag.B(request.path)),

                        HTMLTag.H2("Headers"),
                        HTMLTag.UL(
                            request.headers.map { HTMLTag.LI("\($0.0) = \($0.1)") as HTMLRenderable }
                        ),

                        HTMLTag.H2("Query args"),
                        HTMLTag.UL(
                            request.queryArgs.map { HTMLTag.LI("\($0.0) = \($0.1)") as HTMLRenderable }
                        ),

                        HTMLTag.H2("Request body"),
                        request.contentUTF8 ?? ""
                    )
                )
            ))
        } else {
            return next.handleRequest(request)
        }
    }
}