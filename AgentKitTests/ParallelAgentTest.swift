//
//  ParallelAgentTest.swift
//  AgentKitTests
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Testing
import Foundation
import AgentKit
import SwiftyBeaver

struct ParallelAgentTest {
    var agent = AgentKit.ParallelAgent(name: "parallel_agent",
                                         sub_agents: [
                                            AgentKit.SystemLanguageModelAgent(instructions: "具体的な山の名称だけを英語で答えて",
                                                                              logDestination: ConsoleDestination()),
                                            AgentKit.SystemLanguageModelAgent(instructions: "具体的な山の名称だけを日本語で答えて",
                                                                              logDestination: ConsoleDestination())
                                         ], logDestination: ConsoleDestination())
    
        @Test func ask() async throws {
            let response = try await agent.ask(input: "日本で一番高い山は何山？")
            #expect(!response.isEmpty)
            #expect(response.count == 2)
            #expect(response[0].contains("Fuji") || response[0].contains("富士山"))
            #expect(response[1].contains("富士山") || response[1].contains("Fuji"))
        }
}
