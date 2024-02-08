//
//  GPTManager.swift
//  InterviewPractice
//
//  Created by Luke Thompson on 8/2/2024.
//

import Foundation
import Security

// Message structure to hold the text-content of the message and the sender (either "Interviewer" or "User")
struct Message: Identifiable {
    let id = UUID()
    var sender: String
    var content: String
}

// Handles all requests to the openAI API
class GPTManager: ObservableObject {
    private let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? "YOUR_FALLBACK_API_KEY" // Retrieves the API key from the environmental variables
    @Published var jobRole = "Python Software Developer" // Example job role. In future I'll let the user enter the job role in a parent view
    @Published var conversationHistory: [Message] = [] // Holds messages for current conversation

    func getQuestion(completion: @escaping (Bool) -> Void) {
        let endpoint = "https://api.openai.com/v1/chat/completions"
        
        // Prepare the request
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var messagesToSend: [[String: Any]] = []
        if conversationHistory.isEmpty {
            // If there's no history, start with a default message to initiate the conversation
            messagesToSend.append(["role": "system", "content": "You are an interviewer for a \(jobRole) position. Please start the interview by introducing your company and asking the interviewee your first question."])
        } else {
            // Otherwise, use the existing conversation history
            messagesToSend = conversationHistory.map { message -> [String: Any] in
                ["role": "user", "content": message.content]
            }
        }
        
        let parameters: [String: Any] = [
            "model": "gpt-4",
            "max_tokens": 150,
            "temperature": 0.7,
            "messages": messagesToSend
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print(error.localizedDescription)
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(false)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    // Append the new question (content) to the conversation history
                    DispatchQueue.main.async {
                        self.conversationHistory.append(Message(sender: "Interviewer", content: content))
                    }
                    completion(true)
                } else {
                    print("Invalid response format.")
                    completion(false)
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion(false)
            }
        }.resume()
    }
}
