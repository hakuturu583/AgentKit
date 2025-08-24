//
//  LLMAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import FoundationModels
import SwiftyBeaver

/// Single agent backed by Apple's ``FoundationModels/SystemLanguageModel``.
///
/// Manages session creation/closure and generates responses with optional instructions.
/// - Generic parameter: `LogDestinationType` must be a ``SwiftyBeaver/BaseDestination``.
///   Choose any destination you prefer (e.g., `ConsoleDestination`, `FileDestination`)
///   by referring to the SwiftyBeaver API Reference.
///
/// Example
/// ```swift
/// import AgentKit
/// import SwiftyBeaver
///
/// let agent = SystemLanguageModelAgent(
///   instructions: "Answer with only the mountain name",
///   logDestination: ConsoleDestination()
/// )
///
/// guard agent.isAvailable() else { fatalError("SLM not available") }
/// let answers = try await agent.ask(input: "日本で一番高い山は何山？")
/// // e.g. ["富士山"]
/// agent.closeSession()
/// ```
public class SystemLanguageModelAgent<LogDestinationType> : LLMAgent {
    /// Agent name. Defaults to a lowercased UUID.
    public var name: String
    /// Whether a request is in-flight.
    public var is_running: Bool = false
    /// Number of SLM sessions held by this agent.
    public var num_system_language_model_sessions: UInt8 = 0
    /// Maximum allowed SLM sessions.
    public var max_system_language_model_sessions: UInt8 = 8
    /// Default system language model.
    private let model: SystemLanguageModel
    /// Active language model session.
    private var session: LanguageModelSession?
    /// Instructions passed to the session.
    private var instructions: String
    private var log = SwiftyBeaver.self
    
    /// Initializes a system language model agent.
    /// - Parameters:
        ///   - name: Agent name (defaults to UUID).
        ///   - instructions: System instructions for the model.
    ///   - logDestination: SwiftyBeaver log destination. Choose any `BaseDestination`
    ///     you prefer by referring to the SwiftyBeaver API Reference.
        ///   - max_system_language_model_sessions: Max concurrent session count.
    public init(name: String = UUID().uuidString.lowercased(),
                instructions: String = "",
                logDestination: LogDestinationType,
                max_system_language_model_sessions: UInt8 = 8) {
        self.name = name
        self.model = SystemLanguageModel.default
        self.instructions = instructions
        self.session = nil
        self.log.addDestination(logDestination as! BaseDestination)
        self.log.info("SystemLanguageModelAgent \(name) initialized.")
        self.max_system_language_model_sessions = max_system_language_model_sessions
    }
    
    /// Returns whether the model is available. Logs an error if unavailable.
    public func isAvailable() -> Bool {
        if(!model.isAvailable) {
            self.log.error("System Language Model is not available.")
        }
        return model.isAvailable
    }
    
    /// Creates a language model session.
    public func createSession() {
        num_system_language_model_sessions = 1
        session = LanguageModelSession(model: model, instructions: instructions)
        self.log.info("Session created for agent \(name)")
    }
    
    /// Closes the language model session. Does not close while responding.
    public func closeSession() {
        guard let session = self.session else { return }
        if(session.isResponding) {
            self.log.info("Agent \(name) is now responding, so do not close session.")
            return
        }
        self.num_system_language_model_sessions = 0
        self.session = nil
        self.log.info("Session closed for agent \(name)")
    }
    
    /// Returns the number of SLM sessions currently held.
    public func getSystemLanguageModelSessions() -> UInt8 {
        return self.num_system_language_model_sessions
    }
    
    /// Generates a response for the given input.
    /// - Parameters:
    ///   - input: Input string.
    ///   - generationOptions: Options for generation.
    /// - Returns: Array containing a single generated response.
    public func ask(
        input: String,
        generationOptions: GenerationOptions = GenerationOptions(temperature: 0.0)) async throws -> [String] {
        if !isAvailable() { return [] }
        
        if session == nil {
            createSession()
        }
        
        guard let session = session else {
            self.log.error("Failed to create session for agent \(name)")
            return []
        }
        
        self.is_running = true
        let llm_response = try await session.respond(
            options: generationOptions,
            prompt: { Prompt(input) }
        )
        self.is_running = false
        logTranscript()
        return [llm_response.content]
    }
    
    /// Logs the transcript of the most recent session.
    private func logTranscript() {
        guard let session = session else {
            self.log.warning("No session available for transcript logging")
            return
        }
        self.log.info("Agent name:\(name) Transcript: \(session.transcript)")
    }
}
