//
//  NetworkSocket.swift
//  
//
//  Created by YungCheng Yeh on 2022/3/12.
//

import Network
import NetworkExtension

@available(macOS 10.14, *)
class NetworkSocket: Socket {
    let connection: NWConnection
    required init(host: String, port: Int) {
        self.connection = NWConnection(host: .init(host), port: .init("\(port)")!, using: .tcp)
    }
    
    func open(complete: @escaping ()->Void) {
        self.connection.stateUpdateHandler = {
            (newState) in
            switch newState {
            case .setup:
                print("state setup")
            case .preparing:
                print("state preparing")
            case .ready:
                print("state ready")
                complete()
            case .cancelled:
                print("state cancel")
            case .waiting(let error):
                print("state waiting \(error)")
            case .failed(let error):
                print("state failed \(error)")
            default:
                break
            }
        }
        self.connection.start(queue: .main)
    }
    
    func close() {
        self.connection.cancel()
    }
    
    func write(data: Data) {
        self.connection.send(content: data, completion: .contentProcessed{ _ in })
    }
    
    func read(update: @escaping (Data?, Bool)->Bool) {
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: Int.max) {[weak self] content, contentContext, isComplete, error in
            if update(content, isComplete) {
                self?.read(update: update)
            }
        }
    }
}
