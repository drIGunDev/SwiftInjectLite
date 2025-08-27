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
            
            guard let singleton = findSingleton(T.self) else {
                let key = ObjectIdentifier(T.self)
                singletons[key] = factory()
                return singletons[key] as! T
            }
            
            return singleton
        }
    }
    
    private func findSingleton<T>(_ type: T.Type) -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        let key = ObjectIdentifier(type)
        return singletons[key] as? T
    }
}
