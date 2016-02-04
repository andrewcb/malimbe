public protocol AuthenticationSource {
    func isValid(username: String, password: String) -> Bool
}

/**
 HTTP Basic Authentication handler middleware. 
 - parameter paths: an array of path prefixes which are to require authentication
 - parameter source: an AuthenticationSource used to validate username/password pairs
 - parameter next: the next request handler to chain to when a request either is authenticated or does not require authentication
 */
public struct BasicAuthentication: HTTPRequestHandler {

    let realm: String
    let paths: [String]
    let source: AuthenticationSource
    let next: HTTPRequestHandler

    public init(realm:String, paths: [String], source: AuthenticationSource, next: HTTPRequestHandler) {
        self.realm = realm
        self.paths = paths
        self.source = source
        self.next = next
    }

    private func needAuthentication(request: HTTPRequest) -> Bool {
        return self.paths.contains { request.path.hasPrefix($0) }
    }

    private func haveAuthentication(request: HTTPRequest) -> Bool {
        return request.basicAuthCredentials.flatMap { self.source.isValid($0.0, password:$0.1) } ?? false
    }

    public func handleRequest(request: HTTPRequest) -> Future<HTTPResponse> {
        if self.needAuthentication(request) && !self.haveAuthentication(request) {
            // 403 it -- FIXME
            return Future<HTTPResponse>(immediate: HTTPResponse.NotAuthorized([
                "Content-Type": "text/plain",
                "WWW-Authenticate": "Basic realm=\"\(self.realm)\""
                ], content:"Hello world"))
        } else {
            return self.next.handleRequest(request)
        }
    }
}

extension HTTPRequest {
    var basicAuthCredentials: (String, String)? {
        return (headers["authorization"]?.splitExactly(" ", numSplit:1)).flatMap {
            ($0[0] == "Basic") ? (String(base64:$0[1])?.splitExactly(":", numSplit:1)).map { ($0[0], $0[1]) } : nil
        }
    }
}

