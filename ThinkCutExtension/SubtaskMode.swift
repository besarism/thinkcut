//
//  SubtaskMode.swift
//  ThinkCutExtension
//
//  Created by Besar Ismaili on 08/04/2025.
//

import Foundation

enum SubtaskMode {
    case design
    case coding
    case debugging
    case documentation
    
    /// Returns the 'system' prompt for each specialized mode.
    var systemPrompt: String {
        switch self {
        case .design:
            return """
            You are a Software Architect assistant. You plan solutions in detail.
            Your role: produce a design or architecture outline, including module breakdown,
            recommended patterns, and relevant pseudocode or steps. Do NOT write full code.
            """
        case .coding:
            return """
            You are a Swift coding assistant. You write concise, efficient Swift code
            following best practices. You output code or short explanations only.
            """
        case .debugging:
            return """
            You are a Debugging assistant. You diagnose and fix issues in Swift code.
            You explain the problem and provide corrected code or instructions.
            """
        case .documentation:
            return """
            You are a Documentation writer assistant. You generate documentation or readmes
            explaining code usage, functionality, and examples in clear Markdown format.
            """
        }
    }
    
    /// An optional short name for logging or references.
    var displayName: String {
        switch self {
        case .design:        return "Design"
        case .coding:        return "Coding"
        case .debugging:     return "Debugging"
        case .documentation: return "Documentation"
        }
    }
}
