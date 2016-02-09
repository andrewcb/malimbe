/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */


/** A class implementing a HTTP server.
This is instantiated with a chain of handlers, which it invokes to respond to requests. */

public class HTTPServer: TCPServer {

    /** A handler, or a chain of handlers calling each other, a la WSGI */
    let handler: HTTPRequestHandler

    public init(handler: HTTPRequestHandler) {
        self.handler = handler
    }

    override public func handleConnection(socket: Socket) {
        if let request = self.getHTTPRequest(socket) {
            let logLine =  "\(request.method) \(request.path)"
            print(logLine)

            let resp = self.handler.handleRequest(request)
            resp.onSuccess { try? socket.write($0) }
        }
        socket.closeSocket()
    }

    private func readHeaders(socket: Socket) throws -> [String:String] {
        var result: [String:String] = [:]
        var ln: String
        repeat {
            ln = try socket.readln() ?? ""
            let spl = ln.split(":", maxSplit: 1)
            if spl.count == 2 {
                result[spl[0].lowercaseString] = spl[1].trim { $0  != " " }
            }

        } while !ln.isEmpty
        return result
    }


    private func getHTTPRequest(socket: Socket) -> HTTPRequest? {
        guard let statusLine = try? socket.readln() else {
            return nil
        }
        do {
            let tokens = statusLine.split(" ", maxSplit: 2)
            if tokens.count < 3 {
                return nil
            }
            let hdrs = try self.readHeaders(socket)
            let content = try hdrs["content-length"].flatMap { Int($0) }.flatMap {
                try socket.readBytes($0)
            }
            return HTTPRequest(method: tokens[0], rawPath: tokens[1], headers: hdrs, content: content)
        } catch {
            // FIXME: this should probably throw
            return nil
        }

    }
}