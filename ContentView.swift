//
//  ContentView.swift
//  test
//
//  Created by Jinan Mahdi Alanazi on 23/02/1448 AH.
//
//
//  ContentView.swift
//  test
//
//  Created by Jinan Mahdi Alanazi on 23/02/1448 AH.
//
import SwiftUI

// MARK: - App Color Palette
struct VoiceAssessmentColor {
    static let background = Color(red: 0.98, green: 0.96, blue: 0.91)
    static let primaryText = Color.black
    static let secondaryText = Color(hex: "4A4A4A")
    static let cardBackground = Color.white
    static let audioCircleOuter = Color(hex: "EDEBE8")
    static let audioCircleInner = Color(hex: "E8B931")
    static let activeTabCircle = Color(hex: "F6C445")
    static let waveformColor = Color(hex: "3A220F")
    static let buttonStart = Color(hex: "95B173")
    static let tabIconActive = Color.black
    static let tabIconInactive = Color(hex: "A0A0A0")
}

// MARK: - Main View
struct VoiceAssessmentHomeView: View {
    @StateObject private var audioRecorder = AudioRecorderManager()
    @State private var selectedTab = 0
    @State private var showRecordingView = false

    var body: some View {
        ZStack {
            VoiceAssessmentColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // Header
                        VStack(spacing: 6) {
                            Text("Voice Assessment")
                                .font(.custom("Georgia-Bold", size: 24))
                                .foregroundColor(VoiceAssessmentColor.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("Let's check in on your fluency today!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(VoiceAssessmentColor.secondaryText)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)

                        // Audio Mic Graphic
                        ZStack {
                            Circle()
                                .fill(VoiceAssessmentColor.audioCircleOuter)
                                .frame(width: 210, height: 210)
                            
                            Circle()
                                .fill(VoiceAssessmentColor.audioCircleInner)
                                .frame(width: 155, height: 155)

                            HStack(spacing: 7) {
                                Capsule().fill(VoiceAssessmentColor.waveformColor).frame(width: 7, height: 40)
                                Capsule().fill(VoiceAssessmentColor.waveformColor).frame(width: 7, height: 65)
                                Capsule().fill(VoiceAssessmentColor.waveformColor).frame(width: 7, height: 85)
                                Capsule().fill(VoiceAssessmentColor.waveformColor).frame(width: 7, height: 55)
                                Capsule().fill(VoiceAssessmentColor.waveformColor).frame(width: 7, height: 75)
                                Capsule().fill(VoiceAssessmentColor.waveformColor).frame(width: 7, height: 42)
                            }
                        }
                        .padding(.vertical, 10)

                        // Read Aloud Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("READ ALOUD")
                                .font(.custom("Georgia-Bold", size: 12))
                                .foregroundColor(VoiceAssessmentColor.primaryText)
                                .tracking(0.8)

                            Text("The soft breeze carried the calm sound of the river, gently drifting through the quiet morning air.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(VoiceAssessmentColor.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(VoiceAssessmentColor.cardBackground)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                        .padding(.horizontal, 24)
                        .padding(.top, 25)

                        // Button Start
                        Button(action: {
                            audioRecorder.startRecording()
                            showRecordingView = true
                        }) {
                            Text("Start")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(VoiceAssessmentColor.buttonStart)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 33)
                        .padding(.top, 122)
                        .padding(.bottom, 40)

                    }
                }

                // Custom Tab Bar
                HomeTabBarView(selectedTab: $selectedTab)
                    .padding(.bottom, 12)
            }

            // 1. شاشة التسجيل الصوتية
            if showRecordingView && !audioRecorder.showResultsScreen {
                VoiceAssessmentView(audioRecorder: audioRecorder, onBack: {
                    audioRecorder.stopRecording()
                    showRecordingView = false
                })
                .zIndex(1)
            }

            // 2. شاشة تحليل النتائج (تفتح أوتوماتيكياً عند اكتمال التسجيل)
            if audioRecorder.showResultsScreen {
                AnalysisCompleteView(
                    audioRecorder: audioRecorder,
                    onStart: {
                        // كود شاشة التمرين (يتولاه زميلك)
                    },
                    onBack: {
                        audioRecorder.showResultsScreen = false
                        showRecordingView = false
                    }
                )
                .zIndex(2)
            }
        }
    }
}

// MARK: - Tab Bar Main Component
struct HomeTabBarView: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            HomeTabItem(icon: "mic.fill", label: "Assess", tag: 0, selectedTab: $selectedTab)
            HomeTabItem(icon: "person.wave.2", label: "Exercises", tag: 1, selectedTab: $selectedTab)
            HomeTabItem(icon: "chart.bar.fill", label: "Progress", tag: 2, selectedTab: $selectedTab)
            HomeTabItem(icon: "square.and.pencil", label: "Journal", tag: 3, selectedTab: $selectedTab)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(Color.white)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.yellow, lineWidth: 3)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .shadow(color: .black.opacity(0.08), radius: 6, y: -2)
    }
}

// MARK: - Tab Bar Item Component
struct HomeTabItem: View {
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
                            .fill(Color.yellow)
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
    VoiceAssessmentHomeView()
}
