import XCTest
@testable import Socket

final class SocketTests: XCTestCase {
    let host = "www.google.com"
    let port = 80
    static let request = "GET / HTTP/1.1\r\n\r\n".data(using: .ascii)!
    
    func testStream() throws {
        let socket = StreamSocket(host: host, port: port)
        let exp = expectation(description: "\(#function)\(#line)")
        socket.open { [weak socket] in
            guard let socket = socket else { return }
            socket.read { data, finish in
                if let end = data?.last, end == 0x0A {
                    exp.fulfill()
                    return false
                }
                return true
            }
            socket.write(data: Self.request)
        }
        
        waitForExpectations(timeout: 10) {_ in
            socket.close()
        }
    }
    
    func testURLSession() throws {
        let socket = URLSessionSocket(host: host, port: port)
        let exp = expectation(description: "\(#function)\(#line)")
        socket.open { [weak socket] in
            guard let socket = socket else { return }
            socket.read { data, finish in
                if let end = data?.last, end == 0x0A {
                    exp.fulfill()
                    return false
                }
                return true
            }
            socket.write(data: Self.request)
        }
        
        waitForExpectations(timeout: 10) {_ in
            socket.close()
        }
    }
    
    func testNetwork() throws {
        let socket = NetworkSocket(host: host, port: port)
        let exp = expectation(description: "\(#function)\(#line)")
        socket.open { [weak socket] in
            guard let socket = socket else { return }
            socket.read { data, finish in
                if let end = data?.last, end == 0x0A {
                    exp.fulfill()
                    return false
                }
                return true
            }
            socket.write(data: Self.request)
        }
        
        waitForExpectations(timeout: 10) {_ in
            socket.close()
        }
    }
}


