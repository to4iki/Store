# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Scratchpad & Checklist Organization System
### Directory Structure
```
claude/
├── work/                    # Active work files
│   ├── checklists/         # Task tracking files
│   ├── active/             # Currently being worked on
│   └── archive/            # Completed (kept for reference)
├── scratchpads/            # Temporary working files
│   ├── findings/           # Research and analysis results
│   ├── plans/              # Implementation plans
│   └── temp/               # Very temporary files (auto-cleaned)
├── agents/                 # Inter-agent communication
│   ├── shared/             # Shared findings between agents
│   └── handoffs/           # Task handoff files
├── templates/              # Reusable templates
└── logs/                   # Historical records
```

## Development Commands

### Testing
```bash
make test                    # Run all tests with parallel execution
swift test --package-path Store --parallel
```

### Code Formatting
```bash
make format                  # Format all Swift code in Store/ and Example.swiftpm/
```

### Building
```bash
# Build the Swift package
swift build --package-path Store

# Build example app (Swift Playgrounds)
# Open Example.swiftpm in Xcode or Swift Playgrounds
```

## Architecture Overview

This is a Zustand-inspired state management library for Swift/SwiftUI with the following key architectural components:

### Core Store System
- **Store**: Main state container with iOS 17+ `@Observable` support and iOS 16 fallback using `@Published`
- **StateSet/StateUpdater**: Functional state updating mechanism using inout parameters for efficient mutations
- **createStore()**: Factory function that creates store instances with actions, following Zustand's pattern

### Slice Pattern Implementation
- **Slice Protocol**: Modular state management allowing composition of independent state slices
- **CombinedState/CombinedActions**: Combines multiple slices with `@dynamicMemberLookup` for flat property access
- **createStoreWithSlices()**: Factory for combining slice instances into unified stores
- **CrossSliceActions**: Protocol for actions that operate across multiple slices (e.g., slice interactions)

### Middleware System
- **Middleware Protocol**: Interceptor pattern for state updates with `apply(currentState:next:)` method
- **SimplePrintMiddleware**: Built-in logging middleware for debugging
- Middleware chains applied in reverse order during store creation

### Key Design Patterns
- **Flat Access**: `@dynamicMemberLookup` enables Zustand-like direct property access on combined states/actions
- **Type Safety**: Heavy use of associated types and generics to maintain compile-time safety
- **MainActor**: All state updates are bound to MainActor for SwiftUI compatibility
- **Sendable**: All state types must be Sendable for concurrency safety

### Project Structure
- `Store/Sources/Store/`: Core library implementation
- `Example.swiftpm/`: Swift Playgrounds examples demonstrating usage patterns
- Both single-store patterns (CounterView) and slice composition (SimpleBearFishView) are demonstrated

The library bridges Zustand's JavaScript patterns to Swift's type system while maintaining SwiftUI integration and iOS version compatibility.
