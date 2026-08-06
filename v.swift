//
//  v.swift
//  test
//
//  Created by Jinan Mahdi Alanazi on 23/02/1448 AH.
//
import SwiftUI

// MARK: - Hex Color Extension (Paused Context)
extension Color {
    init(pausedHex hex: String) {
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

// MARK: - Recording Paused Theme Colors
struct RecordingPausedColors {
    static let background = Color(red: 0.98, green: 0.96, blue: 0.91)
    static let primaryText = Color.black
    static let secondaryText = Color(pausedHex: "4A4A4A")
    static let cardBackground = Color.white
    static let audioCircleOuter = Color(pausedHex: "EDEBE8")
    static let audioCircleInner = Color(pausedHex: "E8B931")
    static let waveformColor = Color(pausedHex: "3A220F")
    static let controlButtonBg = Color(pausedHex: "E2E0D8")
    static let controlButtonStop = Color(pausedHex: "8BAA6E")
    static let activeYellow = Color(pausedHex: "F6C445")
}

// MARK: - Main Voice Recording Paused View
struct VoiceRecordingPausedView: View {
    @ObservedObject var audioRecorder: AudioRecorderManager // 📍 استقبال كائن التسجيل
    var onRestart: (() -> Void)? = nil
    
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            RecordingPausedColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // Header
                        VStack(spacing: 6) {
                            Text("Voice Assessment")
                                .font(.custom("Georgia-Bold", size: 24))
                                .foregroundColor(RecordingPausedColors.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("Recording paused")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(RecordingPausedColors.secondaryText)
                            
                            // ⏱️ عرض وقت التسجيل المتوقف عنده
                            Text(formatTime(audioRecorder.recordingTime))
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)

                        // Audio Mic Graphic
                        ZStack {
                            Circle()
                                .fill(RecordingPausedColors.audioCircleOuter)
                                .frame(width: 210, height: 210)
                            
                            Circle()
                                .fill(RecordingPausedColors.audioCircleInner)
                                .frame(width: 155, height: 155)

                            // Waveform Bars
                            HStack(spacing: 7) {
                                Capsule().fill(RecordingPausedColors.waveformColor).frame(width: 7, height: 40)
                                Capsule().fill(RecordingPausedColors.waveformColor).frame(width: 7, height: 65)
                                Capsule().fill(RecordingPausedColors.waveformColor).frame(width: 7, height: 85)
                                Capsule().fill(RecordingPausedColors.waveformColor).frame(width: 7, height: 55)
                                Capsule().fill(RecordingPausedColors.waveformColor).frame(width: 7, height: 75)
                                Capsule().fill(RecordingPausedColors.waveformColor).frame(width: 7, height: 42)
                            }
                        }
                        .padding(.vertical, 10)

                        // Read Aloud Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("READ ALOUD")
                                .font(.custom("Georgia-Bold", size: 12))
                                .foregroundColor(RecordingPausedColors.primaryText)
                                .tracking(0.8)

                            Text("\"The soft breeze carried the calm sound of the river, gently drifting through the quiet morning air.\"")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(RecordingPausedColors.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RecordingPausedColors.cardBackground)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                        .padding(.horizontal, 24)
                        .padding(.top, 25)

                        // MARK: - Audio Controls (Restart / Stop / Resume)
                        HStack(alignment: .center, spacing: 35) {
                            
                            // Restart Button
                            Button(action: {
                                audioRecorder.stopRecording()
                                dismiss()
                                onRestart?()
                            }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(RecordingPausedColors.controlButtonBg)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "xmark")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.black.opacity(0.7))
                                    }
                                    Text("Restart")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(RecordingPausedColors.secondaryText)
                                }
                            }
                            
                            // 🛑 Stop Button (إيقاف التسجيل وتحليله عبر AI)
                            Button(action: {
                                audioRecorder.stopRecording()
                                Task {
                                    await audioRecorder.analyzeAudio()
                                }
                            }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(RecordingPausedColors.controlButtonStop)
                                            .frame(width: 62, height: 62)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.white)
                                            .frame(width: 20, height: 20)
                                    }
                                    Text("Stop")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(RecordingPausedColors.secondaryText)
                                }
                            }
                            
                            // Resume Button (العودة لشاشة التسجيل النشطة)
                            Button(action: {
                                dismiss()
                            }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(RecordingPausedColors.controlButtonBg)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.black.opacity(0.7))
                                    }
                                    Text("Resume")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(RecordingPausedColors.secondaryText)
                                }
                            }
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 30)

                    }
                }

                // Custom Floating Tab Bar
                PausedTabBarView(selectedTab: $selectedTab)
            }

            // ⏳ مؤشر التحميل أثناء انتظار تحليل الـ AI
            if audioRecorder.isAnalyzing {
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
        }
        .navigationBarBackButtonHidden(true)
    }

    // دالة لتنسيق الوقت من ثوانٍ إلى صيغة (00:00)
    private func formatTime(_ totalSeconds: TimeInterval) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = Int(totalSeconds) / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Tab Bar Main Component
struct PausedTabBarView: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            PausedTabItem(icon: "mic.fill", label: "Assess", tag: 0, selectedTab: $selectedTab)
            PausedTabItem(icon: "person.wave.2", label: "Exercises", tag: 1, selectedTab: $selectedTab)
            PausedTabItem(icon: "chart.bar.fill", label: "Progress", tag: 2, selectedTab: $selectedTab)
            PausedTabItem(icon: "square.and.pencil", label: "Journal", tag: 3, selectedTab: $selectedTab)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(Color.white)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(RecordingPausedColors.activeYellow, lineWidth: 3)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .shadow(color: .black.opacity(0.08), radius: 6, y: -2)
    }
}

// MARK: - Tab Bar Item Component
struct PausedTabItem: View {
    let icon: String
    let label: String
    let tag: Int
    @Binding var selectedTab: Int

    var isActive: Bool {
        selectedTab == tag
    }

    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isActive {
                        Circle()
                            .fill(RecordingPausedColors.activeYellow)
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
    VoiceRecordingPausedView(audioRecorder: AudioRecorderManager())
}
