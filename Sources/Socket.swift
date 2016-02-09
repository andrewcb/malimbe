/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */

#if os(Linux)
    import Glibc
#else
    import Foundation
#endif

/**
A Swift wrapper for a POSIX socket.
*/
public struct Socket : Equatable, Hashable {
    private let fd: Int32

    enum Error: ErrorType {
        case CreationFailed
        case SetoptFailed
        case BindFailed
        case ListenFailed
        case AcceptFailed
        case ReadFailed
        case WriteFailed
    }

    init(fd: Int32) {
        self.fd = fd
    }

    /** Create a socket listening for connections on a port
       - parameter port: the port to listen on
    */
    init(port: in_port_t) throws {
        #if os(Linux)
            let fd = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
        #else
            let fd = socket(AF_INET, SOCK_STREAM, 0)
        #endif
          
        if fd == -1 {
            throw Error.CreationFailed
        }

        self.fd = fd

        try self.setopt(SO_REUSEADDR, val: 1)

        var addr_in = sockaddr_in()
        addr_in.sin_family = sa_family_t(AF_INET)
        addr_in.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        #if os(Linux)   
            addr_in.sin_addr = in_addr(s_addr: in_addr_t(0))
            addr_in.sin_port = htons(port)
        #else
            addr_in.sin_port = (Int(OSHostByteOrder()) == OSLittleEndian) ? _OSSwapInt16(port) : port
            addr_in.sin_len = __uint8_t(sizeof(sockaddr_in))
            addr_in.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
        #endif

        let bindresult = withUnsafePointer(&addr_in) { 
            bind(fd, UnsafePointer($0), socklen_t(sizeof(sockaddr_in)))
        }

        if bindresult == -1 {
            throw Error.BindFailed
        }

        if listen(fd, SOMAXCONN) == -1 {
            throw Error.ListenFailed
        }
    }

    public func acceptConnection() throws -> Socket {
        var addr = sockaddr()        
        var len: socklen_t = 0
        let cfd = accept(self.fd, &addr, &len)
        if cfd == -1 {
            throw Error.AcceptFailed
        }
        #if os(Linux)
        #else
            setopt(SO_NOSIGPIPE, 1)
        #endif
        return Socket(fd: cfd)        
    }

    public func write(string: String) throws {
        try write([UInt8](string.utf8))
    }

    public func readByte() throws -> UInt8 {
        var buf: UInt8 = 0
        if recv(self.fd as Int32, &buf, 1, 0)  != 1 {
            throw Error.ReadFailed
        }
        return buf
    }

    public func readBytes(count: Int) throws -> [UInt8] {
        var buf = [UInt8](count: count+1, repeatedValue: 0)
        if recv(self.fd as Int32, &buf, count, 0)  != count {
            throw Error.ReadFailed
        }
        return buf
    }

    public func readln() throws -> String {
        var inb: UInt8 = 0
        var buf: [UInt8] = []
        buf.reserveCapacity(32)

        while inb != UInt8(10) {
            inb = try self.readByte()
            if inb != UInt8(13) && inb != UInt8(10) {
                buf.append(inb)
            }
        }
        buf.append(UInt8(0))
        if let str = String.fromCString(UnsafePointer(buf)) {
            return str
        } else {
            throw Error.ReadFailed
        }
    }

    public func write(data: [UInt8]) throws {
        try data.withUnsafeBufferPointer {
            var toSend = Int(data.count)
            var addr = $0.baseAddress
            while toSend > 0 {
              #if os(Linux)
                  let s = send(self.fd, addr, toSend, Int32(MSG_NOSIGNAL))
              #else
                  let s = write(self.fd, addr, toSend)
              #endif
              if s<0 {
                throw Error.WriteFailed
              }
                addr += s
                toSend -= s
            }
        }
    }

    public var hashValue: Int { return Int(self.fd) }

    func setopt(optname: Int32, val: Int32) throws {
        var valcopy: Int32 = val
        if setsockopt(self.fd, SOL_SOCKET, optname, &valcopy, socklen_t(sizeof(Int32))) == -1 {
            // throw here
            throw Error.SetoptFailed
        }
    }

    public func shutDown() {
        #if os(Linux)
            shutdown(self.fd, Int32(SHUT_RDWR))
        #else
            Darwin.shutdown(self.fd, SHUT_RDWR)
        #endif
    }

    public func closeSocket() {
        shutDown()
        close(fd)
    }
}

public func ==(sock1: Socket, sock2: Socket) -> Bool {
    return sock1.fd == sock2.fd
}