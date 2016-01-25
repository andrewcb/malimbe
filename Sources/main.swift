import Foundation

struct DummyHandler: HTTPRequestHandler {
	func handleRequest(request: HTTPRequest) -> Future<HTTPResponse> {
		return Future<HTTPResponse>(immediate: HTTPResponse.OK(["Content-Type": "text/plain"], content:"Hello world"))
	}
}

func itemsPageHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let items = ["foo", "bar", "baz"].map { "<li><a href=\"\($0)\">\($0)</a></li>"}.joinWithSeparator("")
	return Future(immediate: HTTPResponse.OK(
		["content/type": "text/html"],
		content: "<html><head><title>All items</title></head><body><ul>\(items)</ul></body></html>"))
}

func itemPageHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let id = args["id"] ?? ""
	return Future(immediate: HTTPResponse.OK(
		["content/type": "text/html"],
		content: "<html><head><title>Item \(id)</title></head><body><h1>Item \(id)</h1><p>Description goes here</p></body></html>"))
}

func adminPageHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	return Future(immediate: HTTPResponse.OK(["Content-Type": "text/plain"], content:"This would be the admin page"))
}

let router = Router(routes:[
	Router.Get("/items/",    handler:itemsPageHandler),
	Router.Get("/items/:id", handler:itemPageHandler),
	Router.Get("/admin/",    handler:adminPageHandler)
])

struct DummyAuthSource : AuthenticationSource {
	let passwords: [String:String]

	func isValid(username: String, password: String) -> Bool {
		return passwords[username].map { $0 == password} ?? false
	}
}

let basicAuthSource = DummyAuthSource(passwords:["admin":"thisissecret"])

let basicAuth = BasicAuthentication(realm: "Test Server", paths:["/admin"], source:basicAuthSource, next:router)

let testserver = HTTPServer(handler: basicAuth)

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