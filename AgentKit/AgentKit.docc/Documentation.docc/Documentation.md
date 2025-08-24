# ``AgentKit``

Composable LLM agents for Apple platforms using the system language model.

AgentKit provides small, focused agents that you can compose to build
interactive reasoning pipelines. Start with a single system-backed agent,
then fan-out in parallel or chain results sequentially.

> Note: Requires a device or simulator with System Language Model support.

## Quick Start

Create a single agent and ask a question. The agent manages a session to the
system language model under the hood.

```swift
import AgentKit
import SwiftyBeaver

let agent = SystemLanguageModelAgent(
  instructions: "Answer with only the mountain name",
  logDestination: ConsoleDestination()
)

guard agent.isAvailable() else { fatalError("SLM not available") }
let answers = try await agent.ask(input: "日本で一番高い山は何山？")
// e.g. ["富士山"]
agent.closeSession()
```

## Sequential Composition

Chain agents when the next step depends on the previous answer.

```swift
import AgentKit
import SwiftyBeaver

let seq = SequentialAgent(
  name: "sequential_agent",
  sub_agents: [
    SystemLanguageModelAgent(logDestination: ConsoleDestination()),
    SystemLanguageModelAgent(
      instructions: "前の回答から具体的な山の名称だけを抜き出して",
      logDestination: ConsoleDestination()
    )
  ],
  logDestination: ConsoleDestination()
)

let result = try await seq.ask(input: "日本で一番高い山は何山？")
// e.g. ["富士山"]
seq.closeSession()
```

## Parallel Composition

Ask multiple agents at once and gather all results.

```swift
import AgentKit
import SwiftyBeaver

let par = ParallelAgent(
  name: "parallel_agent",
  sub_agents: [
    SystemLanguageModelAgent(
      instructions: "答えは英語で山名のみ",
      logDestination: ConsoleDestination()
    ),
    SystemLanguageModelAgent(
      instructions: "答えは日本語で山名のみ",
      logDestination: ConsoleDestination()
    ),
  ],
  logDestination: ConsoleDestination()
)

let responses = try await par.ask(input: "日本で一番高い山は何山？")
// e.g. ["Mount Fuji", "富士山"]
par.closeSession()
```

## Session Management

- Call ``LLMAgent/isAvailable()`` before asking.
- Use ``LLMAgent/createSession()`` and ``LLMAgent/closeSession()`` to manage resources.
- Respect ``LLMAgent/max_system_language_model_sessions`` when composing agents.

## API Reference

- ``LLMAgent``
- ``SystemLanguageModelAgent``
- ``SequentialAgent``
- ``ParallelAgent``
