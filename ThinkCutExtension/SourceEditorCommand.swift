//
//  SourceEditorCommand.swift
//  ThinkCutExtension
//
//  Created by Besar Ismaili on 08/04/2025.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let buffer = invocation.buffer
        // Insert a visible line at the beginning
        buffer.lines.insert("// ThinkCut executed", at: 0)
        completionHandler(nil)
    }

    
}
