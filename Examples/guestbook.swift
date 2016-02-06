/*
 A simple web guestbook, arguably the “Hello World” of web apps.
 This version stores the data in memory and does not persist it. 
*/

import Foundation
import aserver

struct GuestbookEntry {
	let name: String
	let text: String
}

extension GuestbookEntry : HTMLRenderable {
	var asHTML: String  {
		let topLine: [HTMLRenderable] = [HTMLTag.B(self.name), "says:"]
		return [
			HTMLTag.DIV([
				HTMLTag.SPAN([topLine], class:"itemtop"),
				HTMLTag.DIV(self.text, class:"itembody")
			], class:"guestbookitem")
		].asHTML
	}
}

var guestbookItems:[GuestbookEntry] = [GuestbookEntry(name: "Bob", text:"Hello")]

func displayInfoHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let hdrs = request.headers.map { "<li>\($0.0) = \($0.1)</li>" }.joinWithSeparator(" ")
	let queryArgs = request.queryArgs.map { "<li>\($0.0) = \($0.1)</li>" }.joinWithSeparator(" ")
	let requestInfo = "Method: <b>\(request.method)</b> Path: <b>\(request.path)</b> <h2>Headers</h2><ul>\(hdrs)</ul><h2>Request body</h2><tt>\(request.contentUTF8)</tt> <h2>Query args</h2><ul>\(queryArgs)</ul>"
	return Future(immediate: HTTPResponse.OK(
		["Content-Type": "text/html"],
		content: "<html><head><title>Information</title></head><body>\(requestInfo)</body></html>"
		))
}

func rootPageHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let head = "<head><title>Guestbook</title><link rel=\"StyleSheet\" href=\"/static/style.css\" type=\"text/css\" media=\"screen\"/></head>"
	//let items: String
	let items: [HTMLRenderable]
	if guestbookItems.count > 0 {
		items = [HTMLTag.H2("Guestbook items:")] + guestbookItems.map { $0 as HTMLRenderable }
	} else {
		items = [HTMLTag.P("The guestbook is currently empty.")]
	}
	//  Swift's type inference currently doesn't allow array literals to be automatically matched to protocol extensions
	// let form: HTMLRenderable = HTMLTag.FORM([HTMLRenderable]([
	// 	HTMLTag.P([HTMLRenderable](arrayLiteral:["Your name:", HTMLTag.INPUT(type:"text", name:"name")])),
	// 	HTMLTag.P([HTMLRenderable](["Your message:", HTMLTag.BR(), HTMLTag.TEXTAREA([], name:"text", cols:60, rows:4)])),
	// 	HTMLTag.INPUT(type:"submit")
	// ]), action:"post", method:"POST")
	let form = "<form action=\"post\" method=POST><p>Your name: <input type=text name=\"name\"/></p><p>Your message:<br/><textarea name=text cols=60 rows=4></textarea><br/><input type=\"submit\"/></form>"
	let body = "<body>\(items.asHTML)\(form)</body>"
	return Future(immediate: HTTPResponse.OK(["Content-Type": "text/html"], 
		content:"<html>\(head)\(body)</html>")
	)
}

func postHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	if let name = request.queryArgs["name"], text = request.queryArgs["text"] {
		guestbookItems.append(GuestbookEntry(name:name, text:text))
	}
	return Future(immediate: HTTPResponse.Redirect("/"))
}

let router = Router(routes:[
	Router.Post("/post",     handler:postHandler),
	Router.Get("/post",      handler:postHandler),
	Router.Get("/",          handler:rootPageHandler)
])

let staticFiles = StaticFileRequestHandler(pathPrefix: "/static/", staticDir:appRelativePath("GuestbookStatic/"), next:router )

let server = HTTPServer(handler: staticFiles)

print("starting...")
do {
	try server.start(9999)
	print("started on 9999")

	while(true) {
		NSRunLoop.mainRunLoop().runUntilDate(NSDate.distantFuture())
	}
} catch {
	print("error: \(error)")
}
