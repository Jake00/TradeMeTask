//
//  NetworkOperation.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 1/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import Foundation

class NetworkOperation: Operation {
    
    var task: URLSessionTask?
    
    override var isAsynchronous: Bool { return true }
    
    private let queue = DispatchQueue(label: "jrb.JakesTradeMe.NetworkOperationQueue")
    
    private struct Keys {
        static let isExecuting = "isExecuting"
        static let isFinished = "isFinished"
    }
    
    private var _executing: Bool = false
    
    override private(set) var isExecuting: Bool {
        get { return queue.sync { _executing }}
        set {
            willChangeValue(forKey: Keys.isExecuting)
            queue.sync { _executing = newValue }
            didChangeValue(forKey: Keys.isExecuting)
        }
    }
    
    private var _finished: Bool = false
    
    override private(set) var isFinished: Bool {
        get { return queue.sync { _finished }}
        set {
            willChangeValue(forKey: Keys.isFinished)
            queue.sync { _finished = newValue }
            didChangeValue(forKey: Keys.isFinished)
        }
    }
    
    func complete() {
        if isExecuting {
            isExecuting = false
        }
        if !isFinished {
            isFinished = true
        }
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        isExecuting = true
        guard let task = task else {
            complete(); return
        }
        APIClient.logRequest(task)
        task.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
}
