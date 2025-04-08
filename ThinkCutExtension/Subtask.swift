//
//  Subtask.swift
//  ThinkCutExtension
//
//  Created by Besar Ismaili on 08/04/2025.
//

import Foundation

struct Subtask {
    let mode: SubtaskMode
    let input: String     // The relevant instructions or code snippet for this subtask
    var output: String?   // The AI response (filled in after execution)
    var summary: String?  // A short summary of the output
}
