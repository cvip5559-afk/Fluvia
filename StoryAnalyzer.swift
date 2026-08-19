//
//  StoryAnalyzer.swift
//  fluvia
//
//  On-device analysis of the story, using Apple's on-device FoundationModels


import Foundation
import FoundationModels
import Combine

@Generable
struct StoryAnalysis {
    @Guide(description: "Overall score from 0 to 100 based on story quality, creativity, and how well it connects the 5 pictures: boy, park, football, rain, home")
    var overallScore: Int

    @Guide(description: "Number of times the single most-repeated meaningful word (not 'the', 'a', 'and') was repeated")
    var wordRepetition: Int

    @Guide(description: "One word describing fluency: Excellent, Good, Fair, or Needs Practice")
    var fluency: String

    @Guide(description: "One or two words describing speaking pace: Good, Too Fast, Too Slow")
    var pace: String

    @Guide(description: "True if the story uses all 5 pictures (boy, park, football, rain, home) in a connected narrative")
    var storyComplete: Bool

    @Guide(description: "The single most frequently repeated meaningful word in the story, lowercase")
    var repeatedWord: String

    @Guide(description: "Exactly 3 short alternative words or phrases instead of the repeated word")
    var alternatives: [String]

    @Guide(description: "Star rating from 1 to 3 based on overall quality")
    var stars: Int

    @Guide(description: "A short, encouraging one-sentence feedback message for a child, in English")
    var feedback: String
}

@MainActor
final class StoryAnalyzer: ObservableObject {

    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    @Published var result: StoryAnalysis?

    func analyze(storyText: String, durationSeconds: Int) async {
        guard !storyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "No story text to analyze"
            return
        }

        isAnalyzing = true
        errorMessage = nil

        let model = SystemLanguageModel.default

        switch model.availability {
        case .available:
            break
        case .unavailable(let reason):
            isAnalyzing = false
            errorMessage = "AI unavailable: \(reason)"
            return
        @unknown default:
            isAnalyzing = false
            errorMessage = "AI unavailable"
            return
        }

        do {
            let session = LanguageModelSession()

            let prompt = """
            Analyze this story told by a child as part of a speech therapy exercise. The child was shown 5 pictures in order: a boy, a park, a football, rain, a home. They spoke for approximately \(durationSeconds) seconds.

            Here is the transcribed story: "\(storyText)"

            Evaluate the story's quality, fluency, word repetition, and whether it connects all 5 pictures into one narrative.
            """

            let response = try await session.respond(
                to: prompt,
                generating: StoryAnalysis.self
            )

            self.result = response.content
            self.isAnalyzing = false

        } catch {
            self.errorMessage = error.localizedDescription
            self.isAnalyzing = false
        }
    }
}
