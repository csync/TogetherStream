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
    private var queueIsCleared = false
    
    init(identifier: String) {
        checkingQueue = DispatchQueue(label: identifier)
    }
    
    func addCallbackAndCheckQueueStatus(callback: @escaping (Error?, T?) -> Void) -> (didAddFirst: Bool, queueIsCleared: Bool) {
        var didAddFirst = false
        var queueIsCleared = false
        checkingQueue.sync {
            queueIsCleared = self.queueIsCleared
            didAddFirst = !queueIsCleared && callbacks.isEmpty
            if !queueIsCleared {
                callbacks.append(callback)
            }
        }
        return (didAddFirst, queueIsCleared)
    }
    
    func executeAndClearCallbacks(withError error: Error?, object: T?) {
        checkingQueue.sync {
            queueIsCleared = true
        }
        for callback in callbacks {
            callback(error, object)
        }
        callbacks.removeAll()
    }
}
