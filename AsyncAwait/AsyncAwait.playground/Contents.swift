//: ### AsyncAwait

import AsyncAwait

//: A very basic example for inline use

let task1 = Async {
    "Simple Test" // the return value infers the type here, but elsewhere it has to be statically typed
}

print("Waiting...")

let result1 = Await(task1)
print(result1)


//: A simple example of a function instead of inline.

func asyncMultiply(aInt: Int,_ bInt: Int) -> Task<Int> { // the type must be specified in this case
    return Async {
        return aInt * bInt // return value will not infer the type
    }
}

let task2 = asyncMultiply(101, 4)

print("Waiting...")

let result2 = Await(task2)
print(result2)

//: An example that actually has to wait.

let task3 = Async { () -> String in
    sleep(2)
    return "Slept for 2 seconds."
}

print("Waiting...")

let result3 = Await(task3)
print(result3)

//: An example with a timeout.

let task4 = Async { () -> String in
    sleep(3)
    return "Slept for 3 seconds"
}

print("Waiting...")

if let result4 = Await(task4, timeout: 1000) {
    print(result4) //never happens
} else {
    print("Timed out")
}

//: An example with a tuple

let task5 = Async { () -> (Int,String) in
    return (5,"five")
}

print("Waiting...")

let result5 = Await(task5)
print(result5)

//: Timeout example continued, because we can Await for it again if it timed out

print("Waiting...")

let result6 = Await(task4)
print(result6)
