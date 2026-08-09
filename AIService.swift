import Foundation

class AIService {
    static let shared = AIService()

    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String ?? ""
    }

    // تحويل الصوت لنص باستخدام Whisper (تستخدمينه لعرض النص فقط، مو للتصنيف)
    func transcribeAudio(fileURL: URL) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        let audioData = try Data(contentsOf: fileURL)

        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        data.append(audioData)
        data.append("\r\n".data(using: .utf8)!)

        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        data.append("whisper-1\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let (responseData, response) = try await URLSession.shared.upload(for: request, from: data)

        // ✅ نتحقق من كود الاستجابة قبل فك التشفير، عشان ما نطلع خطأ غامض لو المفتاح غلط
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorText = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "AIService", code: httpResponse.statusCode,
                           userInfo: [NSLocalizedDescriptionKey: "Whisper API error: \(errorText)"])
        }

        let result = try JSONDecoder().decode(WhisperResponse.self, from: responseData)
        return result.text
    }
}

// Structs لمناقلة البيانات من API
struct WhisperResponse: Codable { let text: String }
