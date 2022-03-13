import XCTest
protocol Socket {
    init(host: String, port: Int)
    func open(complete: @escaping ()->Void)
    func close()
    func write(data: Data)
    func read(update: @escaping (Data?, Bool)->Bool)
}

