# AsyncAwait
A simple ascyncronous API written in Swift.

I created this project after seeing Microsoft's Async/Await API and decided to make a simple version of it in Swift.

See: https://msdn.microsoft.com/en-us/library/vstudio/hh191443(v=vs.110).aspx

Example:
```swift
func asyncMultiply(a: Int, b: Int) -> Task<Int> { // return type must be specified (i.e. Int)
  return Async {
    // anything in here will be executed asyncronously
    return a * b
  }
}

let task = asyncMultiply(101, 4) // Create and execute an asyncronous task

// Do other tasks here
print("Waiting...")

let result = Await(task) // Wait for the task to finish. Result will be Int
print(result) // 404
```
