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
    public var is_running: Bool = false
    public var num_system_language_model_sessions: UInt8 = 0
    private let model: SystemLanguageModel
    private var session: LanguageModelSession?
    private var instructions: String
    private var log = SwiftyBeaver.self
    
    public init(name: String = UUID().uuidString.lowercased(),
                instructions: String = "",
                logDestination: LogDestinationType) {
        self.name = name
        self.model = SystemLanguageModel.default
        self.instructions = instructions
        self.session = nil
        self.log.addDestination(logDestination as! BaseDestination)
        self.log.info("SystemLanguageModelAgent \(name) initialized.")
    }
    
    public func isAvailable() -> Bool {
        if(!model.isAvailable) {
            self.log.error("System Language Model is not available.")
        }
        return model.isAvailable
    }
    
    private func createSession() {
        num_system_language_model_sessions = 1
        session = LanguageModelSession(model: model, instructions: instructions)
        self.log.info("Session created for agent \(name)")
    }
    
    public func ask(
        input: String,
        generationOptions: GenerationOptions = GenerationOptions(temperature: 0.0)) async throws -> [String] {
        if !isAvailable() { return [] }
        
        if session == nil {
            createSession()
        }
        
        guard let session = session else {
            self.log.error("Failed to create session for agent \(name)")
            return []
        }
        
        is_running = true
        let llm_response = try await session.respond(
            options: generationOptions,
            prompt: { Prompt(input) }
        )
        is_running = false
        logTranscript()
        return [llm_response.content]
    }
    
    private func logTranscript() {
        guard let session = session else {
            self.log.warning("No session available for transcript logging")
            return
        }
        self.log.info("Agent name:\(name) Transcript: \(session.transcript)")
    }
}
