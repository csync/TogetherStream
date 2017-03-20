//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation

/// Queue that provides a thread-safe way to store and
/// call callbacks.
class ThreadSafeCallbackQueue<T> {
    
    /// Serial queue used to provide thread safety.
    private var checkingQueue: DispatchQueue
    /// Stores callbacks to call.
    private var callbacks: [(Error?, T?) -> Void] = []
    /// Indicates of the request has already succeeded.
    private var alreadySucceeded = false
    
    /// Creates a new ThreadSafeCallbackQueue
    ///
    /// - Parameter identifier: A unique identifer for the queue
    init(identifier: String) {
        checkingQueue = DispatchQueue(label: identifier)
    }
    
    /// Adds the callback to the queue and checks the status in a thread-safe matter.
    ///
    /// - Parameter callback: The callback to add.
    /// - Returns: A tuple with the current status. `wasEmpty` indicates whether the
    /// queue was empty before; `alreadySucceeded` indicates the request was already marked
    /// as succeeded.
    func addCallbackAndCheckQueueStatus(callback: @escaping (Error?, T?) -> Void) -> (wasEmpty: Bool, alreadySucceeded: Bool) {
        var wasEmpty = false
        var alreadySucceeded = false
        checkingQueue.sync {
            alreadySucceeded = self.alreadySucceeded
            // Don't do anything if already succeeded
            wasEmpty = !alreadySucceeded && callbacks.isEmpty
            if !alreadySucceeded {
                callbacks.append(callback)
            }
        }
        return (wasEmpty, alreadySucceeded)
    }
    
    /// Clears the queue and exectues the stored callbacks with the given results
    /// in a thread-safe matter.
    ///
    /// - Parameters:
    ///   - error: An error that could be passed to the callbacks.
    ///   - object: An object that could be passed to the callbacks.
    func executeAndClearCallbacks(withError error: Error?, object: T?) {
        // Saves callbacks to be executed outside the serial queue.
        var savedCallbacks: [(Error?, T?) -> Void] = []
        checkingQueue.sync {
            // Request only succeeds if no error, this allows a new request to be sent
            // if there is an error.
            if error == nil {
                alreadySucceeded = true
            }
            savedCallbacks = callbacks
            callbacks.removeAll()
        }
        // Callbacks are executed outside the serial queue for performance.
        for callback in savedCallbacks {
            callback(error, object)
        }
    }
}
