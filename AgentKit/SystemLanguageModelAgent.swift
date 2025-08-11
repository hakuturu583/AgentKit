//
//  LLMAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import FoundationModels
import SwiftyBeaver

public class SystemLanguageModelAgent<LogDestinationType> : LLMAgent {
    public var name: String
    private let model: SystemLanguageModel
    private var session: LanguageModelSession
    private var log = SwiftyBeaver.self
    
    public init(name: String = UUID().uuidString.lowercased(),
                instructions: String = "",
                logDestination: LogDestinationType) {
        self.name = name
        self.model = SystemLanguageModel.default
        self.session = LanguageModelSession(model: model, instructions: instructions)
        self.log.addDestination(logDestination as! BaseDestination)
        self.log.info("SystemLanguageModelAgent \(name) initialized.")
    }
    
    public func isAvailable() -> Bool {
        if(!model.isAvailable) {
            self.log.error("System Language Model is not available.")
        }
        return model.isAvailable
    }
    
    public func ask(
        input: String,
        generationOptions: GenerationOptions = GenerationOptions(temperature: 0.0)) async throws -> [String] {
        if !isAvailable() { return [] }
        let llm_response = try await session.respond(
            options: generationOptions,
            prompt: { Prompt(input) }
        )
        logTranscript()
        return [llm_response.content]
    }
    
    private func logTranscript() {
        self.log.info("Agent name:\(name) Transcript: \(session.transcript)")
    }
}
