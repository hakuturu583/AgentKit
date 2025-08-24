//
//  LLMAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import FoundationModels

/// Common protocol for agents that query a language model.
///
/// Conformers manage the session lifecycle (create/close) and implement
/// `ask(input:generationOptions:)` to produce responses for a given input.
public protocol LLMAgent {
    /// Logical identifier for the agent.
    var name: String { get }

    /// Whether the agent is currently running a request.
    /// - Note: Used to coordinate parallel execution and when to close sessions.
    var is_running: Bool { get }

    /// Number of System Language Model sessions currently held by this agent.
    var num_system_language_model_sessions : UInt8 { get }

    /// Maximum number of allowed System Language Model sessions.
    /// Used for resource control in composite agents (``SequentialAgent``/``ParallelAgent``).
    var max_system_language_model_sessions : UInt8 { get }
    
    /// Returns whether the underlying model is available.
    func isAvailable() -> Bool

    /// Creates a session.
    func createSession() -> Void

    /// Closes a session.
    func closeSession() -> Void

    /// Generates responses for the given input.
    /// - Parameters:
    ///   - input: Input string for the model.
    ///   - generationOptions: Options used during generation (e.g. temperature).
    /// - Returns: Array of generated response strings.
    func ask(
        input: String,
        generationOptions: GenerationOptions) async throws -> Array<String>

    /// Returns the number of SLM sessions currently held.
    func getSystemLanguageModelSessions() -> UInt8
}
