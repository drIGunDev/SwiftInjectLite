//
//  ObjectInjector.swift
//  SwiftInjectLite
//
//  Created by Igor Gun on 30.07.25.
//
import Foundation

struct TypeKey<T>: Hashable {
    private let key: AnyHashable

    init(_ type: T.Type) {
        self.key = "\(type)" as AnyHashable
    }

    static func == (lhs: TypeKey<T>, rhs: TypeKey<T>) -> Bool {
        lhs.key == rhs.key
    }
}
