//
//  Scope.swift
//  SwiftInjectLite
//
//  Created by Igor Gun on 30.07.25.
//

import Foundation

public enum Scope<T> {
    case factory
    case singleton(T.Type)
}
