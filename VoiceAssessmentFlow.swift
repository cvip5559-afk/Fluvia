//
//  VoiceAssessmentFlow.swift
//  test
//
//  Merged view combining:
//   - ContentView.swift  (Home / Start)
//   - SwiftUIView.swift  (Active recording)
//   - v.swift            (Paused recording)
//
//  All three screens now live inside ONE SwiftUI View and switch
//  using a simple state enum instead of separate NavigationLinks.
//

import SwiftUI

// MARK: - Shared Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shared Theme Colors (merged from all three files)
struct VoiceFlowColors {
    static let background      = Color(red: 0.98, green: 0.96, blue: 0.91)
    static let primaryText     = Color.black
    static let secondaryText   = Color(hex: "4A4A4A")
    static let cardBackground  = Color.white
    static let audioCircleOuter = Color(hex: "EDEBE8")
    static let audioCircleInner = Color(hex: "E8B931")
    static let waveformColor   = Color(hex: "3A220F")
    static let controlButtonBg = Color(hex: "E2E0D8")
    static let buttonStart     = Color(hex: "95B173")
    static let buttonStop      = Color(hex: "8BAA6E")
    static let activeYellow    = Color(hex: "F6C445")
}

// MARK: - Screen State (replaces separate views / navigation)
private enum VoiceFlowScreen {
    case home
    case recording
    case paused
}

// MARK: - Unified Voice Assessment View
struct VoiceAssessmentFlowView: View {
    @StateObject private var audioRecorder = AudioRecorderManager()
    @State private var screen: VoiceFlowScreen = .home
    @State private var selectedTab = 0

    // Called when the results screen should be shown (hook up your
    // AnalysisCompleteView / SwiftUIView2 here if you want it in-flow).
    var onShowResults: ((AudioRecorderManager) -> Void)? = nil

