//
//  SayItOnceExerciseView.swift
//  fluvia


import SwiftUI

struct SayItOnceExerciseView: View {

    var onBack: (() -> Void)? = nil
    var onGoHome: (() -> Void)? = nil

    // MARK: Palette
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow
    private let tanColor        = Color(red: 0.75, green: 0.68, blue: 0.5)

    private enum Screen {
        case intro, recording, results
    }

    @State private var screen: Screen = .intro
    @State private var finalStoryText: String = ""
    @State private var finalDuration: Int = 0

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                switch screen {
                case .intro:
                    StoryIntroView(onBack: onBack) {
                        screen = .recording
                    }

                case .recording:
                    StoryRecordingView { storyText, duration in
                        finalStoryText = storyText
                        finalDuration = duration
                        screen = .results
                    }

                case .results:
                    StoryResultsView(
                        storyText: finalStoryText,
                        durationSeconds: finalDuration,
                        onTryAgain: { screen = .intro },
                        onGoHome: onGoHome
                    )
                }
            }
        }
    }
}

// MARK: - FIRST PAGE
struct StoryIntroView: View {

    var onBack: (() -> Void)? = nil
    let onStart: () -> Void

    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow
    private let tanColor        = Color(red: 0.75, green: 0.68, blue: 0.5)

    private let pictures: [(emoji: String, label: String)] = [
        ("👦", "Boy"),
        ("🌳", "Park"),
        ("⚽", "Football"),
        ("🌧️", "Rain"),
        ("🏠", "Home")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                titleSection

                Text("A Rainy Football Day")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(darkTextColor.opacity(0.7))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(pictures.enumerated()), id: \.offset) { index, pic in
                            StoryPictureCard(
                                number: index + 1,
                                emoji: pic.emoji,
                                label: pic.label,
                                darkTextColor: darkTextColor
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Challenge")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(darkTextColor)

                    StoryBullet(text: "Use all five pictures, in order")
                    StoryBullet(text: "Speak for 30–45 seconds")
                    StoryBullet(text: "Avoid repeating the same word too often")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(14)
                .padding(.horizontal)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 14
                ) {
                    StoryStepSquare(number: 1, text: "Sit comfortably", color: darkTextColor)
                    StoryStepSquare(number: 2, text: "Look at the pictures", color: greenColor)
                    StoryStepSquare(number: 3, text: "Tell one connected story", color: tanColor)
                    StoryStepSquare(number: 4, text: "Avoid repeating words", color: goldColor)
                }
                .padding(.horizontal)

                Button(action: onStart) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Start Recording")
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(greenColor)
                    .cornerRadius(16)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 100)
        }
    }

    private var titleSection: some View {
           VStack(spacing: 4) {
               HStack {
                   BackButton(action: { onBack?() }, textColor: darkTextColor)
                   Spacer()
               }
               .padding(.horizontal, 20)
               .padding(.top, 12)
               
               Text("Say It Once")
                   .font(.custom("Georgia-Bold", size: 30))
                   .foregroundColor(darkTextColor)
               Text("Story Builder Practice")
                   .font(.system(size: 15, weight: .medium))
                   .foregroundColor(.primary.opacity(0.5))
           }
       }
}

// MARK: - Picture Card

private struct StoryPictureCard: View {

    let number: Int
    let emoji: String
    let label: String
    let darkTextColor: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topLeading) {
                Circle()
                    .fill(darkTextColor)
                    .frame(width: 18, height: 18)

                Text("\(number)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 5)
                    .padding(.top, 2)

                Text(emoji)
                    .font(.system(size: 28))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
            }

            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
        }
        .frame(width: 76)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(14)
    }
}

// MARK: - Steps

private struct StoryStepSquare: View {

