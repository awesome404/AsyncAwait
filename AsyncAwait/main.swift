//
//  main.swift
//  AsyncAwait
//
//  Created by Adam Dann on 2015-03-30.
//  Copyright (c) 2015 Adam Dann. All rights reserved.
//

import Foundation

func scope() { // to avoid lazy initialization of globals.

    println("AsyncAwait")

// A very basic example for inline use

    let task1 = Async {
        "Simple Test" // the return value infers the type here, but elsewhere it has to be statically typed
    }

    println("Waiting...")

    let result1 = Await(task1)
    println(result1)


// A simple example of a function instead of inline
// there is no async keyword anywhere, but you could put it in your funciton name

    func asyncMultiply(aInt: Int, bInt: Int) -> Task<Int> { // the type must be specified in this case
        return Async {
            return aInt * bInt // return value will not infer the type
        }
    }

    let task2 = asyncMultiply(101, 4)

    println("Waiting...")

    let result2 = Await(task2)
    println(result2)


// An example where it actually does something

    func sleep(seconds: Int) -> Task<String> {
        return Async {
            // hack together a sleep method.
            let group = dispatch_group_create()
            let when = dispatch_time(DISPATCH_TIME_NOW, 1000000000 * Int64(seconds))
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
            dispatch_group_enter(group)
            dispatch_after(when, queue) {
                dispatch_group_leave(group)
            }
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            return "\(seconds) seconds have passed"
        }
    }

    let task3 = sleep(2)

    println("Waiting...")

    let result3 = Await(task3)
    println(result3)

    
// an example with a timeout

    let task4 = sleep(3)

    println("Waiting...")

    if let result4 = Await(task4, timeout: 1000) {
        println(result4) //never happens
    } else {
        println("Timed out")
    }

    
// An example with a tuple

    let task5 = Async { () -> (Int,String) in // statically typed
        return (5,"five")
    }

    println("Waiting...")

    let result5 = Await(task5)
    println(result5)

    
// Timeout example continued, because we can Await for it again if it timed out

    println("Waiting...")
    
    let result6 = Await(task4)
    println(result6)

}

scope()