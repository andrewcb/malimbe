import Foundation

struct RoutingPath {
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


struct Router: HTTPRequestHandler {
	struct Route {
		enum Method : String {
			case Get = "GET"
			case Post = "POST"
			case Put = "PUT"
			case Delete = "DELETE"
		}

		typealias Handler = (HTTPRequest, [String:String]) -> Future<HTTPResponse>

		let method: Method
		let path: RoutingPath
		let handler: Handler

		init(method:Method, path:String, handler:Handler) {
			self.method = method
			self.path = RoutingPath(path:path)
			self.handler = handler
		}

		// returns a (possibly empty) dictionary if matches, nil if not
		func matches(request: HTTPRequest) -> [String:String]? {
			return (method.rawValue == request.method) ? path.match(request.path) : nil
		}
	}

	static func Get(path:String, handler:Route.Handler) -> Route {return Route(method:.Get, path:path, handler:handler)}
	static func Post(path:String, handler:Route.Handler) -> Route {return Route(method:.Post, path:path, handler:handler)}
	static func Put(path:String, handler:Route.Handler) -> Route {return Route(method:.Put, path:path, handler:handler)}
	static func Delete(path:String, handler:Route.Handler) -> Route {return Route(method:.Delete, path:path, handler:handler)}

	let routes: [Route]

	init(routes: [Route]) {
		self.routes = routes
	}

	func handleRequest(request: HTTPRequest) -> Future<HTTPResponse> {
		for route in routes {
			if let m = route.matches(request) {
				return route.handler(request, m)
			}
		}
		return Future<HTTPResponse>(immediate: HTTPResponse(code: HTTPResponse.Code.NotFound, headers: ["Content-Type": "text/plain"], content:"404 Not Found"))
	}
}