    let number: Int
    let text: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 34, height: 34)
                .overlay(
                    Text("\(number)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                )

            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

// MARK: - Bullet

private struct StoryBullet: View {

    let text: String

    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .foregroundColor(.gray)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - SECOND PAGE

struct StoryRecordingView: View {

    let onFinish: (String, Int) -> Void

    private let totalSeconds = 45

    @State private var secondsElapsed = 0
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?

    @StateObject private var speechRecognize = SpeechRecognizer()

    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let goldColor       = Color.yellow

    private let pictures = ["👦", "🌳", "⚽", "🌧️", "🏠"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                Text("Say It Once")
                    .font(.custom("Georgia", size: 30))
                    .fontWeight(.bold)
                    .foregroundColor(darkTextColor)
                    .padding(.top, 8)

                Text("Recording…")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(darkTextColor.opacity(0.7))

                Text(
                    speechRecognize.text.isEmpty
                        ? "Start speaking"
                        : speechRecognize.text
                )
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                ZStack {
                    Circle()
                        .stroke(goldColor.opacity(0.25), lineWidth: 14)
                        .frame(width: 220, height: 220)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            goldColor,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(-90))

                    Circle()
                        .fill(goldColor)
                        .frame(width: 180, height: 180)

                    VStack(spacing: 4) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 30))

                        Text("00:\(String(format: "%02d", secondsElapsed)) / 00:45")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(darkTextColor)
                }
                .padding(.vertical, 10)

                HStack(spacing: 10) {
                    ForEach(pictures, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 18))
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }

                Button {
                    speechRecognize.stopRecording()
                    stopTimer()
                    onFinish(speechRecognize.text, secondsElapsed)
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop Recording")
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(darkTextColor)
                    .cornerRadius(16)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 100)
        }
        .onAppear {
            startTimer()

            speechRecognize.requestPermission { granted in
                if granted {
                    speechRecognize.startRecording()
                } else {
                    print("Speech or microphone permission denied")
                }
            }
        }
        .onDisappear {
            speechRecognize.stopRecording()
            stopTimer()
        }
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()

        secondsElapsed = 0
        progress = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsElapsed < totalSeconds {
                secondsElapsed += 1
                withAnimation {
                    progress = CGFloat(secondsElapsed) / CGFloat(totalSeconds)
                }
            }

            if secondsElapsed >= totalSeconds {
                speechRecognize.stopRecording()
                stopTimer()
                onFinish(speechRecognize.text, secondsElapsed)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - THIRD PAGE

struct StoryResultsView: View {

    let storyText: String
    let durationSeconds: Int
    var onTryAgain: () -> Void = {}
    var onGoHome: (() -> Void)? = nil

    @StateObject private var analyzer = StoryAnalyzer()

    // MARK: Shared streak progress
    @State private var didMarkDayComplete = StreakManager.isTodayCompleted

    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                Text("Nice work!")
                    .font(.custom("Georgia", size: 30))
                    .fontWeight(.bold)
                    .foregroundColor(darkTextColor)
                    .padding(.top, 8)

                if analyzer.isAnalyzing {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Analyzing your story...")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)

                } else if let error = analyzer.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button(action: onTryAgain) {
                            Text("Try Again")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                                .background(greenColor)
                                .cornerRadius(18)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.top, 60)

                } else if let analysis = analyzer.result {
                    resultsContent(analysis)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 100) 
        }
        .task {
            await analyzer.analyze(storyText: storyText, durationSeconds: durationSeconds)
        }
    }

    @ViewBuilder
    private func resultsContent(_ analysis: StoryAnalysis) -> some View {
        ZStack {
            Circle()
                .stroke(goldColor.opacity(0.25), lineWidth: 14)
                .frame(width: 190, height: 190)

            Circle()
                .trim(from: 0, to: CGFloat(analysis.overallScore) / 100)
                .stroke(
                    greenColor,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 190, height: 190)
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(Color.white)
                .frame(width: 150, height: 150)

            VStack {
                Text("\(analysis.overallScore)")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(darkTextColor)

                Text("OVERALL SCORE")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }

        HStack {
            ForEach(0..<3) { i in
                Image(systemName: i < analysis.stars ? "star.fill" : "star")
                    .foregroundColor(goldColor)
            }
        }

        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            StoryStatCard(label: "WORD REPETITION", value: "\(analysis.wordRepetition)", darkTextColor: darkTextColor)
            StoryStatCard(label: "FLUENCY", value: analysis.fluency, darkTextColor: darkTextColor, good: true)
            StoryStatCard(label: "SPEAKING PACE", value: analysis.pace, darkTextColor: darkTextColor, good: true)
            StoryStatCard(
                label: "STORY COMPLETION",
                value: analysis.storyComplete ? "✓ Complete" : "Incomplete",
                darkTextColor: darkTextColor,
                good: analysis.storyComplete
            )
        }

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(greenColor)

                Text(analysis.feedback)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(darkTextColor)
            }

            if analysis.wordRepetition > 1 {
                Text("You repeated the word \"\(analysis.repeatedWord)\" \(analysis.wordRepetition) times. Try swapping in a different word next time:")
                    .font(.system(size: 14))
                    .foregroundColor(darkTextColor.opacity(0.85))

                HStack {
                    ForEach(analysis.alternatives, id: \.self) { word in
                        Text(word)
                            .foregroundColor(darkTextColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(goldColor.opacity(0.25))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)

        HStack {
            StoryTag(text: " Goal: 0–1 repeats", darkTextColor: darkTextColor)
            StoryTag(text: "\(durationSeconds) sec", darkTextColor: darkTextColor)
        }

        Button(action: markDayComplete) {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "flag.checkered")
                    Text("Done")
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(darkTextColor)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(goldColor)
            .cornerRadius(18)
        }

        Button(action: onTryAgain) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Try Again")
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(greenColor)
            .cornerRadius(16)
        }
    }

    private func markDayComplete() {
        if !didMarkDayComplete {
            withAnimation {
                StreakManager.markTodayComplete()
                DailyProgressManager.markExerciseDone()
                didMarkDayComplete = true
            }
        }
        onGoHome?()
    }
}

// MARK: - Cards

private struct StoryStatCard: View {

    let label: String
    let value: String
    let darkTextColor: Color
    var good: Bool = false

    private let greenColor = Color(red: 0.45, green: 0.55, blue: 0.35)

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(good ? greenColor : darkTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(14)
    }
}

private struct StoryTag: View {

    let text: String
    let darkTextColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(darkTextColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    SayItOnceExerciseView()
}
