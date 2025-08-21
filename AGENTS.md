# Repository Guidelines

## Project Structure & Module Organization
- `AgentKit/`: Library source (agents, protocols). Includes `AgentKit.docc` for docs.
- `AgentKitTests/`: Test targets using the Swift `Testing` framework.
- `Package.swift`: SwiftPM manifest (library product `AgentKit`).
- `AgentKit.xcodeproj/`: Xcode project for IDE users.

## Build, Test, and Development Commands
- `swift package resolve`: Fetches dependencies (FoundationModels, SwiftyBeaver).
- `swift build` / `swift build -c release`: Builds the library (debug/release).
- `swift test -v`: Runs all tests with verbose output.
- Xcode: open `AgentKit.xcodeproj` and use Product > Build/Test, or run `xcodebuild -project AgentKit.xcodeproj -scheme AgentKit test`.

## Coding Style & Naming Conventions
- Swift 5.9; use 4‑space indentation, no trailing whitespace, 120‑char soft wrap.
- Types: UpperCamelCase (`SequentialAgent`); methods/properties: lowerCamelCase.
- Follow existing public API names as-is (some properties use snake_case for compatibility).
- One type per file; filename matches type (`ParallelAgent.swift`).
- Prefer protocols and value semantics where reasonable; document public APIs.

## Testing Guidelines
- Framework: `Testing` with `@Test` functions and `#expect` assertions.
- Location: tests in `AgentKitTests/`, filenames end with `*Test.swift` (e.g., `ParallelAgentTest.swift`).
- Scope: add unit tests for new behavior; keep tests deterministic (mock logging if needed).
- Run: `swift test` locally before pushing; ensure sessions are closed (`closeSession()`) in tests.

## Commit & Pull Request Guidelines
- Commits: use imperative, concise subjects (e.g., "Add SequentialAgent session control").
- Reference issues with `#123` when applicable; keep related changes together.
- PRs: include a clear description, rationale, testing notes/outputs, and any API changes. Add examples if affecting agent composition.

## Agent-Specific Notes
- Availability: check `isAvailable()` before `ask(input:)`.
- Sessions: manage lifecycle with `createSession()`/`closeSession()`; respect `max_system_language_model_sessions`.
- Composition: use `SequentialAgent` for chaining and `ParallelAgent` for fan‑out.
- Example:
  ```swift
  let agent = SystemLanguageModelAgent(instructions: "Return only the mountain name",
                                       logDestination: ConsoleDestination())
  let answers = try await agent.ask(input: "日本で一番高い山は？")
  ```
