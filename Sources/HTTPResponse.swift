/* The actual content a HTTPResponse can send is abstracted into a protocol. 
This allows, say, large disk files to be handled efficiently (without being 
sucked into RAM in their entirety) */

import Glibc

/** A protocol abstracting the source of content for a HTTPResponse. This is to allow 
responses to efficiently return content too large to read into memory in its entirety. */
protocol HTTPResponseContentSource {
    var byteCount: Int { get }
    func writeToSocket(socket: Socket) throws
}

struct InMemoryContentSource: HTTPResponseContentSource {
    let content: [UInt8]
    let byteCount: Int
    init(content: [UInt8]) {
        self.content = content
        self.byteCount = content.count
    }

    func writeToSocket(socket: Socket) throws {
        try socket.write(self.content)
    }
}

/// Represents content in a file on disk; this is read and sent incrementally, 
/// and does not need to be stored in RAM in its entirety.
struct LocalFileContentSource: HTTPResponseContentSource {
    var byteCount: Int
    var path: String

    public struct ReadError: ErrorType { }

    init?(path:String) {
        var stb = stat()
        if stat(path, &stb) != 0 { return nil }
        self.byteCount = stb.st_size
        self.path = path
    }

    func writeToSocket(socket: Socket) throws {
        let fd = open(self.path, O_RDONLY)
        guard (fd >= 0) else { throw ReadError() }
        defer { close(fd) }
        var remaining = self.byteCount
        let bufsize = 16384

        func copyBytes(count: Int) throws {
            var buf = [UInt8](count: count, repeatedValue: 0)
            if (read(fd, &buf, count) < count) { throw ReadError() }
            try socket.write(buf)
        }
        
        while remaining > bufsize {
            try copyBytes(bufsize)
            remaining -= bufsize
        }
        if remaining > 0 {
            try copyBytes(remaining)
        }
    }
}

/** A structure embodying a HTTP response; this is returned (in a Future) by request handlers. */
public struct HTTPResponse {
    /// HTTP status codes
    enum Code: Int {
        case OK = 200
        case Created = 201
        case Accepted = 202
        case NonAuthoritative = 203
        case NoContent = 204
        case ResetContent = 205
        case PartialContent = 206

        case MovedPermanently = 301
        case Found = 302
        case SeeOther = 303
        case TemporaryRedirect = 307
        case PermanentRedirect = 308

        case BadRequest = 400
        case NotAuthorized = 401
        case PaymentRequired = 402
        case Forbidden = 403
        case NotFound = 404
        case MethodNotAllowed = 405
        case NotAcceptable = 406
        case Timeout = 408
        case ImATeapot = 418
        case Censored = 451

        case InternalError = 500
        case NotImplemented = 501
        case BadGateway = 502
        case ServiceUnavailable = 503
    }
    /// The HTTP status code.
    let code: Code
    /// The HTTP headers
    var headers: [String:String]
    /** A source for the content of the Response. */
    let content: HTTPResponseContentSource

    init(code: Code, headers: [String:String], content: HTTPResponseContentSource) {
        self.code = code
        self.headers = headers
        self.content = content
        self.headers["Content-Length"] = "\(content.byteCount)"
    }

    init(code: Code, headers: [String:String], content: [UInt8]) {
        self.init(code: code, headers:headers, content: InMemoryContentSource(content:content))
    }

    init(code: Code, headers: [String:String], content: String) {
        self.init(code: code, headers:headers, content: InMemoryContentSource(content:[UInt8](content.utf8)))

        // TODO: update encoding
    }
    init(code: Code, headers: [String:String], content: HTMLRenderable) {
        self.init(code: code, headers: headers, content: content.asHTML)
    }

    init?(code: Code, headers: [String:String], filePath: String) {
        if let src = LocalFileContentSource(path:filePath)  { 
            self.init(code: code, headers: headers, content: src)
        } else {
            return nil
        }
    }

    // Utility functions to quickly create common responses
    public static func OK(headers: [String:String], content:String) -> HTTPResponse { return HTTPResponse(code:Code.OK, headers:headers, content:content)}
    public static func OK(headers: [String:String], content:HTMLRenderable) -> HTTPResponse { return HTTPResponse(code:Code.OK, headers:headers, content:content)}
    public static func NotAuthorized(headers: [String:String], content:String) -> HTTPResponse { return HTTPResponse(code:Code.NotAuthorized, headers:headers, content:content)}
    public static func NotAuthorized(headers: [String:String], content:HTMLRenderable) -> HTTPResponse { return HTTPResponse(code:Code.NotAuthorized, headers:headers, content:content)}
    public static func Forbidden(headers: [String:String], content:String) -> HTTPResponse { return HTTPResponse(code:Code.Forbidden, headers:headers, content:content)}
    public static func Forbidden(headers: [String:String], content:HTMLRenderable) -> HTTPResponse { return HTTPResponse(code:Code.Forbidden, headers:headers, content:content)}
    public static func NotFound(headers: [String:String], content:String) -> HTTPResponse { return HTTPResponse(code:Code.NotFound, headers:headers, content:content)}
    public static func NotFound(headers: [String:String], content:HTMLRenderable) -> HTTPResponse { return HTTPResponse(code:Code.NotFound, headers:headers, content:content)}
    public static func Redirect(url: String) -> HTTPResponse { return HTTPResponse(code:Code.SeeOther, headers:["Location": url], content:"")}
}

extension Socket {
    public func write(response: HTTPResponse) throws {
        try self.write("HTTP/1.1 \(response.code.rawValue)\r\n")
        for (k,v) in response.headers {
            try self.write("\(k): \(v)\r\n")
        }
        try self.write("\r\n")
        try response.content.writeToSocket(self)
    }
}