//
//  Orchestrator.swift
//  ThinkCutExtension
//
//  Created by Besar Ismaili on 08/04/2025.
//

import Foundation

class Orchestrator {
    
    private var subtasks: [Subtask]
    private let anthropicService: AnthropicService
    
    init(subtasks: [Subtask], anthropicService: AnthropicService) {
        self.subtasks = subtasks
        self.anthropicService = anthropicService
    }
    
    /// Runs all subtasks in sequence.
    /// In a real extension, you'd want to handle this asynchronously.
    func runAllSubtasks(completion: @escaping ([Subtask]) -> Void) {
        runSubtask(at: 0, completion: completion)
    }
    
    private func runSubtask(at index: Int, completion: @escaping ([Subtask]) -> Void) {
        guard index < subtasks.count else {
            // Finished all subtasks
            completion(subtasks)
            return
        }
        
        var subtask = subtasks[index]
        let mode = subtask.mode
        
        print("Starting subtask \(index + 1)/\(subtasks.count) [\(mode.displayName)]...")
        
        anthropicService.sendRequest(
            systemPrompt: mode.systemPrompt,
            userPrompt: subtask.input
        ) { result in
            switch result {
            case .success(let aiOutput):
                // Store the full output
                subtask.output = aiOutput
                
                // Optionally we can get a short summary
                // We'll do a second API call or just parse inline for brevity
                // Here, let's just keep the first 120 chars as a naive summary:
                let shortSummary = aiOutput.prefix(120) + (aiOutput.count > 120 ? "..." : "")
                subtask.summary = String(shortSummary)
                
                // Update our array
                self.subtasks[index] = subtask
                print("Subtask \(index + 1) complete. Summary: \(subtask.summary ?? "")")
                
                // Move to the next subtask
                self.runSubtask(at: index + 1, completion: completion)
                
            case .failure(let error):
                // You can decide to skip or stop. We'll just store an error message.
                print("Error in subtask \(index + 1): \(error.localizedDescription)")
                subtask.output = "Error: \(error.localizedDescription)"
                self.subtasks[index] = subtask
                
                // We'll continue to the next subtask anyway.
                self.runSubtask(at: index + 1, completion: completion)
            }
        }
    }
}
