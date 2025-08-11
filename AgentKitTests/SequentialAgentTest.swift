//
//  SequentialAgentTest.swift
//  AgentKitTests
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Testing
import AgentKit
import SwiftyBeaver

struct SequentialAgentTest {
    var agent = AgentKit.SystemLanguageModelAgent(logDestination: ConsoleDestination())

    @Test func ask() async throws {
        let response = try await agent.ask(input: "日本で一番高い山は何山？")
        #expect(response != nil)
        #expect(response!.contains("富士山"))
    }
}
