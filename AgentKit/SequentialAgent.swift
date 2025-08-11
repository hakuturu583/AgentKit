//
//  SequentialAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import SwiftyBeaver

public class SequentialAgent<LogDestinationType> : LLMAgent {
    public var name: String
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
    
    public func ask(input: String) async throws -> String? {
        var prompt = input
        for (index, agent) in sub_agents.enumerated() {
            if index == sub_agents.count - 1 {
                guard let response = try await agent.ask(input: prompt) else { return nil }
                return response
            } else {
                guard let response = try await agent.ask(input: prompt) else {
                    return nil
                }
                prompt = response
            }
        }
        return nil
    }
}
