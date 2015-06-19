//: ### AsyncAwait

import AsyncAwait

//: A very basic example for inline use

let task1 = Async {
    "Simple Test" // the return value infers the type here, but elsewhere it has to be statically typed
}

print("Waiting...")

let result1 = Await(task1)
print(result1)


//: A simple example of a function instead of inline
// there is no async keyword anywhere, but you could put it in your funciton name

func asyncMultiply(aInt: Int,_ bInt: Int) -> Task<Int> { // the type must be specified in this case
    return Async {
        return aInt * bInt // return value will not infer the type
    }
}

let task2 = asyncMultiply(101, 4)

print("Waiting...")

let result2 = Await(task2)
print(result2)

//: An example where it actually does something

let task3 = sleep(2)

print("Waiting...")

let result3 = Await(task3)
print(result3)

//: an example with a timeout

let task4 = sleep(3)

print("Waiting...")

if let result4 = Await(task4, timeout: 1000) {
    print(result4) //never happens
} else {
    print("Timed out")
}

//: An example with a tuple

let task5 = Async { () -> (Int,String) in // statically typed
    return (5,"five")
}

print("Waiting...")

let result5 = Await(task5)
print(result5)

//: Timeout example continued, because we can Await for it again if it timed out

print("Waiting...")

let result6 = Await(task4)
print(result6)

//: Hacks

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
