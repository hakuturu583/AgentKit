//
//  LLMAgentTest.swift
//  AgentKitTests
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Testing
import AgentKit
import SwiftyBeaver

struct SystemLanguageModelTest {
    var agent = AgentKit.SequentialAgent(name: "sequential_agent",
                                         sub_agents: [
        AgentKit.SystemLanguageModelAgent(logDestination: ConsoleDestination()),
        AgentKit.SystemLanguageModelAgent(instructions: "具体的な山の名称だけを抜き出して",
                                          logDestination: ConsoleDestination())
    ], logDestination: ConsoleDestination())
    
    @Test func ask() async throws {
        let response = try await agent.ask(input: "日本で一番高い山は何山？")
        #expect(response != nil)
        #expect(response == "富士山")
    }
}
