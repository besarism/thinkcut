//
//  SourceEditorExtension.swift
//  ThinkCutExtension
//
//  Created by Besar Ismaili on 08/04/2025.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        
        // 1. Collect user input from the text buffer or selection.
        let buffer = invocation.buffer
        let selectionText = gatherSelection(from: buffer)
        
        // If no text is selected, you could prompt the user or fallback to some placeholder
        let userGoal = selectionText.isEmpty
        ? "Implement a new SwiftUI feature with MVVM design." // fallback
        : selectionText
        
        // 2. Define your subtasks. In a real scenario, you could get more dynamic about this.
        let tasks = [
            Subtask(mode: .design,
                    input: "Design subtask for: \(userGoal)"),
            Subtask(mode: .coding,
                    input: "Coding subtask. Use the design's instructions to implement the feature in Swift code."),
            Subtask(mode: .debugging,
                    input: "Debug or verify the code from previous step, identify potential issues."),
            Subtask(mode: .documentation,
                    input: "Generate documentation or usage instructions for the final code.")
        ]
        
        // 3. Initialize the Anthropic service with your API key
        let anthropicService = AnthropicService(apiKey: "YOUR_ANTHROPIC_API_KEY")
        
        // 4. Create the orchestrator
        let orchestrator = Orchestrator(subtasks: tasks, anthropicService: anthropicService)
        
        // 5. Run the tasks (async)
        orchestrator.runAllSubtasks { completedSubtasks in
            
            // At this point, all subtasks are done. We can combine results or insert them.
            // For demonstration, let's just print them to the console and
            // also insert a comment into the current buffer with the final summary.
            
            print("All subtasks completed.")
            
            var finalSummaryLines: [String] = []
            for (index, subtask) in completedSubtasks.enumerated() {
                let title = "Subtask \(index + 1) [\(subtask.mode.displayName)]"
                let summary = subtask.summary ?? "No summary"
                finalSummaryLines.append("=== \(title) ===\n\(summary)\n")
            }
            
            // Insert a comment block at the top of the file with the subtask summaries
            buffer.lines.insert("// Boomerang Orchestrator Results:", at: 0)
            var insertIndex = 1
            for summaryLine in finalSummaryLines {
                let commentLine = "// " + summaryLine.replacingOccurrences(of: "\n", with: "\n// ")
                buffer.lines.insert(commentLine, at: insertIndex)
                insertIndex += 1
            }
            
            // Potentially also insert the full code or docs from subtask outputs.
            // e.g. if you wanted to append them:
            /*
             if let codingOutput = completedSubtasks[1].output {
             buffer.lines.insert("// [Coding Output]:\n\(codingOutput)", at: insertIndex)
             }
             */
            
            // Signal done
            completionHandler(nil)
        }
    }
    
    /// Simple helper to gather text from the user's selection in Xcode
    private func gatherSelection(from buffer: XCSourceTextBuffer) -> String {
        var selectedText = ""
        for range in buffer.selections {
            if let textRange = range as? XCSourceTextRange {
                let start = textRange.start.line
                let end = textRange.end.line
                
                if start == end {
                    // Single-line selection
                    let lineText = buffer.lines[start] as? String ?? ""
                    let colStart = textRange.start.column
                    let colEnd   = textRange.end.column
                    if colStart < colEnd && colEnd <= lineText.count {
                        let substring = lineText[colStart..<colEnd]
                        selectedText += substring
                    }
                } else {
                    // Multi-line selection
                    for lineIndex in start...end {
                        if lineIndex < buffer.lines.count {
                            let lineText = buffer.lines[lineIndex] as? String ?? ""
                            selectedText += lineText
                        }
                    }
                }
            }
        }
        return selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// A small string range subscript convenience
extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: max(0, range.lowerBound))
        let endIndex = self.index(startIndex, offsetBy: min(self.count - range.lowerBound,
                                                            range.upperBound - range.lowerBound))
        return String(self[startIndex..<endIndex])
    }
}
