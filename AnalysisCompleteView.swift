import SwiftUI

struct AnalysisCompleteView: View {
    @ObservedObject var audioRecorder: AudioRecorderManager
    var onStart: () -> Void = {}
    var onBack: () -> Void = {}

    var body: some View {
        ZStack {
            background

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    basedOnBox
                    yourPlanBox
                    Spacer(minLength: 20)
                    startButton
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Background
    private var background: some View {
        LinearGradient(
            colors: [Color(hex: "FFFBF0"), Color(hex: "EDE9DC")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .overlay(
            Text("Analysis Complete")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
        )
        .padding(.top, 10)
    }

    // MARK: - Box 1: Based on
    private var basedOnBox: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Based on")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            if let result = audioRecorder.assessmentResult {
                AnalysisObservationRow(title: result)
            } else {
                AnalysisObservationRow(title: "Sudden blocks detected")
                AnalysisObservationRow(title: "Rising tension before words")
                AnalysisObservationRow(title: "Shallow breath support")
            }
        }
    }

    // MARK: - Box 2: Your Plan
    private var yourPlanBox: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Plan")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            AnalysisPlanStepCard(
                step: "STEP 1",
                title: "Breathing Exercise",
                description: "A short Warm-up to calm your breath before the main exercise.",
                systemIcon: "lungs.fill"
            )

            AnalysisPlanStepCard(
                step: "STEP 2",
                title: "Sound Prolongation",
                description: "Chosen based on the sudden blocks and rising tension detected in your recording.",
                systemIcon: "waveform.path"
            )
        }
    }

    // MARK: - Start Button
    private var startButton: some View {
        Button(action: onStart) {
            Text("Start Exercise")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(hex: "8FAE68"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

// MARK: - Private Helper Views
private struct AnalysisObservationRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "8B7FD4"))
            }

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(hex: "A79AE8"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 4)
    }
}

private struct AnalysisPlanStepCard: View {
    let step: String
    let title: String
    let description: String
    var customImageName: String? = nil
    var systemIcon: String = "questionmark"

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)

                if let customImageName, UIImage(named: customImageName) != nil {
                    Image(customImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                } else {
                    Image(systemName: systemIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(step)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black.opacity(0.6))

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(hex: "D6CFF2"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Color Hex Extension (حل المشكلة الأساسية)
extension Color {
    init(khex: String) {
        let hex = khex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8 * 17), (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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

// MARK: - Preview
#Preview {
    AnalysisCompleteView(audioRecorder: AudioRecorderManager())
}
