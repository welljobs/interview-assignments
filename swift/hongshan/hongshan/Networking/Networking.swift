//
//  Networking.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import Foundation
import Combine

enum ResponseError: Swift.Error {
    case HTTPSError(Error)
    case JSONTransfer(Error)
    case NoneYetData
    
    static func map(_ error: Error) -> ResponseError {
        return error as? ResponseError ?? .JSONTransfer(error)
    }
}

enum URLSessionError: Error {
    case invalidResponse
    case errorMessage(status: Int, data: Data)
    case URLError(URLError)
}

enum HTTPSMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum HTTPSContentType: String {
    case form = "form-data"
    case json = "application/json"
}

protocol HTTPRequest {
    associatedtype Input: Codable
    associatedtype Output: Codable
    
    var path: String { get }
    var version: String { get }
    var mockEnable: Bool { get }
    var method: HTTPSMethod { get }
    var contentType: HTTPSContentType { get }
    var params: Input { get }
}

extension HTTPRequest {
    var version: String { "1.0.0" }
    var method: HTTPSMethod { .post }
    var mockEnable: Bool { false }
    var contentType: HTTPSContentType { .form }
    
}

protocol HTTPSResponse: Codable {
    var pageNo: Int? { get set }
    var pageSize: Int? { get set }
    var total: Int? { get set }
    var success: Int? { get set }
    var message: String? { get set }
}

extension HTTPSResponse {
    var pageNo: Int? {
        get { nil }
        set { }
    }
    var pageSize: Int? {
        get { nil }
        set { }
    }
    var total: Int? {
        get { nil }
        set { }
    }
    var success: Int? {
        get { nil }
        set { }
    }
    var message: String? {
        get { nil }
        set { }
    }
}

protocol Networkable {
    func fetch<R: HTTPRequest>(_ request: R, handler: @escaping (Result<R.Output, ResponseError>) -> Void) where R: HTTPRequest
    func fetch<R: HTTPRequest>(_ request: R) -> Future<R.Output, ResponseError> where R: HTTPRequest
    func fetch<R: HTTPRequest>(from request: R) -> AnyPublisher<R.Output, ResponseError> where R: HTTPRequest
    
    func load<R: HTTPRequest>(_ request: R) -> R.Output where R: HTTPRequest
}

public class Networking: Networkable {
    static let `default` = Networking()
    private init() {
        //  私有构造函数，防止外部创建新的实例.
    }
    func fetch<R>(_ request: R, handler: @escaping (Result<R.Output, ResponseError>) -> Void) where R : HTTPRequest {
        if HSMockManager.default.hasMockData(for: request.path) {
            let duration = HSMockManager.default.requestDuration ?? 0
            DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval(duration)) {
                guard let json = HSMockManager.default.mockData(for: request.path) else { return }
                guard let data = json.data(using: .utf8) else { return }
                do {
                    let model = try JSONDecoder().decode(R.Output.self, from: data)
                    OperationQueue.main.addOperation {
                        handler(.success(model))
                    }
                } catch {
                    Console.log(tag: "Networking:", msg: "\(error.localizedDescription)")
                    OperationQueue.main.addOperation {
                        handler(.failure(.JSONTransfer(error)))
                    }
                }
            }
        }
    }
    func fetch<R>(from request: R) -> AnyPublisher<R.Output, ResponseError> where R : HTTPRequest {
        return fetch(request).eraseToAnyPublisher()
    }
    func fetch<R>(_ request: R) -> Future<R.Output, ResponseError> where R : HTTPRequest {
        if HSMockManager.default.hasMockData(for: request.path) {
            guard let json = HSMockManager.default.mockData(for: request.path) else {
                return networkingError(request: request, error: .NoneYetData)
            }
            guard let data = json.data(using: .utf8) else {
                return networkingError(request: request, error: .NoneYetData)
            }
            do {
                let model = try JSONDecoder().decode(R.Output.self, from: data)
                return Future<R.Output, ResponseError> { promise in
                    OperationQueue.main.addOperation {
                        promise(.success(model))
                    }
                }
            } catch {
                Console.log(tag: "Networking:", msg: "\(error.localizedDescription)")
                return networkingError(request: request, error: ResponseError.map(error))                }
        }
        //  此处走远程服务器请求数据
        guard let model = HomeDataRequest.Response(data: []) as? R.Output else {
            return networkingError(request: request, error: .NoneYetData)
        }
        return Future<R.Output, ResponseError> { promise in
            OperationQueue.main.addOperation {
                promise(.success(model))
            }
        }
    }
    
    func mockData(for key: String) async throws -> String? {
        guard let filePath = Bundle.main.path(forResource: key, ofType: "json") else {
            throw URLError(.badServerResponse)
        }
        let content = try? NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String
        return content
    }
    func load<R>(_ request: R) -> R.Output where R : HTTPRequest {
        guard let url = Bundle.main.url(forResource: request.path, withExtension: "json") else {
            fatalError("Couldn't find \(request.path) in main bundle.")
        }
        do {
            let data = try Data(contentsOf: url)
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(R.Output.self, from: data)
            } catch {
                fatalError("Couldn't parse \(request.path) as \(R.Output.self):\n\(error)")
            }
        } catch {
            fatalError("Couldn't load \(request.path) from main bundle:\n\(error)")
        }
    }
}

extension Networking {
    func networkingError<R: HTTPRequest>(request: R, error: ResponseError) -> Future<R.Output, ResponseError> {
        return Future { promise in
            OperationQueue.main.addOperation {
                promise(.failure(error))
            }
        }
    }
}

extension URLSession {
    func send(request: URLRequest) -> AnyPublisher<Data, URLSessionError> {
        dataTaskPublisher(for: request)
            .mapError { URLSessionError.URLError($0) }
            .flatMap { data, response -> AnyPublisher<Data, URLSessionError> in
                guard let response = response as? HTTPURLResponse else {
                    return .fail(.invalidResponse)
                }
                guard 200..<300 ~= response.statusCode else {
                    return .fail(.errorMessage(status: response.statusCode, data: data))
                }
                return .just(data)
        }.eraseToAnyPublisher()
    }
}
extension Publisher {
    static func empty() -> AnyPublisher<Output, Failure> {
        Empty().eraseToAnyPublisher()
    }

    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        Just(output).catch { _ in AnyPublisher<Output, Failure>.empty() }.eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        Fail(error: error).eraseToAnyPublisher()
    }
}
