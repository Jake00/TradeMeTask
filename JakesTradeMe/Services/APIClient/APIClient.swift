//
//  APIClient.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 1/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import Foundation

final class APIClient {
    
    var base: Base = .develop
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "accept": "application/json"
        ]
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()
    
    typealias Parameters = [String: Any]
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    enum Base: String {
        case develop = "https://api.tmsandbox.co.nz/v1/"
        case production = "https://api.trademe.co.nz/v1/"
        
        var url: URL {
            // swiftlint:disable:next force_unwrapping
            return URL(string: rawValue)!
        }
    }
    
    enum Method: String {
        case get = "GET"
        
        var encodesParametersInURL: Bool {
            switch self {
            case .get: return true
            }
        }
    }
    
    struct Request {
        let method: Method
        let path: String
        let parameters: Parameters?
        
        init(
            _ method: Method,
            _ path: String,
            parameters: Parameters? = nil
            ) {
            self.method = method
            self.path = path
            self.parameters = parameters
        }
    }
    
    @discardableResult
    func sendRequest(
        _ request: Request,
        completionHandler: @escaping CompletionHandler
        ) -> URLSessionDataTask {
        
        guard let url = URL(string: request.path, relativeTo: base.url)
            ?? request.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                .flatMap({ URL(string: $0, relativeTo: base.url) }) else {
                    fatalError("Invalid URL provided to \(self): \(request.path)")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        encode(&urlRequest, with: request, url)
        
        let operation = NetworkOperation()
        let task = session.dataTask(with: urlRequest) { data, response, error in
            APIClient.logResponse(data, response, error, url)
            operation.complete()
            completionHandler(data, response, error)
        }
        operation.task = task
        queue.addOperation(operation)
        
        return task
    }
    
    func encode(_ urlRequest: inout URLRequest, with request: Request, _ url: URL) {
        guard request.method.encodesParametersInURL else {
            if let parameters = request.parameters {
                urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }
            return
        }
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            request.parameters?.isEmpty == false {
            guard let parameters = request.parameters as? [String: String] else {
                fatalError("Only string types are supported in query parameters. "
                    +      "No arrays, dictionaries or other types.")
            }
            components.queryItems = parameters.map(URLQueryItem.init)
            urlRequest.url = components.url
        }
    }
}
