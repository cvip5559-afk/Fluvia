//
//  AssessView.swift
//  fluvia

import SwiftUI

private enum AssessScreen: Equatable {
    case home
    case recording
    case paused
}

struct AssessView: View {
    @StateObject private var audioRecorder = AudioRecorderManager()
    @State private var screen: AssessScreen = .home
    @State private var showAnalysis = false
    @State private var isPulsing = false
    var onBack: () -> Void = {}
    var onStartExercise: (String) -> Void = { _ in }
    var onGoHome: () -> Void = {}

    // MARK: Palette (unified with the rest of the app)
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header

                        micGraphic
                            .padding(.top, 50)

                        readAloudCard
                            .padding(.top, 60)

                        controls
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 100)
                    .padding(.bottom, 100) // room above the global tab bar
                }
            }

            if audioRecorder.isAnalyzing {
                analyzingOverlay
            }

            // Analysis screen appears instantly, no animation
            if showAnalysis {
                AnalysisCompleteView(
                    audioRecorder: audioRecorder,
                    onBack: {
                        showAnalysis = false
                        screen = .home
                    },
                    onStartExercise: onStartExercise,
                    onGoHome: onGoHome
                )
                .zIndex(1)
            }
        }
        .onChange(of: audioRecorder.showResultsScreen) { _, showResults in
            if showResults {
                showAnalysis = true
                DailyProgressManager.markVoiceAssessmentDone()
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        VStack(spacing: 6) {
            if screen == .home {
                HStack {
                    BackButton(action: onBack, textColor: darkTextColor)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 6)
            }

            Text("Voice Assessment")
                .font(.custom("Georgia", size: 30))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)
                .multilineTextAlignment(.center)

            switch screen {
            case .home:
                Text("Let's check in on your fluency today!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary.opacity(0.5))

            case .recording:
                Text("Listening... take your time")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Text(formatTime(audioRecorder.recordingTime))
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.red)
                    .padding(.top, 2)

            case .paused:
                Text("Recording paused")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Text(formatTime(audioRecorder.recordingTime))
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Mic Graphic

    private var micGraphic: some View {
        ZStack {
            // Pulsing ring — only animates while actively recording,
            // so it visually confirms "yes, it's really recording now"
            // instead of just showing the same static circles as Start.
            Circle()
                .stroke(Color(red: 0.85, green: 0.65, blue: 0.1).opacity(0.5), lineWidth: 3)
                .frame(width: 210, height: 210)
                .scaleEffect(isPulsing ? 1.18 : 1.0)
                .opacity(isPulsing ? 0 : 0.8)

            Circle()
                .fill(Color.gray.opacity(0.12))
                .frame(width: 210, height: 210)
                .scaleEffect(isPulsing ? 1.06 : 1.0)

            Circle()
                .fill(goldColor.opacity(0.55))
                .frame(width: 155, height: 155)
                .scaleEffect(isPulsing ? 1.06 : 1.0)

            HStack(spacing: 7) {
                Capsule().fill(darkTextColor).frame(width: 7, height: 40)
                Capsule().fill(darkTextColor).frame(width: 7, height: 65)
                Capsule().fill(darkTextColor).frame(width: 7, height: 85)
                Capsule().fill(darkTextColor).frame(width: 7, height: 55)
                Capsule().fill(darkTextColor).frame(width: 7, height: 75)
                Capsule().fill(darkTextColor).frame(width: 7, height: 42)
            }
        }
        .padding(.vertical, 10)
        .onChange(of: screen) { _, newScreen in
            updatePulse(for: newScreen)
        }
        .onAppear {
            updatePulse(for: screen)
        }
    }

    private func updatePulse(for screen: AssessScreen) {
        if screen == .recording {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                isPulsing = false
            }
        }
    }

    // MARK: - Read Aloud Card

    private var readAloudCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("READ ALOUD")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)
                .tracking(0.8)

            Text("\"The soft breeze carried the calm sound of the river, gently drifting through the quiet morning air.\"")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(darkTextColor)
                .lineSpacing(4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
        .padding(.horizontal, 24)
        .padding(.top, 25)
    }

    // MARK: - Controls

    @ViewBuilder
    private var controls: some View {
        switch screen {
        case .home:
            Button(action: {
                audioRecorder.startRecording()
                screen = .recording
            }) {
                Text("Start")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(greenColor)
                    .cornerRadius(18)
            }
            .padding(.horizontal, 33)
            .padding(.top, 60)
            .padding(.bottom, 40)

        case .recording:
            HStack(alignment: .center, spacing: 35) {
                controlButton(icon: "xmark", label: "Restart", bg: Color.gray.opacity(0.15), size: 50) {
                    audioRecorder.stopRecording()
                    screen = .home
                }

                controlButton(square: true, label: "Stop", bg: greenColor, size: 62) {
                    audioRecorder.stopRecording()
                }

                controlButton(icon: "pause.fill", label: "Pause", bg: Color.gray.opacity(0.15), size: 50) {
                    audioRecorder.pauseRecording()
                    screen = .paused
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 30)

        case .paused:
            HStack(alignment: .center, spacing: 35) {
                controlButton(icon: "xmark", label: "Restart", bg: Color.gray.opacity(0.15), size: 50) {
                    audioRecorder.stopRecording()
                    screen = .home
                }

                controlButton(square: true, label: "Stop", bg: greenColor, size: 62) {
                    audioRecorder.stopRecording()
                }

                controlButton(icon: "play.fill", label: "Resume", bg: Color.gray.opacity(0.15), size: 50) {
                    audioRecorder.resumeRecording()
                    screen = .recording
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
        }
    }

    @ViewBuilder
    private func controlButton(
        icon: String? = nil,
        square: Bool = false,
        label: String,
        bg: Color,
        size: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(bg)
                        .frame(width: size, height: size)
                    if square {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                    } else if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(darkTextColor.opacity(0.7))
                    }
                }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Analyzing overlay

    private var analyzingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(.white)
                Text("Analyzing speech...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
        }
        .zIndex(1)
    }

    private func formatTime(_ totalSeconds: TimeInterval) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = Int(totalSeconds) / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview {
    AssessView()
}
