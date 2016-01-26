//
//  main.swift
//  Either
//
//  Created by Andrew Bennett on 26/01/2016.
//  Copyright © 2016 TeamBnut. All rights reserved.
//

public protocol EitherType {
    typealias First
    typealias Second

    func map<T>(
        @noescape first first: First throws -> T,
        @noescape second: Second throws -> T
    ) rethrows -> T

    func apply(
        @noescape first first: First throws -> Void,
        @noescape second: Second throws -> Void
    ) rethrows
}

public extension EitherType {
    var isFirst: Bool {
        return map(first: { _ in true }, second: { _ in false })
    }

    var isSecond: Bool {
        return map(first: { _ in false }, second: { _ in true })
    }

    func map<T>(
        @noescape first first: First throws -> T,
        @noescape second: Second throws -> T
    ) rethrows -> T {
        var value: T?
        try apply(
            first:  { value = try first($0) },
            second: { value = try second($0) })
        if let value = value { return value }
        fatalError("\(self.dynamicType).apply must call first or second exactly once.")
    }
}

private extension EitherType {
    var first: First? {
        return map(first: { $0 }, second: { _ in nil })
    }

    var second: Second? {
        return map(first: { _ in nil }, second: { $0 })
    }
}

public func either<E: EitherType,V>(
    first: E.First throws -> V,
    second: E.Second throws -> V
) -> (E throws -> V) {
    return { try $0.map(first: first, second: second) }
}

public func either<E: EitherType,V>(
    first: E.First -> V,
    second: E.Second -> V
) -> (E -> V) {
    return { $0.map(first: first, second: second) }
}

public extension SequenceType where Generator.Element: EitherType {
    func filterFirst() -> [Generator.Element.First] {
        return self.flatMap { $0.first }
    }
    func filterSecond() -> [Generator.Element.Second] {
        return self.flatMap { $0.second }
    }
    func split()
        -> ([Generator.Element.First], [Generator.Element.Second])
    {
        return ( self.flatMap { $0.first }, self.flatMap { $0.second } )
    }
}
