public class HTTPServer: TCPServer {

    /** A handler, or a chain of handlers calling each other, a la WSGI */
	let handler: HTTPRequestHandler

	init(handler: HTTPRequestHandler) {
		self.handler = handler
	}

	override public func handleConnection(socket: Socket) {
		if let request = self.getHTTPRequest(socket) {
			let logLine =  "\(request.method) \(request.path)"
			print(logLine)

			let resp = self.handler.handleRequest(request)
			resp.onSuccess { try? socket.write($0) }

			//let response = HTTPResponse(code: HTTPResponse.Code.OK, headers: ["Content-Type": "text/plain"], content:"Hello world")
			//try? socket.write(response)
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


	func getHTTPRequest(socket: Socket) -> HTTPRequest? {
		guard let statusLine = try? socket.readln() else {
			return nil
		}
		do {
			let tokens = statusLine.split(" ", maxSplit: 2)
			if tokens.count < 3 {
				return nil
			}
			let hdrs = try self.readHeaders(socket)
			return HTTPRequest(method: tokens[0], rawPath: tokens[1], headers: hdrs)
		} catch {
			return nil
		}

	}
}