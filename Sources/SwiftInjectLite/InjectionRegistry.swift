//
//  DIContainer.swift
//  DI
//
//  Created by Igor Gun on 25.07.25.
//

import Foundation

public final class InjectionRegistry {
    
    public typealias Factory<T> = @Sendable () -> T
    
    public class func inject<T>(_ keyPath: KeyPath<InjectionRegistry, T>) -> T {
        shared.inject(keyPath)
    }
    
    public class func instantiate<T>(_ scope: Scope<T> = .factory, factory: @escaping Factory<T>) -> T {
        shared.instantiate(scope, factory: factory)
    }

    private func inject<T>(_ keyPath: KeyPath<InjectionRegistry, T>) -> T {
        lock.lock()
        defer { lock.unlock() }
        
        return self[keyPath: keyPath]
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

    nonisolated(unsafe) private var lock: NSRecursiveLock = .init()
    
    private init() {}
    private var singletons: [AnyHashable: Any] = [:]
    nonisolated(unsafe) private static let shared = InjectionRegistry()
}
