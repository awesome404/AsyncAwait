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
        var indentifier = 0
        switch self {
        case .High:       indentifier = DISPATCH_QUEUE_PRIORITY_HIGH
        case .Low:        indentifier = DISPATCH_QUEUE_PRIORITY_LOW
        case .Background: indentifier = DISPATCH_QUEUE_PRIORITY_BACKGROUND
        default:          indentifier = DISPATCH_QUEUE_PRIORITY_DEFAULT
        }
        return dispatch_get_global_queue(indentifier,0)
    }
}

private let serialQueue = dispatch_queue_create(nil,DISPATCH_QUEUE_SERIAL)

/// An asynchronous task.
public class Task<T> {
    
    private let group: dispatch_group_t
    private var result: T? = nil
    
    private init(priority: Priority, call: Void -> T) {
        group = dispatch_group_create()
        dispatch_group_async(group, priority.queue) {
            let result = call()
            dispatch_async(serialQueue) {
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
- returns: Result of the task or nil if it timed out.
*/
public func Await<T>(task: Task<T>) -> T {
    dispatch_group_wait(task.group, DISPATCH_TIME_FOREVER)
    var result: T? = nil
    dispatch_async(serialQueue) {
        result = task.result
        task.result = nil // clear the result so it can only get the result once, twice will always return nil
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
    let nanotimeout: UInt64 = UInt64(timeout) * 1000000
    dispatch_group_wait(task.group, nanotimeout)
    var result: T? = nil
    dispatch_async(serialQueue) {
        result = task.result
        task.result = nil // clear the result so it can only get the result once, twice will always return nil
    }
    return result
}