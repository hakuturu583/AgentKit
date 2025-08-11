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
    var agent = AgentKit.SystemLanguageModelAgent(logDestination: ConsoleDestination())
    
    @Test func ask() async throws {
        let response = try await agent.ask(input: "日本で一番高い山は何山？")
        #expect(!response.isEmpty)
        #expect(response.count == 1)
        #expect(response[0].contains("富士山"))
    }
}
