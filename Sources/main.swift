//import NSLinux
import Foundation

struct DummyHandler: HTTPRequestHandler {
	func handleRequest(request: HTTPRequest) -> Future<HTTPResponse> {
		return Future<HTTPResponse>(immediate: HTTPResponse(code: HTTPResponse.Code.OK, headers: ["Content-Type": "text/plain"], content:"Hello world"))
	}
}

func itemsPageHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let items = ["foo", "bar", "baz"].map { "<li><a href=\"\($0)\">\($0)</a></li>"}.joinWithSeparator("")
	return Future<HTTPResponse>(immediate: HTTPResponse(
		code: HTTPResponse.Code.OK, 
		headers: ["content/type": "text/html"],
		content: "<html><head><title>All items</title></head><body><ul>\(items)</ul></body></html>"))
}

func itemPageHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let id = args["id"] ?? ""
	return Future<HTTPResponse>(immediate: HTTPResponse(
		code: HTTPResponse.Code.OK, 
		headers: ["content/type": "text/html"],
		content: "<html><head><title>Item \(id)</title></head><body><h1>Item \(id)</h1><p>Description goes here</p></body></html>"))
}

let router = Router(routes:[
	Router.Get("/items/",    handler:itemsPageHandler),
	Router.Get("/items/:id", handler:itemPageHandler),
])

let testserver = HTTPServer(handler: router)

print("starting...")
do {
	try testserver.start(9999)
	print("started on 9999")

	while(true) {
		NSRunLoop.mainRunLoop().runUntilDate(NSDate.distantFuture())
	}
} catch {
	print("error: \(error)")
}