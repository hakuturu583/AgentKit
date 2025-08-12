//
//  SequentialAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import FoundationModels
import SwiftyBeaver

public class SequentialAgent<LogDestinationType> : LLMAgent {
    public var name: String
    public var is_running = false
    public var num_system_language_model_sessions: UInt8 = 0
    let sub_agents: Array<LLMAgent>
    private var log = SwiftyBeaver.self
    
    public init(name: String, sub_agents: Array<LLMAgent> = [], logDestination: LogDestinationType) {
        self.name = name
        self.sub_agents = sub_agents
        self.log.addDestination(logDestination as! BaseDestination)
        self.log.info("SequentialAgent \(name) initialized.")
    }
    
    public func isAvailable() -> Bool {
        return self.sub_agents.allSatisfy {$0.isAvailable()}
    }
    
    public func ask(
        input: String,
        generationOptions: GenerationOptions = GenerationOptions(temperature: 0.0)) async throws -> Array<String> {
        var prompt = input
        is_running = true
        for (index, agent) in sub_agents.enumerated() {
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
