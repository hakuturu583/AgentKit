# ``AgentKit``

Composable LLM agents for Apple platforms using the system language model.

AgentKit provides small, focused agents that you can compose to build
interactive reasoning pipelines. Start with a single system-backed agent,
then fan-out in parallel or chain results sequentially.

> Note: Requires a device or simulator with System Language Model support.

## Quick Start

Create a single agent and ask a question. See ``SystemLanguageModelAgent`` for a full example.

## Sequential Composition

Chain agents when the next step depends on the previous answer. See ``SequentialAgent`` for an example.

## Parallel Composition

Ask multiple agents at once and gather all results. See ``ParallelAgent`` for an example.

## Session Management

- Call ``LLMAgent/isAvailable()`` before asking.
- Use ``LLMAgent/createSession()`` and ``LLMAgent/closeSession()`` to manage resources.
- Respect ``LLMAgent/max_system_language_model_sessions`` when composing agents.

## API Reference

- ``LLMAgent``
- ``SystemLanguageModelAgent``
- ``SequentialAgent``
- ``ParallelAgent``
