
/**
A structure representing an incoming HTTP request. This is what request handlers see.
*/
public struct HTTPRequest {
    /// The HTTP method; typically GET, POST, PUT or DELETE, though left open for expansion
    public let method: String
    /// The request path, minus any GET query arguments
    public let path: String
    /// The incoming HTTP headers; keys are lowercased.
    public let headers: [String:String]
    /// Optional content (i.e., in a POST or PUT) sent with the request
    public let content: [UInt8]?
    /// The GET form arguments, if present
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

    /// The content as a UTF-8 string, if present and decodable.
    public var contentUTF8:String? { return self.content.flatMap { String.fromCString(UnsafePointer($0)) } }

    public var postArgs: [String:String]? {
        if self.headers["content-type"] == "application/x-www-form-urlencoded" {
            return self.contentUTF8?.decodeQueryString()
        }
        return nil
    }

    /// Any form query arguments, which may be POSTed in the body or appended to the path of a GET
    public var queryArgs: [String:String] {
        return self.postArgs ?? self.getArgs
    }
}