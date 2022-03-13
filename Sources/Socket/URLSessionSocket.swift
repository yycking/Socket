//
//  File.swift
//  
//
//  Created by YungCheng Yeh on 2022/3/11.
//

import Foundation

@available(macOS 10.11, *)
class URLSessionSocket: NSObject, Socket {
    private let task: URLSessionStreamTask
    
    required init(host: String, port: Int) {
        self.task = URLSession.shared.streamTask(withHostName: host, port: port)
    }
    
    func open(complete: @escaping ()->Void) {
        self.task.resume()
        complete()
    }
    
    func close() {
        self.task.closeWrite()
        self.task.closeRead()
    }
    
    func write(data: Data) {
        self.task.write(data, timeout: 5.0) { error in
            
        }
    }
    
    func read(update: @escaping (Data?, Bool)->Bool) {
        self.task.readData(ofMinLength: 1, maxLength: Int.max, timeout: 0) {[weak self] data, eof, error in
            if update(data, eof) {
                self?.read(update: update)
            }
        }
    }
}
