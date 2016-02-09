/*
 A simple web guestbook, arguably the “Hello World” of web apps.
 This version stores the data in memory and does not persist it. 
*/

import Foundation
import malimbe

struct GuestbookEntry {
	let name: String
	let text: String
}

extension GuestbookEntry : HTMLRenderable {
	var asHTML: String  {
		return [
			HTMLTag.DIV([
				HTMLTag.SPAN(HTMLTag.B(self.name), "says:", class:"itemtop"),
				HTMLTag.DIV(self.text, class:"itembody")
			], class:"guestbookitem")
		].asHTML
	}
}

var guestbookItems:[GuestbookEntry] = [
	//GuestbookEntry(name: "Bob", text:"Hello")
]

func rootPageHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let items: [HTMLRenderable]
	if guestbookItems.count > 0 {
		items = [HTMLTag.H2("Guestbook items:")] + guestbookItems.map { $0 as HTMLRenderable }
	} else {
		items = [HTMLTag.P("The guestbook is currently empty.")]
	}
	let content = HTMLTag.HTML(
		HTMLTag.HEAD(HTMLTag.TITLE("Guestbook"), HTMLTag.LINK(rel:"StyleSheet", href:"/static/style.css", type:"text/css", media:"screen")),
		HTMLTag.BODY(
			items, 
			HTMLTag.FORM(
	 			HTMLTag.P("Your name:", HTMLTag.INPUT(type:"text", name:"name")),
	 			HTMLTag.P("Your message:", HTMLTag.BR(), HTMLTag.TEXTAREA( name:"text", cols:60, rows:4)),
	 			HTMLTag.INPUT(type:"submit"), 
	 		action:"post", method:"POST")
		)
	)
	return Future(immediate: HTTPResponse.OK(["Content-Type": "text/html"], 
		content:content)
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
