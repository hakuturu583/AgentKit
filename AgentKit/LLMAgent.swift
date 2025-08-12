//
//  LLMAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import FoundationModels

public protocol LLMAgent {
    var name: String { get }
    var is_running: Bool { get }
    // var num_system_model_sessions : UInt8 { get }
    
    func isAvailable() -> Bool
    func ask(
        input: String,
        generationOptions: GenerationOptions) async throws -> Array<String>
}
