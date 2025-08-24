//
//  SequentialAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import FoundationModels
import SwiftyBeaver

/// Agent that executes multiple ``LLMAgent`` instances in order,
/// passing each stage's first response to the next stage as input.
///
/// - Generic parameter: `LogDestinationType` must be a ``SwiftyBeaver/BaseDestination``.
///   Choose any destination you prefer (e.g., `ConsoleDestination`, `FileDestination`)
///   by referring to the SwiftyBeaver API Reference.
public class SequentialAgent<LogDestinationType> : LLMAgent {
    /// Agent name.
    public var name: String
    /// Whether a request is in-flight.
    public var is_running = false
    /// Number of SLM sessions held by this agent.
    public var num_system_language_model_sessions: UInt8 = 0
    /// Maximum allowed SLM sessions.
    public var max_system_language_model_sessions: UInt8 = 8
    /// Child agents executed sequentially.
    let sub_agents: Array<LLMAgent>
    private var log = SwiftyBeaver.self
    
    /// Initializes a sequential agent.
    /// - Parameters:
        ///   - name: Agent name.
        ///   - sub_agents: Child agents to execute in order.
    ///   - logDestination: SwiftyBeaver log destination. Choose any `BaseDestination`
    ///     you prefer by referring to the SwiftyBeaver API Reference.
    ///   - max_system_language_model_sessions: Max concurrent session count.
    public init(
        name: String,
        sub_agents: Array<LLMAgent> = [],
        logDestination: LogDestinationType,
        max_system_language_model_sessions: UInt8 = 8) {
        self.name = name
        self.sub_agents = sub_agents
        self.log.addDestination(logDestination as! BaseDestination)
        self.log.info("SequentialAgent \(name) initialized.")
        self.max_system_language_model_sessions = max_system_language_model_sessions
    }
    
    /// Returns true when all child agents are available.
    public func isAvailable() -> Bool {
        return self.sub_agents.allSatisfy {$0.isAvailable()}
    }
    
    /// Creates sessions on all child agents.
    public func createSession() -> Void
    {
        for agent in sub_agents {
            agent.createSession()
        }
    }
    
    /// Closes sessions for child agents that are not currently running.
    public func closeSession() -> Void
    {
        for agent in sub_agents {
            if(!agent.is_running) {
                agent.closeSession()
            }
        }
    }
    
    /// Returns the total number of SLM sessions held by child agents.
    public func getSystemLanguageModelSessions() -> UInt8 {
        var num_sessions: UInt8 = 0
        for agent in sub_agents {
            num_sessions = num_sessions + agent.getSystemLanguageModelSessions()
        }
        return num_sessions
    }
    
    /// Executes child agents in order, passing the first response from each stage to the next.
    /// - Parameters:
    ///   - input: Input for the first child agent.
    ///   - generationOptions: Generation options.
    /// - Returns: Responses from the final stage. Intermediate stages pass only the first element forward.
    public func ask(
        input: String,
        generationOptions: GenerationOptions = GenerationOptions(temperature: 0.0)) async throws -> Array<String> {
        var prompt = input
        is_running = true
        for (index, agent) in sub_agents.enumerated() {
            while(getSystemLanguageModelSessions() > self.max_system_language_model_sessions) {
                self.closeSession()
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
            let responses = try await agent.ask(input: prompt, generationOptions: generationOptions)
            if index == sub_agents.count - 1 {
                return responses
            } else {
                guard let response = responses.first else {
                    return []
                }
                prompt = response
            }
        }
        is_running = false
        return []
    }
}
