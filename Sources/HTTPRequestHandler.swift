protocol HTTPRequestHandler {
	func handleRequest(request: HTTPRequest) -> Future<HTTPResponse>
}