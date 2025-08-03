//
//  DIContainer.swift
//  DI
//
//  Created by Igor Gun on 25.07.25.
//

import Foundation

public final class InjectionRegistry {
    
    public typealias Factory<T> = @Sendable () -> T
    
    nonisolated(unsafe) var lock: NSRecursiveLock = .init()
    
    private init() {}
    var singletons: [AnyHashable: Any] = [:]
    nonisolated(unsafe) static let shared = InjectionRegistry()
}
