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

var guestbookItems:[GuestbookEntry] = [GuestbookEntry(name: "Bob", text:"Hello")]

func displayInfoHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let hdrs = request.headers.map { "<li>\($0.0) = \($0.1)</li>" }.joinWithSeparator(" ")
	let queryArgs = request.queryArgs.map { "<li>\($0.0) = \($0.1)</li>" }.joinWithSeparator(" ")
	let requestInfo = "Method: <b>\(request.method)</b> Path: <b>\(request.path)</b> <h2>Headers</h2><ul>\(hdrs)</ul> <h2>Query args</h2><ul>\(queryArgs)</ul>"
	return Future(immediate: HTTPResponse.OK(
		["Content-Type": "text/html"],
		content: "<html><head><title>Information</title></head><body>\(requestInfo)</body></html>"
		))
}

func rootPageHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let head = "<head><title>Guestbook</title></head>"
	let items: String
	if guestbookItems.count > 0 {
		items = "<h2>Guestbook items:</h2>" + ((guestbookItems.map { "<p class=guestbookitem><span class=\"itemtop\"><b>\($0.name)</b>says:</span><br/>\($0.text)</p>" }).joinWithSeparator(""))
	} else {
		items = "<p>The guestbook is currently empty.</p>"
	}
	let form = "<form action=\"post\"><p>Your name: <input type=text name=\"name\"/></p><p>Your message:<br/><textarea name=text cols=60 rows=4></textarea><br/><input type=\"submit\"/></form>"
	let body = "<body>\(items)\(form)</body>"
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
	Router.Get("/post",      handler:postHandler),
	Router.Get("/",          handler:rootPageHandler)
])


let server = HTTPServer(handler: router)

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
