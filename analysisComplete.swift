import SwiftUI

struct analysisComplete: View {
    var onStart: () -> Void = {}
    var onBack: () -> Void = {}

    // MARK: - Body
    // Layout structure (matches the wireframe):
    // ZStack
    // └─ VStack (root)
    // ├─ Header
    // ├─ VStack (box 1: "Based on")
    // ├─ VStack (box 2: "Your Plan")
    // └─ Start Button

    var body: some View {
    ZStack {
    background

    ScrollView {
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
    .font(.system(size: 28, weight: .heavy))
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

    BasedOnRow(title: "Sudden blocks detected")
    BasedOnRow(title: "Rising tension before words")
    BasedOnRow(title: "Shallow breath support")
    }
    }

    // MARK: - Box 2: Your Plan

    private var yourPlanBox: some View {
    VStack(alignment: .leading, spacing: 16) {
    Text("Your Plan")
    .font(.system(size: 20, weight: .bold))
    .foregroundColor(.black)

    PlanStepCard(
    step: "STEP 1",
    title: "Breathing Exercise",
    description: "A short Warm-up to calm your breath before the main exercise.",
    systemIcon: "lungs.fill" // SF Symbol — no Assets entry needed
    )

    PlanStepCard(
    step: "STEP 2",
    title: "Sound Prolongation",
    description: "Chosen based on the sudden blocks and rising tension detected in your recording.",
    systemIcon: "waveform.path" // SF Symbol — no Assets entry needed
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

    // MARK: - Based On Row

    struct BasedOnRow: View {
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
    .font(.system(size: 17, weight: .bold))
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

    // MARK: - Plan Step Card

    struct PlanStepCard: View {
    let step: String
    let title: String
    let description: String

    /// Name of an image in Assets.xcassets (e.g. "breathing_icon", "sound_icon").
    /// Each card MUST use a different, unique asset name — reusing the same
    /// name across cards is why deleting one image removed both.
    var customImageName: String? = nil

    /// Fallback SF Symbol, used only if customImageName is nil or not found.
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

    // MARK: - Hex Color Helper

    extension Color {
    init(hex: String) {
    let scanner = Scanner(string: hex)
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)

    let r = Double((rgbValue & 0xFF0000) >> 16) / 255
    let g = Double((rgbValue & 0x00FF00) >> 8) / 255
    let b = Double(rgbValue & 0x0000FF) / 255

    self.init(red: r, green: g, blue: b)
    }
    }

    // MARK: - Preview
#Preview {
    analysisComplete()
}
