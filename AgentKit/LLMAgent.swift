//
//  LLMAgent.swift
//  AgentKit
//
//  Created by 片岡大哉 on 2025/08/11.
//

import Foundation
import SwiftyBeaver

public protocol LLMAgent {
    var name: String { get }
    
    func isAvailable() -> Bool
    func ask(input: String) async throws -> Array<String>
}
