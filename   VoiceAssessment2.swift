import SwiftUI

// MARK: - Hex Color Extension (Assessment Context)
extension Color {
    init(assessmentHex hex: String) {
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

// MARK: - Voice Assessment Theme Colors
struct VoiceAssessmentColors {
    static let background = Color(red: 0.98, green: 0.96, blue: 0.91)
    static let primaryText = Color.black
    static let secondaryText = Color(assessmentHex: "4A4A4A")
    static let cardBackground = Color.white
    static let audioCircleOuter = Color(assessmentHex: "EDEBE8")
    static let audioCircleInner = Color(assessmentHex: "E8B931")
    static let activeTabCircle = Color(assessmentHex: "F6C445")
    static let waveformColor = Color(assessmentHex: "3A220F")
    static let buttonStart = Color(assessmentHex: "8BAA6E")
    static let controlButtonBg = Color(assessmentHex: "E2E0D8")
    static let tabIconActive = Color.black
    static let tabIconInactive = Color(assessmentHex: "A0A0A0")
}

// MARK: - Main Voice Assessment View
struct VoiceAssessmentView: View {
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VoiceAssessmentColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // Header
                        VStack(spacing: 6) {
                            Text("Voice Assessment")
                                .font(.custom("Georgia-Bold", size: 24))
                                .foregroundColor(VoiceAssessmentColors.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("Listening... take your time")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(VoiceAssessmentColors.secondaryText)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)

                        // Audio Mic Graphic
                        ZStack {
                            Circle()
                                .fill(VoiceAssessmentColors.audioCircleOuter)
                                .frame(width: 210, height: 210)
                            
                            Circle()
                                .fill(VoiceAssessmentColors.audioCircleInner)
                                .frame(width: 155, height: 155)

                            // Custom Waveform Bars
                            HStack(spacing: 7) {
                                Capsule().fill(VoiceAssessmentColors.waveformColor).frame(width: 7, height: 40)
                                Capsule().fill(VoiceAssessmentColors.waveformColor).frame(width: 7, height: 65)
                                Capsule().fill(VoiceAssessmentColors.waveformColor).frame(width: 7, height: 85)
                                Capsule().fill(VoiceAssessmentColors.waveformColor).frame(width: 7, height: 55)
                                Capsule().fill(VoiceAssessmentColors.waveformColor).frame(width: 7, height: 75)
                                Capsule().fill(VoiceAssessmentColors.waveformColor).frame(width: 7, height: 42)
                            }
                        }
                        .padding(.vertical, 10)

                        // Read Aloud Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("READ ALOUD")
                                .font(.custom("Georgia-Bold", size: 12))
                                .foregroundColor(VoiceAssessmentColors.primaryText)
                                .tracking(0.8)

                            Text("\"The soft breeze carried the calm sound of the river, gently drifting through the quiet morning air.\"")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(VoiceAssessmentColors.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(VoiceAssessmentColors.cardBackground)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                        .padding(.horizontal, 24)
                        .padding(.top, 25)

                        // MARK: - Audio Controls (Restart / Stop / Pause)
                        HStack(alignment: .center, spacing: 35) {
                            
                            // Restart Button
                            Button(action: {
                                dismiss()
                            }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(VoiceAssessmentColors.controlButtonBg)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "xmark")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.black.opacity(0.7))
                                    }
                                    Text("Restart")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(VoiceAssessmentColors.secondaryText)
                                }
                            }
                            
                            // Stop Button
                            Button(action: {
                                print("Stop tapped")
                            }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(VoiceAssessmentColors.buttonStart)
                                            .frame(width: 62, height: 62)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.white)
                                            .frame(width: 20, height: 20)
                                    }
                                    Text("Stop")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(VoiceAssessmentColors.secondaryText)
                                }
                            }
                            
                            // Pause Button (NavigationLink to Paused View)
                            NavigationLink(destination: VoiceRecordingPausedView()) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(VoiceAssessmentColors.controlButtonBg)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "pause.fill")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black.opacity(0.7))
                                    }
                                    Text("Pause")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(VoiceAssessmentColors.secondaryText)
                                }
                            }
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 30)

                    }
                }

                // Custom Navigation Bar
                AssessmentTabBarView(selectedTab: $selectedTab)
                    .padding(.bottom, 12)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Assessment Tab Bar Main Component
struct AssessmentTabBarView: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            AssessmentTabItem(icon: "mic.fill", label: "Assess", tag: 0, selectedTab: $selectedTab)
            AssessmentTabItem(icon: "person.wave.2", label: "Exercises", tag: 1, selectedTab: $selectedTab)
            AssessmentTabItem(icon: "chart.bar.fill", label: "Progress", tag: 2, selectedTab: $selectedTab)
            AssessmentTabItem(icon: "square.and.pencil", label: "Journal", tag: 3, selectedTab: $selectedTab)
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

// MARK: - Assessment Tab Bar Item Component
struct AssessmentTabItem: View {
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
    VoiceAssessmentView()
}
