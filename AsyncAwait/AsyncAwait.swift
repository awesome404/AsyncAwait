//
//  AsyncAwait.swift
//  AsyncAwait
//
//  Created by Adam Dann on 2015-03-30.
//  Copyright (c) 2015 Adam Dann. All rights reserved.
//

import Foundation

/// Priority to run the asynchronous task at.
public enum Priority {
    case High, Low, Background, Default
    
    // internal variable to get the proper queue
    private var queue: dispatch_queue_t {
        var indentifier = DISPATCH_QUEUE_PRIORITY_DEFAULT
        switch self {
        case .High:       indentifier = DISPATCH_QUEUE_PRIORITY_HIGH
        case .Low:        indentifier = DISPATCH_QUEUE_PRIORITY_LOW
        case .Background: indentifier = DISPATCH_QUEUE_PRIORITY_BACKGROUND
        default:          indentifier = DISPATCH_QUEUE_PRIORITY_DEFAULT
        }
        return dispatch_get_global_queue(indentifier,0)
    }
}

// Internal serial queue to protect the results from getting squashed.
private let serialQueue = dispatch_queue_create(nil,DISPATCH_QUEUE_SERIAL)

/// An asynchronous task container. This is created by Async and evaluated by Await.
public class Task<T> {
    
    private let group = dispatch_group_create()
    private var result: T? = nil
    
    private init(priority: Priority, call: Void -> T) {
        dispatch_group_async(group, priority.queue) {
            let result = call()
            dispatch_sync(serialQueue) { // protect the result
                self.result = result
            }
        }
    }
}

/**
Create and execute an asynchronous task.
(Just a simple wrapper, but Task.init() is hidden)

- parameter priority: Priority to run the task at.
- parameter call: The task to execute asynchronously.
- returns: Task object to be used in Await().
*/
public func Async<T>(priority: Priority = .Default, call: Void -> T) -> Task<T> {
    return Task(priority: priority, call: call)
}

/**
Wait or retrieve a result of a task.

- parameter task: Task object created by Async.
- returns: Result of the task.
*/
public func Await<T>(task: Task<T>) -> T {
    dispatch_group_wait(task.group, DISPATCH_TIME_FOREVER) // wait for it...
    var result: T? = nil
    dispatch_sync(serialQueue) { // protect the result
        result = task.result
    }
    assert(result != nil)
    return result!
}

/**
Wait or retrieve a result of a task with a timeout.
(If timeout happens, the task can Await again.)

- parameter task: Task object created by Async.
- parameter timeout: Milliseconds after the task is abandoned.
- returns: Result of the task or nil if it timed out.
*/
public func Await<T>(task: Task<T>, timeout: Int) -> T? {
    let nanotimeout: UInt64 = UInt64(timeout) * 1000000 // prepare the timeout
    dispatch_group_wait(task.group, nanotimeout) // wait for it...
    var result: T? = nil
    dispatch_sync(serialQueue) { // protect the result
        result = task.result
    }
    return result
}