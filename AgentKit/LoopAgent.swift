//
//  LoopAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/14.
//

import Foundation
import FoundationModels
import SwiftyBeaver

/// Agent that repeats the ``SequentialAgent`` pipeline a specified number of times.
///
/// Each iteration runs the same sequential pipeline with the original input and returns the last result.
/// - Generic parameter: `LogDestinationType` must be a ``SwiftyBeaver/BaseDestination``.
///   Choose any destination you prefer (e.g., `ConsoleDestination`, `FileDestination`)
///   by referring to the SwiftyBeaver API Reference.
///
/// Example
/// ```swift
/// import AgentKit
/// import SwiftyBeaver
///
/// let loop = LoopAgent(
///   name: "loop_agent",
///   sub_agents: [
///     SystemLanguageModelAgent(
///       instructions: "日本で一番高い山を答えて",
///       logDestination: ConsoleDestination()
///     ),
///     SystemLanguageModelAgent(
///       instructions: "前の回答から山名のみを抽出して",
///       logDestination: ConsoleDestination()
///     )
///   ],
///   logDestination: ConsoleDestination(),
///   max_system_language_model_sessions: 8,
///   max_loop: 3
/// )
///
/// let result = try await loop.ask(input: "日本で一番高い山は何山？")
/// // e.g. ["富士山"]
/// loop.closeSession()
/// ```
class LoopAgent<LogDestinationType> : SequentialAgent<LogDestinationType> {
    /// Maximum number of iterations.
    let max_loop : UInt8
    
    /// Initializes a looping sequential agent.
    /// - Parameters:
        ///   - name: Agent name.
        ///   - sub_agents: Child agents executed in sequence.
    ///   - logDestination: SwiftyBeaver log destination. Choose any `BaseDestination`
    ///     you prefer by referring to the SwiftyBeaver API Reference.
        ///   - max_system_language_model_sessions: Max concurrent session count.
        ///   - max_loop: Number of loop iterations.
    public init(
        name: String,
        sub_agents: Array<LLMAgent> = [],
        logDestination: LogDestinationType,
        max_system_language_model_sessions: UInt8 = 8,
        max_loop: UInt8 = 1
    ) {
        self.max_loop = max_loop
        super.init(name: name,
                   sub_agents: sub_agents,
                   logDestination: logDestination,
                   max_system_language_model_sessions: max_system_language_model_sessions)
    }
    
    /// Repeats the sequential pipeline for the given number of iterations and returns the last result.
    public override func ask(
        input: String,
        generationOptions: GenerationOptions = GenerationOptions(temperature: 0.0)) async throws -> [String] {
        var answer: [String] = []
        for(i, _) in (0..<Int(self.max_loop)).enumerated() {
            answer = try await super.ask(input: input, generationOptions: generationOptions)
        }
        return answer
    }
}
