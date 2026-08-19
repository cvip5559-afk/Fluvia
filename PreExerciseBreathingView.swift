//
//  PreExerciseBreathingView.swift
//  fluvia


import SwiftUI

struct PreExerciseGateView<Destination: View>: View {
    let onBack: () -> Void
    @ViewBuilder let destination: () -> Destination

    private enum Stage {
        case prompt
        case breathing
        case exercise
    }

    private enum BreathPhase {
        case inhale
        case exhale
    }

    @State private var stage: Stage = .prompt

    // MARK: Breathing config — 4s inhale + 4s exhale = 8s per cycle
    private let inhaleDuration = 4
    private let exhaleDuration = 4
    private let totalSessionDuration = 32 // 4 full cycles

    @State private var phase: BreathPhase = .inhale
    @State private var phaseElapsed = 0
    @State private var totalElapsed = 0
    @State private var breathTimer: Timer?
    @State private var circleScale: CGFloat = 0.85 // Initial standard scale

    // MARK: Palette (unified with the rest of the app)
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let purpleColor     = Color(red: 0.58, green: 0.40, blue: 0.68)

    var body: some View {
        switch stage {
        case .prompt:
            promptCard
        case .breathing:
            breathingView
        case .exercise:
            destination()
        }
    }

    // MARK: - Prompt

    private var promptCard: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(purpleColor.opacity(0.2))
                        .frame(width: 90, height: 90)
                    Image(systemName: "wind")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(darkTextColor)
                }

                Text("Before You Start")
                    .font(.custom("Georgia", size: 30))
                    .fontWeight(.bold)
                    .foregroundColor(darkTextColor)

                Text("A calm breath can make the difference between tension and ease. Want to take 30 seconds to settle in first?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Button(action: startBreathing) {
                    Text("Yes, Breathe First")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(greenColor)
                        .cornerRadius(18)
                }

                Button(action: skipBreathing) {
                    Text("Skip")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(darkTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(18)
                }

                Button(action: onBack) {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 2)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 8)
            )
            .padding(.horizontal, 28)
        }
    }

    // MARK: - Breathing View

    private var phaseTitle: String {
        phase == .inhale ? "Inhale" : "Exhale"
    }

    private var phaseInstruction: String {
        phase == .inhale
            ? "Slowly fill your lungs with air."
            : "Gently release your breath."
    }

    private var totalSecondsRemaining: Int {
        max(totalSessionDuration - totalElapsed, 0)
    }

    private var breathingView: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header Bar
                ZStack {
                    VStack {
                        HStack {
                            BackButton(action: onBack, textColor: darkTextColor)
                            Spacer()
                        }

                        Text("Just Breathe")
                            .font(.custom("Georgia-Bold", size: 30))
                            .foregroundColor(darkTextColor)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // Circle Container & Subtitles Stack 
                VStack(spacing: 0) {
                    // Circle Container with white text inside
                    ZStack {
                        // Outer soft circle
                        Circle()
                            .fill(purpleColor.opacity(0.18))
                            .frame(width: 220, height: 220)
                            .scaleEffect(circleScale * 1.15)

                        // Inner main circle
                        Circle()
                            .fill(purpleColor.opacity(0.60))
                            .frame(width: 170, height: 170)
                            .scaleEffect(circleScale)

                        // Text inside circle
                        Text(phaseTitle)
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .tracking(1.5)
                            .textCase(.uppercase)
                    }
                    .frame(height: 260)

                   
                    VStack(spacing: 10) {
                        Text(phaseInstruction)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Text("\(totalSecondsRemaining)s left")
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.top, 40)
                }

                Spacer()
            }
        }
        .onAppear {
            startBreathingSession()
        }
        .onDisappear {
            breathTimer?.invalidate()
        }
    }

    // MARK: - Flow Control & Animation Logic

    private func startBreathing() {
        withAnimation { stage = .breathing }
    }

    private func skipBreathing() {
        withAnimation { stage = .exercise }
    }

    private func startBreathingSession() {
        phase = .inhale
        phaseElapsed = 0
        totalElapsed = 0
        
        triggerLungAnimation()

        breathTimer?.invalidate()
        breathTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            totalElapsed += 1
            phaseElapsed += 1

            let currentPhaseDuration = (phase == .inhale) ? inhaleDuration : exhaleDuration
            
            if phaseElapsed >= currentPhaseDuration {
                phaseElapsed = 0
                phase = (phase == .inhale) ? .exhale : .inhale
                triggerLungAnimation()
            }

            if totalElapsed >= totalSessionDuration {
                breathTimer?.invalidate()
                withAnimation { stage = .exercise }
            }
        }
    }

    private func triggerLungAnimation() {
        let duration = Double(phase == .inhale ? inhaleDuration : exhaleDuration)
        let targetScale: CGFloat = (phase == .inhale) ? 1.25 : 0.85

        withAnimation(.easeInOut(duration: duration)) {
            circleScale = targetScale
        }
    }
}