    var body: some View {
        ZStack {
            VoiceFlowColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header
                        micGraphic
                        readAloudCard
                        controls
                    }
                }
                tabBar
            }

            if audioRecorder.isAnalyzing {
                analyzingOverlay
            }
        }
        .onChange(of: audioRecorder.showResultsScreen) { showResults in
            if showResults {
                onShowResults?(audioRecorder)
            }
        }
    }

    // MARK: - Header (text differs per screen)
    @ViewBuilder
    private var header: some View {
        VStack(spacing: 6) {
            Text("Voice Assessment")
                .font(.custom("Georgia-Bold", size: 24))
                .foregroundColor(VoiceFlowColors.primaryText)
                .multilineTextAlignment(.center)

            switch screen {
            case .home:
                Text("Let's check in on your fluency today!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(VoiceFlowColors.secondaryText)

            case .recording:
                Text("Listening... take your time")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(VoiceFlowColors.secondaryText)
                Text(formatTime(audioRecorder.recordingTime))
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.red)
                    .padding(.top, 2)

            case .paused:
                Text("Recording paused")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(VoiceFlowColors.secondaryText)
                Text(formatTime(audioRecorder.recordingTime))
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
    }

    // MARK: - Mic / Waveform Graphic (identical across all three screens)
    private var micGraphic: some View {
        ZStack {
            Circle()
                .fill(VoiceFlowColors.audioCircleOuter)
                .frame(width: 210, height: 210)

            Circle()
                .fill(VoiceFlowColors.audioCircleInner)
                .frame(width: 155, height: 155)

            HStack(spacing: 7) {
                Capsule().fill(VoiceFlowColors.waveformColor).frame(width: 7, height: 40)
                Capsule().fill(VoiceFlowColors.waveformColor).frame(width: 7, height: 65)
                Capsule().fill(VoiceFlowColors.waveformColor).frame(width: 7, height: 85)
                Capsule().fill(VoiceFlowColors.waveformColor).frame(width: 7, height: 55)
                Capsule().fill(VoiceFlowColors.waveformColor).frame(width: 7, height: 75)
                Capsule().fill(VoiceFlowColors.waveformColor).frame(width: 7, height: 42)
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: - Read Aloud Card (identical text across all three screens)
    private var readAloudCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("READ ALOUD")
                .font(.custom("Georgia-Bold", size: 12))
                .foregroundColor(VoiceFlowColors.primaryText)
                .tracking(0.8)

            Text("\"The soft breeze carried the calm sound of the river, gently drifting through the quiet morning air.\"")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(VoiceFlowColors.secondaryText)
                .lineSpacing(4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(VoiceFlowColors.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 24)
        .padding(.top, 25)
    }

    // MARK: - Controls (Start / Restart-Stop-Pause / Restart-Stop-Resume)
    @ViewBuilder
    private var controls: some View {
        switch screen {

        // ---- HOME: single full-width Start button ----
        case .home:
            Button(action: {
                audioRecorder.startRecording()
                screen = .recording
            }) {
                Text("Start")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(VoiceFlowColors.buttonStart)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 33)
            .padding(.top, 122)
            .padding(.bottom, 40)

        // ---- RECORDING: Restart / Stop / Pause ----
        case .recording:
            HStack(alignment: .center, spacing: 35) {
                controlButton(icon: "xmark", label: "Restart", bg: VoiceFlowColors.controlButtonBg, size: 50) {
                    audioRecorder.stopRecording()
                    screen = .home
                }

                controlButton(square: true, label: "Stop", bg: VoiceFlowColors.buttonStop, size: 62) {
                    audioRecorder.stopRecording() // already triggers analyzeAudio()
                }

                controlButton(icon: "pause.fill", label: "Pause", bg: VoiceFlowColors.controlButtonBg, size: 50) {
                    screen = .paused
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 30)

        // ---- PAUSED: Restart / Stop / Resume ----
        case .paused:
            HStack(alignment: .center, spacing: 35) {
                controlButton(icon: "xmark", label: "Restart", bg: VoiceFlowColors.controlButtonBg, size: 50) {
                    audioRecorder.stopRecording()
                    screen = .home
                }

                controlButton(square: true, label: "Stop", bg: VoiceFlowColors.buttonStop, size: 62) {
                    audioRecorder.stopRecording() // already triggers analyzeAudio()
                }

                controlButton(icon: "play.fill", label: "Resume", bg: VoiceFlowColors.controlButtonBg, size: 50) {
                    audioRecorder.resumeRecording()
                    screen = .recording
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
        }
    }

    // Reusable round control button (covers restart/pause/resume icon buttons and the square stop button)
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
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(VoiceFlowColors.secondaryText)
            }
        }
    }

    // MARK: - Analyzing Overlay
    private var analyzingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
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
    }

    // MARK: - Tab Bar (merged HomeTabBarView / AssessmentTabBarView / PausedTabBarView)
    private var tabBar: some View {
        HStack {
            FlowTabItem(icon: "mic.fill", label: "Assess", tag: 0, selectedTab: $selectedTab)
            FlowTabItem(icon: "person.wave.2", label: "Exercises", tag: 1, selectedTab: $selectedTab)
            FlowTabItem(icon: "chart.bar.fill", label: "Progress", tag: 2, selectedTab: $selectedTab)
            FlowTabItem(icon: "square.and.pencil", label: "Journal", tag: 3, selectedTab: $selectedTab)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(Color.white)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(VoiceFlowColors.activeYellow, lineWidth: 3)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .shadow(color: .black.opacity(0.08), radius: 6, y: -2)
    }

    // MARK: - Time formatting
    private func formatTime(_ totalSeconds: TimeInterval) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = Int(totalSeconds) / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Tab Bar Item (shared)
private struct FlowTabItem: View {
    let icon: String
    let label: String
    let tag: Int
    @Binding var selectedTab: Int

    var isActive: Bool { selectedTab == tag }

    var body: some View {
        Button(action: { selectedTab = tag }) {
            VStack(spacing: 4) {
                ZStack {
                    if isActive {
                        Circle()
                            .fill(VoiceFlowColors.activeYellow)
                            .frame(width: 36, height: 36)
                    }
                    Image(systemName: icon)
                        .foregroundColor(isActive ? .black : .gray)
                }
                Text(label)
                    .font(.system(size: 11, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? .black : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview
#Preview {
    VoiceAssessmentFlowView()
}
