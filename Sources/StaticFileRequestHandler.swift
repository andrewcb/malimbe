public struct StaticFileRequestHandler : HTTPRequestHandler {
	let pathPrefix: String
	let staticDir: String
	let next: HTTPRequestHandler

	public init(pathPrefix: String, staticDir: String, next: HTTPRequestHandler) {
		self.pathPrefix = pathPrefix
		self.staticDir = staticDir
		self.next = next
	}
	public func handleRequest(request: HTTPRequest) -> Future<HTTPResponse> {
		if let remainder =  request.path.remainderFromPrefix(self.pathPrefix) {
			let filePath = self.staticDir + remainder
			let contentType = contentTypeForName(request.path)
			print("contentTypeForName(\(request.path)) -> \(contentType)")
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