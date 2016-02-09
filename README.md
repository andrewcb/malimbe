# Malimbe: a simple asynchronous server-side web framework for Swift on Linux

Malimbe is (an early sketch of a) server-side web framework written in Swift. Its features are as follows:

- Malimbe uses an implementation of [Futures](https://en.wikipedia.org/wiki/Futures_and_promises) for concurrency. Request handlers immediately return a Future of a HTTP Request. The Future is an opaque reference to a computation (which may or may not be complete) which will return the desired result.  The computations execute in parallel threads.  Futures are opaque containers which may be mapped and flatMapped over. (Malimbe's Futures implementation is somewhat inspired by the Futures in [Scala](http://scala-lang.org).)


- The Malimbe request handling mechanism takes the form of a chain of request handlers (also sometimes referred to as middleware); each handler has the option of generating and returning a response itself or passing the request on to the next handler. (The exception is the `Router` handler, which is always at the end of the chain, and routes requests to its own handling functions.)

- Malimbe has basic HTML generation features; the `HTMLRenderable` protocol should be used for objects which can generate a HTML representation of themselves. There is a `HTMLTag` type (matching this protocol), which may be used to programmatically generate HTML documents. `String`s are extended to be `HTMLRenderable`, though for reasons of safety, they are always quoted, with HTML tags escaped; to emit HTML in a string form, use the `HTMLLiteral` type.

## Built-in HTTP Request Handlers

The following HTTP request handler types are provided:

- **BasicAuthentication**: An implementation of HTTP Basic Authentication. This defines the `AuthenticationSource` protocol. To use this request handler, define an implementation of this protocol and pass it when instantiating `BasicAuthentication`.

- **Router**: A request handler that routes requests by matching path to any of a number
    of subhandlers (each taking the form of a function). `Router` performs pattern matching on paths, and can extract arguments and pass them on to request handlers; for example, a page which looks up an item by its ID may be defined as such:

```
func itemPageHandler(request: HTTPRequest, args:[String:String]) -> Future<HTTPResponse> {
	let id = args["id"] ?? ""
	// generate the item page here
} 

let router = Router(routes:[
    // ...
	Router.Get("/items/:id", handler:itemPageHandler),
])

```

- ***StaticFileRequestHandler**: This can serve static files from a directory (or tree of directories) under a path on the server. 

## Building instructions

Malimbe builds on Ubuntu using the Swift 2.2 2016-01-06 snapshot. To build the framework, enter the Malimbe directory and (with the Swift executable in your path), type 
```
swift build
```

To build the example applications, enter the `Examples` subdirectory and type `make`.  This will produce executables in the local directory, which may be run from the command line, i.e., `./guestbook`. 

## Example applications

The Examples directory contains a few very simple example applications which don't depend on any Swift packages other than Malimbe. These are:

- **testserver1**: a "Hello World"-type application, demonstrating routing and basic authentication.

- **guestbook**: an implementation of a simple web guestbook. This uses the static file handler to serve a CSS stylesheet. Guestbook items are currently stored in memory and are not persistent.

## Current shortcomings

Malimbe is currently not production-grade software; there is, at the time of writing, not yet a production-grade implementation of `libdispatch` (a.k.a. Grand Central Dispatch) on Linux. Malimbe uses the NSLinux shim library which fakes `libdispatch`, spawning a thread for each block. This is good enough for small test-bed applications, but is not likely to be optimally performant.

In addition, Malimbe is a somewhat minimal framework, and does not provide a number of components typically required for back-end development; these include:

- A template rendering system of some sort. One idea might be a templating system that allows arbitrary Swift code to be embedded in templates; because of Swift being a compiled language, the templates would be converted to machine-generated Swift source files in the build process. (A similar system is used in [the Scala Play framework](https://www.playframework.com).)  A simpler (though arguably less performant) alternative would be a runtime system implemented in Swift and providing a subset of functionality (such as if/then, iteration and inclusion of blocks).

- Libraries for connecting to databases (PostgreSQL/MySQL/MongoDB/SQLite); either in an ORM or ActiveRecord form or using raw SQL. (It would be nice if these were asynchronous, themselves returning Futures, though synchronous ones could be made asynchronous by being executed in closures.)

- Client libraries for using web APIs (also ideally asynchronously).

- More request handler middleware, from simple things (i.e., a client-side cookie-based session store) to more complex systems (i.e., flexible identity frameworks).


## Author

Malimbe was written by [Andrew Bulhak](http://dev.null.org/acb/). Its repository is at https://github.com/andrewcb/malimbe/.

## The name

A malimbe is one of a number of species of weaver birds indigenous to Africa, and hence an apt name for a web framework in Swift.