import SwiftUI
  
// MARK: - Main Container View
struct MainContainerView: View {
    @State private var showBreathingOption: Bool = true
    @State private var showBreathing: Bool = false

    var body: some View {
        ZStack {
            // الشاشة الرئيسية أو الخلفية (تصبح مشوشة عند ظهور البوب أب)
            sample3()
                .blur(radius: (showBreathingOption && !showBreathing) ? 10 : 0)
                .animation(.easeInOut(duration: 0.3), value: showBreathingOption)
                .disabled(showBreathingOption)

            // 1. شاشة الخيار المنبثقة (Popup)
            if showBreathingOption && !showBreathing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showBreathingOption = false
                        }
                    }
                
                VStack(spacing: 18) {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 42))
                        .foregroundColor(Color(red: 0.75, green: 0.55, blue: 0.35))
                    
                    Text("Breathing Exercise")
                        .font(.custom("Georgia-Bold", size: 22))
                        .foregroundColor(.primary)
                    
                    Text("Would you like to start a breathing exercise to relax now?")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    
                    HStack(spacing: 12) {
                        // زر التجاهل
                        Button(action: {
                            withAnimation {
                                showBreathingOption = false
                            }
                        }) {
                            Text("Not Now")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(12)
                        }
                        
                        // زر الموافقة والتنقل الفوري
                        Button(action: {
                            showBreathingOption = false
                            showBreathing = true // يفتح الشاشة فوراً
                        }) {
                            Text("Start Now")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.55, green: 0.65, blue: 0.45))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.98, green: 0.97, blue: 0.94))
                        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 28)
            }

            // 2. Breathing Screen appears instantly (No Animation)
            if showBreathing {
                sample3(onBack: {
                    showBreathing = false
                })
                .zIndex(1)
            }
        }
    }
}

// MARK: - Breathing Exercise View
struct sample3: View {
    var onBack: (() -> Void)? = nil
    
    private let totalSeconds: Int
    @State private var secondsLeft: Int
    @State private var progress: CGFloat = 1.0
    @State private var timer: Timer? = nil

    init(totalSeconds: Int = 10, onBack: (() -> Void)? = nil) {
        self.totalSeconds = totalSeconds
        self.onBack = onBack
        _secondsLeft = State(initialValue: totalSeconds)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 22) {

                    Text("Breathing Exercise")
                        .font(.custom("Georgia-Bold", size: 30))
                        .padding(.top, 30)

                    Image(systemName: "lungs.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.brown)

                    Text("Take a few deep breaths to\nrelax your body.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    ZStack {
                        Circle()
                            .stroke(Color.yellow.opacity(0.25), lineWidth: 14)
                            .frame(width: 220, height: 220)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color.yellow,
                                style: StrokeStyle(
                                    lineWidth: 14,
                                    lineCap: .round
                                )
                            )
                            .frame(width: 220, height: 220)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)

                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 180, height: 180)

                        VStack(spacing: 4) {
                            Text("\(secondsLeft)")
                                .font(.system(size: 50, weight: .bold))
                                .contentTransition(.numericText(countsDown: true))

                            Text("SEC")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .padding(.vertical, 10)
                    .onAppear {
                        startTimer()
                    }
                    .onDisappear {
                        stopTimer()
                    }

                    VStack(spacing: 14) {
                        StepRow(number: 1, text: "Sit comfortably", color: .brown)

                        StepRow(
                            number: 2,
                            text: "Inhale slowly",
                            color: Color(red: 0.55, green: 0.75, blue: 0.55)
                        )

                        StepRow(
                            number: 3,
                            text: "Hold for few seconds",
                            color: Color(red: 0.75, green: 0.68, blue: 0.5)
                        )

                        StepRow(
                            number: 4,
                            text: "Exhale gently",
                            color: .yellow
                        )
                    }
                    .padding(.horizontal)

                    Button {
                        stopTimer()
                        onBack?() // العودة للخلف مباشرة
                    } label: {
                        Text("Done")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Color(red: 0.55, green: 0.65, blue: 0.45)
                            )
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                }
                .padding(.bottom, 20)
            }

            BottomTabBar()
        }
        .background(
            Color(red: 0.97, green: 0.95, blue: 0.90)
                .ignoresSafeArea()
        )
    }

    // MARK: - Timer Logic
    private func startTimer() {
        stopTimer()
        secondsLeft = totalSeconds
        progress = 1.0

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsLeft > 0 {
                secondsLeft -= 1
                withAnimation {
                    progress = CGFloat(secondsLeft) / CGFloat(totalSeconds)
                }
            }

            if secondsLeft == 0 {
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Step Row
struct StepRow: View {
    let number: Int
    let text: String
    let color: Color

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)

                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(text)
                .font(.system(size: 16, weight: .semibold))

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(
            color: .black.opacity(0.08),
            radius: 6,
            x: 0,
            y: 3
        )
    }
}

// MARK: - Bottom Tab Bar
struct BottomTabBar: View {
    private var barShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 24,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 24
        )
    }

    var body: some View {
        HStack {
            TabItem(icon: "mic.fill", title: "Assess", isSelected: false)
            TabItem(icon: "person.2.fill", title: "Exercises", isSelected: true)
            TabItem(icon: "chart.bar.fill", title: "Progress", isSelected: false)
            TabItem(icon: "square.and.pencil", title: "Journal", isSelected: false)
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Color.white)
        .clipShape(barShape)
        .overlay(
            barShape.strokeBorder(Color.yellow, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: -3)
    }
}

// MARK: - Tab Item
struct TabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 36, height: 36)
                }

                Image(systemName: icon)
                    .foregroundColor(isSelected ? .black : .gray)
            }

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? .black : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainContainerView()
}

