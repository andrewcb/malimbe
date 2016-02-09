/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */

 /* The path routing system. This consists of the Router request handler, and the RoutingPath structure. */

import Foundation

public struct RoutingPath {
    enum Segment {
        // a literal piece of text between /s to match
        case Literal(text: String)
        // a variable belonging between a single pair of /s, i.e., /:item/
        case SingleVar(name: String)
        // a variable matching a path, consuming one or more segments; i.e., /*page
        case PathVar(name: String)

        init(segment: String) {
            if segment.characters.first == ":" {
                self = .SingleVar(name:String(segment.characters.dropFirst()))
            } else if segment.characters.first == "*" {
                self = .PathVar(name:String(segment.characters.dropFirst()))
            } else {
                self = .Literal(text:segment)
            }
        }

        func match(segments: ArraySlice<String> ) -> ((String, String)?, ArraySlice<String>)? {
            switch(self) {
                case .Literal(let text): if segments.first == text {
                    return (nil, segments.dropFirst())
                }
                case .SingleVar(let name): if let seg = segments.first where !seg.isEmpty {
                    return ((name, seg), segments.dropFirst())
                }
                case .PathVar(let name): if !segments.isEmpty {
                    let joined = segments.joinWithSeparator("/")
                    if !joined.isEmpty {
                        return ((name, joined), segments.suffix(0))
                    }
                }

            }
            return nil
        }
    }

    let segments: [Segment]
    
    init(path:String) {
        self.segments = path.componentsSeparatedByString("/").map { Segment(segment:$0) }
    }

    func match(path: String) -> [String:String]? {
        var psegs = path.componentsSeparatedByString("/").dropFirst(0)
        var defs: [String:String] = [:]
        for segment in self.segments {
            if let (definition, remainder) = segment.match(psegs) {
                if let (k, v) = definition {
                    defs[k] = v
                }
                psegs = remainder
            } else {
                return nil
            }
        }
        if psegs.isEmpty { 
            return defs
        } else {
            return nil
        }
    }
}

/** A request handler that routes requests by matching path to any of a number
    of subhandlers (each taking the form of a function). Router also allows for
    placeholders in the path templates to be turned into keyword variable values, 
    which are passed in to the respective handler in a dictionary. 
    These placeholders start with a colon; i.e., 
    ``` /articles/:id/
    ```

    Router is at the end of the HTTPRequestHandler chain, and has no next 
    HTTPRequestHandler; all progress downstream is through its own request handlers.
*/

public struct Router: HTTPRequestHandler {
    /** A structure holding a single route specification to match against, 
    along with its handler. */
    public struct Route {
        public enum Method : String {
            case Get = "GET"
            case Post = "POST"
            case Put = "PUT"
            case Delete = "DELETE"
        }

        public typealias Handler = (HTTPRequest, [String:String]) -> Future<HTTPResponse>

        public let method: Method
        public let path: RoutingPath
        public let handler: Handler

        public init(method:Method, path:String, handler:Handler) {
            self.method = method
            self.path = RoutingPath(path:path)
            self.handler = handler
        }

        // returns a (possibly empty) dictionary if matches, nil if not
        func matches(request: HTTPRequest) -> [String:String]? {
            return (method.rawValue == request.method) ? path.match(request.path) : nil
        }
    }

    /* Utility functions creating route specifications */
    public static func Get(path:String, handler:Route.Handler) -> Route {return Route(method:.Get, path:path, handler:handler)}
    public static func Post(path:String, handler:Route.Handler) -> Route {return Route(method:.Post, path:path, handler:handler)}
    public static func Put(path:String, handler:Route.Handler) -> Route {return Route(method:.Put, path:path, handler:handler)}
    public static func Delete(path:String, handler:Route.Handler) -> Route {return Route(method:.Delete, path:path, handler:handler)}

    let routes: [Route]

    public init(routes: [Route]) {
        self.routes = routes
    }

    public func handleRequest(request: HTTPRequest) -> Future<HTTPResponse> {
        for route in routes {
            if let m = route.matches(request) {
                return route.handler(request, m)
            }
        }
        return Future(immediate: HTTPResponse.NotFound(["Content-Type": "text/plain"], content:"404 Not Found"))
    }
}