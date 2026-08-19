import Foundation
import SoundAnalysis

struct StutterClassificationResult {
    let label: String
    let confidence: Double
}

private class StutterResultsObserver: NSObject, SNResultsObserving {
    var onComplete: (([SNClassification]) -> Void)?
    var onError: ((Error) -> Void)?

    
    private var topClassificationPerWindow: [SNClassification] = []

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult,
              let top = classificationResult.classifications.first else { return }
        topClassificationPerWindow.append(top)
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        onError?(error)
    }

    
    func requestDidComplete(_ request: SNRequest) {
        onComplete?(topClassificationPerWindow)
    }
}

class StutterClassifierService {
    static let shared = StutterClassifierService()

    
    
    func classify(fileURL: URL) async throws -> StutterClassificationResult {
        let model = try StutterModel(configuration: MLModelConfiguration()).model
        let request = try SNClassifySoundRequest(mlModel: model)
        let analyzer = try SNAudioFileAnalyzer(url: fileURL)

        return try await withCheckedThrowingContinuation { continuation in
            let observer = StutterResultsObserver()
            var didFinish = false

            observer.onComplete = { classificationsPerWindow in
                guard !didFinish else { return }
                didFinish = true

                guard !classificationsPerWindow.isEmpty else {
                    continuation.resume(throwing: NSError(
                        domain: "StutterClassifierService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "لم يُنتج التحليل أي نتائج (الملف الصوتي قد يكون قصير جداً أو فارغ)"]
                    ))
                    return
                }

               
                var votesPerLabel: [String: Int] = [:]
                var confidenceSumPerLabel: [String: Double] = [:]

                for classification in classificationsPerWindow {
                    votesPerLabel[classification.identifier, default: 0] += 1
                    confidenceSumPerLabel[classification.identifier, default: 0] += Double(classification.confidence)
                }

                
                
                let winner = votesPerLabel.max { a, b in
                    if a.value != b.value {
                        return a.value < b.value
                    }
                    return (confidenceSumPerLabel[a.key] ?? 0) < (confidenceSumPerLabel[b.key] ?? 0)
                }!

                let averageConfidence = (confidenceSumPerLabel[winner.key] ?? 0) / Double(winner.value)

                #if DEBUG
                
                
                print(" نتائج التصويت عبر \(classificationsPerWindow.count) نافذة زمنية:")
                for (label, votes) in votesPerLabel.sorted(by: { $0.value > $1.value }) {
                    let avgConf = (confidenceSumPerLabel[label] ?? 0) / Double(votes)
                    print("   - \(label): \(votes) صوت، متوسط ثقة \(String(format: "%.2f", avgConf))")
                }
                #endif

                continuation.resume(returning: StutterClassificationResult(
                    label: winner.key,
                    confidence: averageConfidence
                ))
            }

            observer.onError = { error in
                guard !didFinish else { return }
                didFinish = true
                continuation.resume(throwing: error)
            }

            do {
                try analyzer.add(request, withObserver: observer)
                analyzer.analyze()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
