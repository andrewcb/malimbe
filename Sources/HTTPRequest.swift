

public struct HTTPRequest {
	public let method: String
	public let path: String
	public let headers: [String:String]
	public let content: [UInt8]?
	public let getArgs: [String:String]

	init(method: String, rawPath: String, headers: [String:String], content:[UInt8]?) {
		self.method = method
		self.headers = headers
		self.content = content

		let splitpath = rawPath.split("?", maxSplit:1)
		self.path = splitpath[0]
		if splitpath.count > 1 {
			let argtuples = splitpath[1].split("&", maxSplit: Int.max).map { $0.split("=", maxSplit:1) }.flatMap { 
				($0.count > 1 ) ? ($0[0].urldecode(), $0[1].urldecode()) : nil
			}
			self.getArgs = [String:String](argtuples)
		} else {
			self.getArgs = [:]
		}
	}

	public var contentUTF8:String? { return self.content.flatMap { String.fromCString(UnsafePointer($0)) } }

	public var postArgs: [String:String]? {
		if self.headers["content-type"] == "application/x-www-form-urlencoded" {
			return self.contentUTF8?.decodeQueryString()
		}
		return nil
	}

	public var queryArgs: [String:String] {
		return self.postArgs ?? self.getArgs
	}
}