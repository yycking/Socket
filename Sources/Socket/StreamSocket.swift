//
//  File.swift
//  
//
//  Created by YungCheng Yeh on 2022/3/11.
//

import Foundation

class StreamSocket: NSObject, Socket {
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var openComplete: (()->Void)?
    var callback: ((Data?, Bool)->Bool)?
    private var opend = 0
    
    required init(host: String, port: Int) {
        Stream.getStreamsToHost(withName: host,
                                port: port,
                                inputStream: &self.inputStream,
                                outputStream: &self.outputStream)
    }
    
    func open(complete: @escaping ()->Void) {
        self.openComplete = complete
        
        guard
            let inputStream = self.inputStream,
            let outputStream = self.outputStream else { return }
        self.opend = 0
        [inputStream, outputStream].forEach{ stream in
            stream.delegate = self
            stream.schedule(in: .current, forMode: .default)
            stream.open()
        }
    }
    
    func close() {
        [self.inputStream, self.outputStream].forEach{ stream in
            stream?.close()
            stream?.remove(from: .current, forMode: .common)
        }
    }
    
    func write(data: Data) {
        let length = data.count
        let bytes = [UInt8](data)
        self.outputStream?.write(bytes, maxLength: length)
    }
    
    func read(update: @escaping (Data?, Bool)->Bool) {
        self.callback = update
    }
}

extension StreamSocket: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.errorOccurred:
            print("ErrorOccurred")
        case Stream.Event.endEncountered:
            print("EndEncountered")
        case Stream.Event.hasBytesAvailable:
            print("HasBytesAvaible")
            if let stream = aStream as? InputStream {
                readAvailableBytes(stream: stream)
            }
        case Stream.Event.openCompleted:
            print("OpenCompleted")
            self.opend += 1
        case Stream.Event.hasSpaceAvailable:
            print("HasSpaceAvailable")
            if self.opend == 2 {
                self.opend += 1
                self.openComplete?()
            }
        default:
            print("default reached. unknown stream event")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let max = 4096
        var data: Data?
        while stream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: max)
            let length = stream.read(&buffer, maxLength: max)
            if length > 0 {
                if data == nil {
                    data = Data()
                }
                data?.append(buffer, count: length)
            }
        }
        
        guard let update = self.callback else {return}
        if update(data, true) == false {
            self.callback = nil
        }
    }
}
