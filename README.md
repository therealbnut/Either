# Either

A reusable Swift Either protocol, easy to conform to, extensible, and with useful functions.

### Example Usage:

```swift
let results: [Result<Int,MyError>] = ...
let values: [Int] = results.filterSecond()
```

### Example Conformance:

```swift
enum Result<T,E: ErrorType> {
    case Value(T), Error(E)
}

extension Result: EitherType {
    func apply(
        @noescape first first: E throws -> Void,
        @noescape second: T throws -> Void
    ) rethrows {
        switch self {
        case let .Error(x): try first(x)
        case let .Value(x): try second(x)
        }
    }
}
```
