//
//  AnthropicService.swift
//  ThinkCutExtension
//
//  Created by Besar Ismaili on 08/04/2025.
//

import Foundation

enum AnthropicError: Error {
    case invalidResponse
    case apiError(String)
}

class AnthropicService {
    private let apiKey: String
    
    // Insert your actual Anthropic endpoint here. The docs currently use e.g. "https://api.anthropic.com/v1/complete"
    private let anthropicURL = URL(string: "https://api.anthropic.com/v1/complete")!
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Send a request to the Anthropic API with the given system prompt and user prompt.
    func sendRequest(systemPrompt: String, userPrompt: String,
                     completion: @escaping (Result<String, Error>) -> Void) {
        
        // Combine system and user instructions in a single prompt (Claude uses "Human:" / "Assistant:" style or can handle system messages).
        // We'll do a naive approach: "System: ... User: ..."
        let fullPrompt = """
        System: \(systemPrompt)
        
        User: \(userPrompt)
        """
        
        let requestBody: [String: Any] = [
            "prompt": fullPrompt,
            "model": "claude-instant-v1",  // Or claude-2, etc.
            "max_tokens_to_sample": 500,
            // Additional parameters as needed
        ]
        
        var request = URLRequest(url: anthropicURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(AnthropicError.invalidResponse))
                return
            }
            
            // The response from Anthropic typically has a "completion" field containing the assistant text.
            // Check the actual structure in Anthropic's docs.
            // Example structure:
            // {
            //   "completion": "Hello, here is the result...",
            //   "stop_reason": "max_tokens",
            //   ...
            // }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let completionText = json["completion"] as? String {
                    completion(.success(completionText))
                } else {
                    completion(.failure(AnthropicError.apiError("Missing 'completion' in response")))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
