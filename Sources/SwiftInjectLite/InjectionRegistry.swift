//
//  DIContainer.swift
//  DI
//
//  Created by Igor Gun on 25.07.25.
//

import Foundation

public final class InjectionRegistry {
    
    public typealias Factory<T> = @Sendable () -> T
    


    nonisolated(unsafe) internal var lock: NSRecursiveLock = .init()
    
    private init() {}
    internal var singletons: [AnyHashable: Any] = [:]
    nonisolated(unsafe) internal static let shared = InjectionRegistry()
}
