//
//  ParallelAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import FoundationModels
import SwiftyBeaver

public class ParallelAgent<LogDestinationType> : LLMAgent {
    public var name: String
    public var is_running: Bool = false
    public var num_system_model_sessions:UInt8 = 0
    let sub_agents: Array<LLMAgent>
    private var log = SwiftyBeaver.self
    
    public init(name: String, sub_agents: Array<LLMAgent> = [], logDestination: LogDestinationType) {
        self.name = name
        self.sub_agents = sub_agents
        self.log.addDestination(logDestination as! BaseDestination)
        self.log.info("ParallelAgent \(name) initialized.")
    }
    
    public func isAvailable() -> Bool {
        return self.sub_agents.allSatisfy {$0.isAvailable()}
    }
    
    public func ask(
        input: String,
        generationOptions: GenerationOptions = GenerationOptions(temperature: 0.0)) async throws -> [String] {
        // Launch all sub-agent asks in parallel using async lets
        var results = [[String]]()
        is_running = true
        try await withThrowingTaskGroup(of: [String].self) { group in
            for agent in sub_agents {
                group.addTask {
                    try await agent.ask(input: input, generationOptions:  generationOptions)
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
