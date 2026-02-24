# SwiftInjectLite

> 💉 A minimal, compile-time-safe dependency injection framework for Swift. Based on KeyPaths. No reflection. No magic.

SwiftInjectLite provides a pragmatic approach to dependency injection in Swift using pure Swift features like `KeyPath`. It enforces **compile-time validation**, avoiding runtime surprises or misconfigurations.  
Perfect for developers who want clarity, type safety, and simplicity — with zero boilerplate.

---

## 📦 Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/drIGunDev/SwiftInjectLite.git", from: "1.1.0")
```

Or via Xcode:

1. File → Add Packages…
2. Enter repository URL
3. Choose your version and target

---

## 🚀 Basic Usage

### 1. Define protocols and implementations

```swift
protocol Animal: AnyObject {
    var name: String { get }
}

protocol Cat: Animal {}
protocol Dog: Animal {}

class CatIml: Cat {
    let name: String
    init(name: String) { self.name = name }
}

class DogIml: Dog {
    let name: String
    init(name: String) { self.name = name }
}
```

### 2. Register dependencies in `InjectionRegistry`

```swift
extension InjectionRegistry {
    var cat: Cat {
        Self.instantiate(.factory) { CatIml(name: "Mia") }
    }

    var dog: Dog {
        Self.instantiate(.factory) { DogIml(name: "Max") }
    }
}
```

### 3. Inject using `@Inject`

```swift
class PetOwner {
    @Inject(\.cat) var cat
    @Inject(\.dog) var dog

    func play() -> String {
        "I'm playing with \(cat.name) and \(dog.name)"
    }
}
```

### 4. Register composite dependencies

```swift
extension InjectionRegistry {
    var petOwner: PetOwner {
        Self.instantiate(.factory) { PetOwner() }
    }
}
```

---

## 🔗 Chained Dependencies

When a service depends on another registered service, resolve it via `Self.inject()` inside the registration getter:

```swift
extension InjectionRegistry {
    var apiProvider: any ApiProvider {
        Self.instantiate(.singleton) { ApiProviderImpl() }
    }

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

---

## 🔁 Scopes

- `.factory`: creates a new instance each time
- `.singleton`: reuses a shared instance

Scope selection guide:

| Scope | Use when |
|---|---|
| `.singleton` | Shared state, expensive init, hardware resources (database, BLE, recorder) |
| `.factory` | Independent instances per consumer, ViewModels with local state |

---

## 🍎 SwiftUI Integration

### Resolving into `@State`

Use `InjectionRegistry.inject()` directly when initializing SwiftUI state:

```swift
struct ArchiveView: View {
    @State private var viewModel = InjectionRegistry.inject(\.archiveViewModel)

    var body: some View {
        List(viewModel.items) { ... }
    }
}
```

### `@Observable` + `@Inject` Compatibility

When using the `@Observable` macro, mark injected dependencies with `@ObservationIgnored` to prevent unnecessary view re-renders:

```swift
@Observable final class TrackingViewModelImpl: TrackingViewModel {
    var isTracking: Bool = false  // triggers view updates

    @ObservationIgnored @Inject(\.sensorDataSource) private var sensor
    @ObservationIgnored @Inject(\.databaseService) private var db
}
```

---

## 🧪 Test Cases

These test scenarios demonstrate SwiftInjectLite in action:

### ✅ Injection works

```swift
@Inject(\.petOwner) var owner

#expect(owner.cat.name == "Mia")
#expect(owner.dog.name == "Max")
#expect(owner.play() == "I'm playing with Mia and Max")
```

### 🧪 Factory scope returns new instances

```swift
@Inject(\.cat) var cat1
@Inject(\.cat) var cat2

#expect(!(cat1 === cat2))
```

### 🧠 Singleton scope returns the same instance

```swift
protocol Circus: AnyObject {
    var animals: [Animal] { get }
}

class CircusIml: Circus {
    @Inject(\.cat) var cat
    @Inject(\.dog) var dog

    var animals: [Animal] { [cat, dog] }
}

extension InjectionRegistry {
    var circus: Circus {
        Self.instantiate(.singleton) { CircusIml() }
    }
}

@Inject(\.circus) var circus1
@Inject(\.circus) var circus2

#expect(circus1 === circus2)
```

### ✅ Singleton reset between tests

```swift
override func setUp() {
    InjectionRegistry.resetSingletons()
}
```

---

## 🧪 Mock Support

You can conditionally register mocks via `#if USE_MOCK` for testing:

```swift
#if USE_MOCK
class CatMockIml: Cat {
    let name: String
    init(name: String) { self.name = name }
}

extension InjectionRegistry {
    var cat: Cat {
        Self.instantiate(.factory) { CatMockIml(name: "MockMia") }
    }
}
#endif
```

This allows seamless switching between real and mock implementations without touching production code.

---

## 💡 Philosophy

SwiftInjectLite does not aim to be a full-featured DI framework with graphs, containers, or runtime resolution.  
Instead, it focuses on **compile-time safety**, **clarity**, and **simplicity** — everything you need for robust injection without overhead.

---

## 📄 License

MIT © Igor Gun
