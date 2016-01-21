

struct HTTPRequest {
	let method: String
	let path: String
	let headers: [String:String]
	var routingVars: [String:String]?

	init(method: String, rawPath: String, headers: [String:String]) {
		self.method = method
		self.path = rawPath  // TODO: split query string
		self.headers = headers
	}
}