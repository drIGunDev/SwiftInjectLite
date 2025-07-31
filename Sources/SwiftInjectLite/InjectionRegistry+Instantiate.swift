//
//  InjectionRegistry+Instantiate.swift
//  SwiftInjectLite
//
//  Created by Igor Gun on 31.07.25.
//

import Foundation

extension InjectionRegistry {
    
    public class func instantiate<T>(_ scope: Scope<T> = .factory, factory: @escaping Factory<T>) -> T {
        shared.instantiate(scope, factory: factory)
    }
    
    private func instantiate<T>(_ scope: Scope<T> = .factory, factory: @escaping Factory<T>) -> T {
        lock.lock()
        defer { lock.unlock() }
        
        switch scope {
        case .factory: return factory()
        case .singleton(let type):
            guard let singleton = findSingleton(type) else {
                let key = ObjectIdentifier(type)
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
