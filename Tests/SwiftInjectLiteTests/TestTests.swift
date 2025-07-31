//
//  SleepAnalyzerTests.swift
//  SleepAnalyzerTests
//
//  Created by Igor Gun on 31.07.25.
//

import Testing
@testable import SwiftInjectLite

protocol Animal: AnyObject {
    var name: String { get }
}

protocol Cat: Animal {}

#if USE_MOCK
class CatMockIml: Cat {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
#else
class CatIml: Cat {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
#endif

extension InjectionRegistry {
#if USE_MOCK
    var cat: Cat {
        Self.instantiate(.factory) { CatMockIml(name: "MockMia") }
    }
#else
    var cat: Cat {
        Self.instantiate(.factory) { CatIml(name: "Mia") }
    }
#endif
}

protocol Dog: Animal {}

class DogIml: Dog {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension InjectionRegistry {
    var dog: Dog {
        Self.instantiate(.factory) { DogIml(name: "Max") }
    }
}

protocol PatOwner {
    var cat: Cat { get }
    var dog: Dog { get }
    
    func play() -> String
}

class PatOwnerIml: PatOwner {
    @Inject(\.cat) var cat
    @Inject(\.dog) var dog
    
    func play() -> String {
        "I'm playing with \(cat.name) and \(dog.name)"
    }
}

extension InjectionRegistry {
    var patOwner: PatOwner {
        Self.instantiate(.factory) { PatOwnerIml.init() }
    }
}

protocol Circus: AnyObject {
    var animals: [Animal] { get }
}

class CircusIml: Circus {
    @Inject(\.cat) var cat
    @Inject(\.dog) var dog
    
    var animals: [Animal] {
        [cat, dog]
    }
}

extension InjectionRegistry {
    var circus: Circus {
        Self.instantiate(.singleton(Circus.self)) { CircusIml.init() }
    }
}

struct Tests {
    
    @Test func testInjections() async throws {
        @Inject(\.patOwner) var patOwner
        
#if USE_MOCK
        #expect(patOwner.cat.name == "MockMia")
#else
        #expect(patOwner.cat.name == "Mia")
#endif
        #expect(patOwner.dog.name == "Max")
#if USE_MOCK
        #expect(patOwner.play() == "I'm playing with MockMia and Max")
#else
        #expect(patOwner.play() == "I'm playing with Mia and Max")
#endif
    }
    
    @Test func testFactoryScope() async throws {
        @Inject(\.cat) var cat1
        @Inject(\.cat) var cat2
        
        #expect(!(cat1 === cat2))
    }
    
    @Test func testSingletonScope() async throws {
        @Inject(\.circus) var circus1
        @Inject(\.circus) var circus2
        
        #expect(circus1 === circus2)
    }
}

