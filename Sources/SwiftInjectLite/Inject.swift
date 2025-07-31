//
//  Inject.swift
//  SwiftInjectLite
//
//  Created by Igor Gun on 30.07.25.
//

import Foundation

@propertyWrapper public struct Inject<T> {
    
    public var wrappedValue: T {
        mutating get {
            lock.lock()
            defer { lock.unlock() }
            
            if value == nil {
                value = InjectionRegistry.inject(keyPath)
            }
    
            return value!
        }
        set {
            lock.lock()
            defer { lock.unlock() }

            value = newValue
        }
    }
    
    public var projectedValue: Inject<T> { self }
    
    private var lock: NSRecursiveLock = .init()
    private let keyPath: KeyPath<InjectionRegistry, T>
    private var value: T?
    
    public init(_ keyPath: KeyPath<InjectionRegistry, T>) {
        self.keyPath = keyPath
    }
}
