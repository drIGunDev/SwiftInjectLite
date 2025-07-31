//
//  InjectionRegistry+Inject.swift
//  SwiftInjectLite
//
//  Created by Igor Gun on 31.07.25.
//

import Foundation

extension InjectionRegistry {
    
    public class func inject<T>(_ keyPath: KeyPath<InjectionRegistry, T>) -> T {
        shared.inject(keyPath)
    }

    private func inject<T>(_ keyPath: KeyPath<InjectionRegistry, T>) -> T {
        lock.lock()
        defer { lock.unlock() }
        
        return self[keyPath: keyPath]
    }
}
