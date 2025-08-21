//
//  LoopAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/14.
//

import Foundation
import FoundationModels
import SwiftyBeaver

class LoopAgent<LogDestinationType> : SequentialAgent<LogDestinationType> {
    let max_loop : UInt8
    
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
