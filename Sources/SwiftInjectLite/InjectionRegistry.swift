//
//  InjectionRegistry.swift
//  SwiftInjectLite
//
//  Created by Igor Gun on 25.07.25.
//

import Foundation

public final class InjectionRegistry {
    
    public typealias Factory<T> = @Sendable () -> T
    
    let lock: NSRecursiveLock = .init()
    
    private init() {}
    var singletons: [AnyHashable: Any] = [:]
    nonisolated(unsafe) static let shared = InjectionRegistry()

    public class func resetSingletons() {
        shared.lock.lock()
        defer { shared.lock.unlock() }
        shared.singletons.removeAll()
    }
}
