//
//  RequestDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

class ThreadSafeCallbackQueue<T> {
    
    private var checkingQueue: DispatchQueue
    private var callbacks: [(Error?, T?) -> Void] = []
    private var alreadySucceeded = false
    
    init(identifier: String) {
        checkingQueue = DispatchQueue(label: identifier)
    }
    
    func addCallbackAndCheckQueueStatus(callback: @escaping (Error?, T?) -> Void) -> (didAddFirst: Bool, alreadySucceeded: Bool) {
        var didAddFirst = false
        var alreadySucceeded = false
        checkingQueue.sync {
            alreadySucceeded = self.alreadySucceeded
            didAddFirst = !alreadySucceeded && callbacks.isEmpty
            if !alreadySucceeded {
                callbacks.append(callback)
            }
        }
        return (didAddFirst, alreadySucceeded)
    }
    
    func executeAndClearCallbacks(withError error: Error?, object: T?) {
        var savedCallbacks: [(Error?, T?) -> Void] = []
        checkingQueue.sync {
            if error == nil {
                alreadySucceeded = true
            }
            savedCallbacks = callbacks
            callbacks.removeAll()
        }
        for callback in savedCallbacks {
            callback(error, object)
        }
    }
}
