//
//  AnalysisCompleteView.swift
//  fluvia
//


import SwiftUI

struct AnalysisCompleteView: View {
    @ObservedObject var audioRecorder: AudioRecorderManager
    var onBack: () -> Void = {}
    var onStartExercise: (String) -> Void = { _ in }
    var onGoHome: () -> Void = {}

    // MARK: Palette (unified with the rest of the app)
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow
    private let purpleColor     = Color(red: 0.52, green: 0.40, blue: 0.60)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    header
                    resultBox
                    planBox
                    actionButtonsGroup
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 4){
            HStack {
                BackButton(action: onBack, textColor: darkTextColor)
                Spacer()
            }
            .padding(.bottom, 4)
            Text("Analysis Complete")
                .font(.custom("Georgia", size: 28))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)
        }
        .padding(.top, 8)
    }
    // MARK: - Result Box (shows the REAL detected type + confidence)

    private var resultBox: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Based on your recording")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(darkTextColor)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(match.tint.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: match.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(match.tint == .yellow ? .orange : match.tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(match.detectedLabel)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(darkTextColor)

                    if let confidence = audioRecorder.assessmentConfidence {
                        Text("\(Int(confidence * 100))% confidence")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
            )
        }
    }

    // MARK: - Plan Box (now driven by the ACTUAL classification)

    private var planBox: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Plan")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(darkTextColor)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                    Image(systemName: match.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(darkTextColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(match.exerciseTitle)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(darkTextColor)

                    Text(match.planDescription)
                        .font(.system(size: 14))
                        .foregroundColor(darkTextColor.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(match.tint.opacity(0.18))
            )
        }
    }

    // MARK: - Start Button

    private var actionButtonsGroup: some View {
        VStack(spacing: 14) {
            // Main Primary CTA Button
            Button(action: {
                if match.isFluent {
                    onBack()
                } else {
                    onStartExercise(match.exerciseTitle)
                }
            }) {
                Text(match.isFluent ? "Back to Exercises" : "Start Exercise")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(greenColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
            }

            // Secondary / Tertiary Text Button
            Button(action: onGoHome) {
                Text("Exercise Later")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(darkTextColor.opacity(0.6))
                    .padding(.vertical, 6)
            }
        }
    }

    // MARK: - Label → Exercise mapping
    //
    // This is the fix: instead of a hardcoded plan, we read the REAL
    // label the model produced and map it to one of your 5 stutter
    // types. `match.exerciseTitle` is then handed to onStartExercise,
    // which RootView uses to switch to the Exercises tab (so the tab
    // bar icon updates) AND auto-open that exact exercise.

    private struct ExerciseMatch {
        let detectedLabel: String
        let exerciseTitle: String
        let planDescription: String
        let icon: String
        let tint: Color
        let isFluent: Bool
    }

    private var match: ExerciseMatch {
        let raw = audioRecorder.assessmentResult ?? ""
        let normalized = raw.lowercased()

        if normalized.contains("fluent") || (normalized.contains("no") && normalized.contains("stutter")) {
            return ExerciseMatch(
                detectedLabel: "No Stuttered Words",
                exerciseTitle: "Keep Practicing",
                planDescription: "Your speech sounded smooth this time, nice work! Keep practicing to build consistency.",
                icon: "checkmark.seal.fill",
                tint: greenColor,
                isFluent: true
            )
        } else if normalized.contains("prolong") {
            return ExerciseMatch(
                detectedLabel: "Prolongation",
                exerciseTitle: "Say It Slow",
                planDescription: "Stretch sounds gently and ease tension at the start of a word.",
                icon: "waveform.path",
                tint: greenColor,
                isFluent: false
            )
        } else if normalized.contains("block") {
            return ExerciseMatch(
                detectedLabel: "Block",
                exerciseTitle: "Easy Start",
                planDescription: "Release tension with a slow breath before gliding gently into speech.",
                icon: "lungs.fill",
                tint: purpleColor,
                isFluent: false
            )
        } else if normalized.contains("sound") && normalized.contains("rep") {
            return ExerciseMatch(
                detectedLabel: "Sound Repetition",
                exerciseTitle: "Smooth Start",
                planDescription: "Stretch the repeated sound gently for 2 seconds, then glide into the full word.",
                icon: "repeat",
                tint: greenColor,
                isFluent: false
            )
        } else if normalized.contains("word") && normalized.contains("rep") {
            return ExerciseMatch(
                detectedLabel: "Word Repetition",
                exerciseTitle: "Say It Once",
                planDescription: "Practice saying the whole word once, smoothly, without repeating it.",
                icon: "text.word.spacing",
                tint: purpleColor,
                isFluent: false
            )
        } else if normalized.contains("interject") || normalized.contains("filler") {
            return ExerciseMatch(
                detectedLabel: "Interjection",
                exerciseTitle: "Silent Pause",
                planDescription: "Swap filler words like \"um\" or \"uh\" for a brief, silent pause instead.",
                icon: "quote.bubble.fill",
                tint: goldColor,
                isFluent: false
            )
        } else {
            // Unrecognized label — show it plainly instead of pretending
            // to know, and point to the Exercises tab generally.
            return ExerciseMatch(
                detectedLabel: raw.isEmpty ? "Unrecognized" : raw,
                exerciseTitle: "Explore Exercises",
                planDescription: "We couldn't map this result to a specific technique yet, check out all your exercises.",
                icon: "questionmark.circle",
                tint: Color.gray,
                isFluent: false
            )
        }
    }
}

// MARK: - Preview

#Preview {
    AnalysisCompleteView(audioRecorder: AudioRecorderManager())
}
