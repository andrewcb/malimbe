public class TestServer: TCPServer {

	override public func handleConnection(socket: Socket) {
		print("handleConnection: \(socket)")
		if let line = try? socket.readln() {
			print("line = \(line)")
			try? socket.write("You said: \(line)\r\n")
		}
	}
}

