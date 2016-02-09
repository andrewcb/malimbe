/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */

import Foundation

//#if os(Linux)
    import Glibc
    import NSLinux
//#endif

/** A basic TCP socket server; this listens on a socket and then calls a handler for 
    connections.
 */
public class TCPServer {

    private var inSocket: Socket = Socket(fd: -1)
    private var connected: Set<Socket> = []
    
    private var socketsLock = NSLock()

    private func lock(closure: ()->()) {
        self.socketsLock.lock()
        closure()
        self.socketsLock.unlock()
    }

    /** Start the server. */
    public func start(port: in_port_t) throws {
        stop()
        inSocket = try Socket(port: port)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            while let socket = try? self.inSocket.acceptConnection() {
                self.lock {
                    self.connected.insert(socket)
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    self.handleConnection(socket)
                    self.lock {
                        self.connected.remove(socket)
                    }
                })
            }
        }
    }

    /** Shut down the server. */
    public func stop() {
        self.inSocket.closeSocket()
        lock {
            for socket in self.connected {
                socket.shutDown()
            }
            self.connected.removeAll(keepCapacity: true)
        }
    }

    /** Handle an incoming connection; override in subclasses */
    public func handleConnection(socket: Socket) {
    }
}