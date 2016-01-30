public struct HTTPResponse {
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

	let code: Code
	var headers: [String:String]
	let content: [UInt8]

	init(code: Code, headers: [String:String], content: [UInt8]) {
		self.code = code
		self.headers = headers
		self.content = content
		self.headers["Content-Length"] = "\(content.count)"
	}

	init(code: Code, headers: [String:String], content: String) {
		self.code = code
		self.headers = headers
		// TODO: update encoding
		self.content = [UInt8](content.utf8)
		self.headers["Content-Length"] = "\(self.content.count)"
	}

	public static func OK(headers: [String:String], content:String) -> HTTPResponse { return HTTPResponse(code:Code.OK, headers:headers, content:content)}
	public static func NotAuthorized(headers: [String:String], content:String) -> HTTPResponse { return HTTPResponse(code:Code.NotAuthorized, headers:headers, content:content)}
	public static func Forbidden(headers: [String:String], content:String) -> HTTPResponse { return HTTPResponse(code:Code.Forbidden, headers:headers, content:content)}
	public static func NotFound(headers: [String:String], content:String) -> HTTPResponse { return HTTPResponse(code:Code.NotFound, headers:headers, content:content)}

}

extension Socket {
	public func write(response: HTTPResponse) throws {
		try self.write("HTTP/1.1 \(response.code.rawValue)\r\n")
		for (k,v) in response.headers {
			try self.write("\(k): \(v)\r\n")
		}
		try self.write("\r\n")
		try self.write(response.content)
	}
}