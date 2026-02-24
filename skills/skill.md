# SwiftInjectLite — AI Agent Skill Guide

> Minimal, compile-time-safe dependency injection for Swift. No reflection. KeyPath-based.

## Core API

```swift
// Registration (in InjectionRegistry extension)
Self.instantiate(.factory)   { MyImpl() }   // new instance every time
Self.instantiate(.singleton) { MyImpl() }   // shared instance

// Resolution
InjectionRegistry.inject(\.serviceName)     // direct call
@Inject(\.serviceName) var service          // property wrapper (lazy, cached)

// Testing
InjectionRegistry.resetSingletons()         // clear all singletons
```

---

## Registration Pattern

Always extend `InjectionRegistry` with a computed property returning the **protocol type**. Implementation stays private.

```swift
// Protocol (public)
protocol DatabaseService: AnyObject {
    func fetch() async throws -> [Item]
}

// Implementation (private)
private final class DatabaseServiceImpl: DatabaseService { ... }

// Registration
extension InjectionRegistry {
    var databaseService: any DatabaseService {
        Self.instantiate(.singleton) { DatabaseServiceImpl() }
    }
}
```

## Chained Dependencies

When a service depends on another registered service, resolve it via `Self.inject()` inside the registration closure:

```swift
extension InjectionRegistry {
    var sensor: any Sensor {
        let apiProvider = Self.inject(\.apiProvider)
        return Self.instantiate(.singleton) { SensorImpl(apiProvider: apiProvider) }
    }

    var dataSource: any DataSource {
        let sensor = Self.inject(\.sensor)
        return Self.instantiate(.singleton) { DataSourceImpl(sensor: sensor) }
    }
}
```

## Resolution Patterns

### @Inject Property Wrapper (in classes/actors)

```swift
final class RepositoryImpl: Repository {
    @Inject(\.databaseService) private var db
    @Inject(\.graphRenderer) private var renderer

    func loadData() async throws -> [Item] {
        try await db.fetch()
    }
}
```

### Direct Resolution (in SwiftUI views with @State)

```swift
struct ContentView: View {
    @State private var viewModel = InjectionRegistry.inject(\.contentViewModel)

    var body: some View { ... }
}
```

### Direct Resolution (in @Observable ViewModels for child VMs)

```swift
@Observable final class ParentViewModelImpl: ParentViewModel {
    var childViewModel = InjectionRegistry.inject(\.childViewModel)
}
```

## SwiftUI + @Observable Compatibility

When using `@Observable` macro, suppress observation tracking on injected properties with `@ObservationIgnored`:

```swift
@Observable final class TrackingViewModelImpl: TrackingViewModel {
    var isTracking: Bool = false                   // observed — triggers view updates

    @ObservationIgnored @Inject(\.sensorDataSource) private var sensor
    @ObservationIgnored @Inject(\.databaseService)  private var db
    // changes to these do NOT trigger view re-renders
}
```

## Scope Selection Guide

| Scope | Use when | Example |
|---|---|---|
| `.singleton` | Shared state, expensive init, hardware/OS resources | database, BLE sensor, recorder |
| `.factory` | Independent instances per consumer, ViewModels with local state | any ViewModel, computation helpers |
| default (`.factory`) | Omit scope param to get factory | `Self.instantiate { Impl() }` |

## Real-World Architecture Pattern (MVVM + DI)

```
InjectionRegistry extension (per file, next to the type)
├── protocol (public)           — contract
├── implementation (private)    — hidden from outside
└── InjectionRegistry extension — registration

Resolution flow:
App Entry Point
└── View (@State via InjectionRegistry.inject)
    └── ViewModel (@Inject property wrappers)
        └── Services (@Inject property wrappers)
            └── Infrastructure singletons
```

Example layered setup:

```swift
// Infrastructure layer (singleton)
extension InjectionRegistry {
    var apiProvider: any ApiProvider {
        Self.instantiate(.singleton) { ApiProviderImpl() }
    }
    var databaseService: any DatabaseService {
        Self.instantiate(.singleton) { DatabaseServiceImpl() }
    }
}

// Domain layer (factory — new per consumer)
extension InjectionRegistry {
    var repository: any Repository {
        Self.instantiate(.factory) { RepositoryImpl() }
        // RepositoryImpl uses @Inject(\.databaseService) internally
    }
}

// UI layer (singleton ViewModel = shared state across views)
extension InjectionRegistry {
    var archiveViewModel: any ArchiveViewModel {
        Self.instantiate(.singleton) { ArchiveViewModelImpl() }
        // ArchiveViewModelImpl uses @Inject(\.repository), @Inject(\.databaseService)
    }
}
```

## Testing

### Mock via #if compiler flag

```swift
// Production (in production file)
extension InjectionRegistry {
    var networkService: any NetworkService {
        Self.instantiate(.singleton) { NetworkServiceImpl() }
    }
}

// Mock (in test target or behind #if USE_MOCK)
#if USE_MOCK
extension InjectionRegistry {
    var networkService: any NetworkService {
        Self.instantiate(.factory) { NetworkServiceMock() }
    }
}
#endif
```

### Singleton reset between tests

```swift
override func setUp() {
    InjectionRegistry.resetSingletons()
}
```

### Inline registration override for unit tests

Register a test double by providing an `extension InjectionRegistry` in the test file — Swift's module system resolves the last declaration, or wrap in `#if DEBUG`.

## Thread Safety

All resolution and instantiation is thread-safe via `NSRecursiveLock`. `@Inject` wrapper lazy-initializes on first access with lock protection. Safe to use from `actor`-isolated types and concurrent code.

## Constraints & Limitations

- Singletons are keyed by **type string** (`"\(T.self)"`). If two different protocols resolve to the same concrete type, they share one singleton slot. Register each as a distinct type.
- No circular dependency detection — circular `@Inject` chains will deadlock due to reentrant locking. Design dependency graph as a DAG.
- `@Inject` caches the resolved value at first access — runtime swapping after first resolution has no effect on already-resolved wrappers.
- No automatic DI container initialization needed — everything is lazily resolved on demand.

## Quick Reference Checklist

When adding a new injectable service:
1. Define a `protocol` for the service
2. Create a `private` (or `internal`) implementation class/actor/struct
3. Add `extension InjectionRegistry` with a computed property returning `any Protocol`
4. Inside, call `Self.instantiate(.singleton|.factory) { Impl() }`
5. For dependencies inside the implementation, use `@Inject(\.depName)` properties
6. For chained deps at registration time, use `Self.inject(\.depName)` inside the getter
7. In SwiftUI views, use `@State private var vm = InjectionRegistry.inject(\.vm)`
8. In `@Observable` classes, add `@ObservationIgnored` before `@Inject`
