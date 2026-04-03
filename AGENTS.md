# Store

A lightweight state management library for Swift, inspired by Zustand.
It simplifies Flux principles and is designed for seamless SwiftUI integration.

## Directory Structure

```
Sources/Store/
├── Store.swift                    # Store core and createStore
├── Set.swift                      # StateSet (state updates, scoped, replace)
├── Slice.swift                    # Slice protocol
└── Middleware/                    # Middleware protocol and implementations
Tests/StoreTests/                  # Unit tests for each feature
docs/                              # Detailed documentation
Example.swiftpm/                   # Swift Playgrounds sample app
```

## Development

```bash
make test     # Run tests
make build    # Build
```
