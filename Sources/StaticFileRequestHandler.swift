/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */


/**  Middleware to serve static files from under a specific directory to under a specific path.
*/

public struct StaticFileRequestHandler : HTTPRequestHandler {
    let pathPrefix: String
    let staticDir: String
    let next: HTTPRequestHandler

    /**
    - parameter pathPrefix: The prefix of paths on incoming HTTP requests which are to be served as static files
    - parameter staticDir:  The local directory from which files are to be served.
    - parameter next: The handler to invoke for requests not matching pathPrefix
    */
    public init(pathPrefix: String, staticDir: String, next: HTTPRequestHandler) {
        self.pathPrefix = pathPrefix
        self.staticDir = staticDir
        self.next = next
    }

    public func handleRequest(request: HTTPRequest) -> Future<HTTPResponse> {
        if let remainder =  request.path.remainderFromPrefix(self.pathPrefix) {
            let filePath = self.staticDir + remainder
            let contentType = contentTypeForName(request.path)
            if let response = HTTPResponse(code: HTTPResponse.Code.OK, headers:["Content-Type": contentType], filePath:filePath) {
                return Future(immediate: response)
            } else {
                return Future(immediate: HTTPResponse.NotFound(["Content-Type": "text/plain"], content:"Not found"))
            }
        } else {
            return next.handleRequest(request)
        }
    }
}