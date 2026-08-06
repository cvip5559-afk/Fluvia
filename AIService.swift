//
//  AIService.swift
//  test
//
//  Created by Jinan Mahdi Alanazi on 23/02/1448 AH.
//

import Foundation

class AIService {
    static let shared = AIService()
    private let apiKey = "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" // حطي مفتاح الـ API هنا

    // 1. تحويل الصوت لنص باستخدام Whisper
    func transcribeAudio(fileURL: URL) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        let audioData = try Data(contentsOf: fileURL)
        
        // Form Data setup for Whisper
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        data.append(audioData)
        data.append("\r\n".data(using: .utf8)!)
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        data.append("whisper-1\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let (responseData, _) = try await URLSession.shared.upload(for: request, from: data)
        let result = try JSONDecoder().decode(WhisperResponse.self, from: responseData)
        return result.text
    }

    // 2. تصنيف التأتأة بناءً على النص المنقول (الـ Prompt ينحط هنا)
    func classifyStutter(transcription: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // هنا الـ Prompt اللي يشخص التأتأة
        let systemPrompt = """
        You are a speech-language pathology AI assistant. Analyze the transcribed audio text for stuttering/disfluency patterns.
        Classify the primary stutter type into EXACTLY ONE of these categories:
        - "Say It Slow"
        - "Easy Start"
        - "Smooth Start"
        - "Say It Once"
        - "Silent Pause"
        
        Return ONLY the category name.
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": "Transcribed text: \(transcription)"]
            ],
            "temperature": 0.2
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (responseData, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(GPTResponse.self, from: responseData)
        return result.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Smooth Start"
    }
}

// Structs لمناقلة البيانات من API
struct WhisperResponse: Codable { let text: String }
struct GPTResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable { let content: String }
        let message: Message
    }
    let choices: [Choice]
}
