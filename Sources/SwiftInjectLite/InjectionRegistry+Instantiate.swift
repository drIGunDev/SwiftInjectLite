//
//  InjectionRegistry+Instantiate.swift
//  SwiftInjectLite
//
//  Created by Igor Gun on 31.07.25.
//

import Foundation

extension InjectionRegistry {
    
    public class func instantiate<T>(_ scope: Scope = .factory, factory: @escaping Factory<T>) -> T {
        shared.instantiate(scope, factory: factory)
    }
    
    private func instantiate<T>(_ scope: Scope = .factory, factory: @escaping Factory<T>) -> T {
        lock.lock()
        defer { lock.unlock() }
        
        switch scope {
        case .factory: return factory()
        case .singleton:
            let key = TypeKey(T.self)
            if let existing = singletons[key] as? T {
                return existing
            }
            let instance = factory()
            singletons[key] = instance
            return instance
        }
    }
    
}
