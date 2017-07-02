//
//  APIClient.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 1/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import Foundation
import CoreData.NSManagedObjectContext

final class APIClient {
    
    // MARK: - Init
    
    let base: Base
    let mapper: Mapper
    let viewContext: NSManagedObjectContext
    
    init(base: Base, jsonContext: NSManagedObjectContext, viewContext: NSManagedObjectContext) {
        self.base = base
        self.viewContext = viewContext
        self.mapper = Mapper(context: jsonContext)
    }
    
    // MARK: -
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        
        // Not really comfortable having these here, committed in the source repo and also in plaintext.
        // I am assuming that using a more secure approach is out of scope for this sample application,
        // since there is no specification for handling these.
        let consumerKey = "978145F1EA9F6C2ED3423F261D4419E5"
        let consumerSecret = "DE5A671CC22B6936C493D8F6BAABB620"
        
        configuration.httpAdditionalHeaders = [
            "accept": "application/json",
            "Authorization":
                "OAuth oauth_consumer_key=\"\(consumerKey)\", "
                    + "oauth_signature_method=\"PLAINTEXT\", "
                    + "oauth_signature=\"\(consumerSecret)&\""
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
    
    enum Errors: Error, LocalizedError {
        case emptyResponse
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .emptyResponse:
                return NSLocalizedString("api_error.empty_response",
                                         value: "There was no data returned.",
                                         comment: "Unexpected empty response error message.")
            case .invalidResponse:
                return NSLocalizedString("api_error.invalid_response",
                                         value: "Received an invalid response.",
                                         comment: "Invalid response error message.")
            }
        }
    }
    
    /**
     HTTP Methods supported by `APIClient`.
     
     - seealso:
     [Available HTTP Methods](https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html)
     */
    enum Method: String {
        case get = "GET"
        
        var encodesParametersInURL: Bool {
            switch self {
            case .get: return true
            }
        }
    }
    
    /**
     A Request is used to describe and then build a `URLRequest`.
     This is done in `APIClient.sendRequest(_:completionHandler:)`.
     */
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
    
    /**
     Sends a constructed request.
     This is the primitive method that all endpoint routes call through.
     */
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
    
    /**
     Encodes the provided `URLRequest` using the descripted parameters in the `Request` structure.
     */
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
