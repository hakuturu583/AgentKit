//
//  ParallelAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import FoundationModels
import SwiftyBeaver

/// Agent that runs multiple ``LLMAgent`` instances concurrently and merges results.
///
/// - Generic parameter: `LogDestinationType` must be a ``SwiftyBeaver/BaseDestination``.
///   Choose any destination you prefer (e.g., `ConsoleDestination`, `FileDestination`)
///   by referring to the SwiftyBeaver API Reference.
///
/// Example
/// ```swift
/// import AgentKit
/// import SwiftyBeaver
///
/// let par = ParallelAgent(
///   name: "parallel_agent",
///   sub_agents: [
///     SystemLanguageModelAgent(
///       instructions: "答えは英語で山名のみ",
///       logDestination: ConsoleDestination()
///     ),
///     SystemLanguageModelAgent(
///       instructions: "答えは日本語で山名のみ",
///       logDestination: ConsoleDestination()
///     ),
///   ],
///   logDestination: ConsoleDestination()
/// )
///
/// let responses = try await par.ask(input: "日本で一番高い山は何山？")
/// // e.g. ["Mount Fuji", "富士山"]
/// par.closeSession()
/// ```
public class ParallelAgent<LogDestinationType> : LLMAgent {
    /// Agent name.
    public var name: String
    /// Whether a request is in-flight.
    public var is_running: Bool = false
    /// Number of SLM sessions held by this agent.
    public var num_system_language_model_sessions:UInt8 = 0
    /// Maximum allowed SLM sessions.
    public var max_system_language_model_sessions: UInt8 = 1
    /// Child agents executed in parallel.
    let sub_agents: Array<LLMAgent>
    private var log = SwiftyBeaver.self
    
    /// Initializes a parallel agent.
    /// - Parameters:
        ///   - name: Agent name.
        ///   - sub_agents: Child agents to run concurrently.
    ///   - logDestination: SwiftyBeaver log destination. Choose any `BaseDestination`
    ///     you prefer by referring to the SwiftyBeaver API Reference.
    public init(name: String, sub_agents: Array<LLMAgent> = [], logDestination: LogDestinationType) {
        self.name = name
        self.sub_agents = sub_agents
        self.log.addDestination(logDestination as! BaseDestination)
        self.log.info("ParallelAgent \(name) initialized.")
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
    
    /// Asks all child agents concurrently and returns a flattened array of results.
    /// - Parameters:
    ///   - input: Input passed to all child agents.
    ///   - generationOptions: Generation options.
    /// - Returns: Concatenated results from all child agents.
    public func ask(
        input: String,
        generationOptions: GenerationOptions = GenerationOptions(temperature: 0.0)) async throws -> [String] {
        // Launch all sub-agent asks in parallel using async lets
        var results = [[String]]()
        is_running = true
        try await withThrowingTaskGroup(of: [String].self) { group in
            for agent in sub_agents {
                group.addTask {
                    if(self.getSystemLanguageModelSessions() > self.max_system_language_model_sessions) {
                        // self.closeSession()
                    }
                    return try await agent.ask(input: input, generationOptions:  generationOptions)
                }
            }
            for try await result in group {
                results.append(result)
            }
        }
        is_running = false
        // Flatten and return
        return results.flatMap { $0 }
    }
}
