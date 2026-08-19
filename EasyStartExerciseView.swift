//
//
//  EasyStartExerciseView.swift
//  fluvia
//

import SwiftUI

private enum BreathPhase {
    case idle
    case breathingIn
    case glide
}

struct EasyStartExerciseView: View {

    var onBack: (() -> Void)? = nil
    var onGoHome: (() -> Void)? = nil

    // MARK: Palette 
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow

    
    private let phrases = [
        "I appreciate you taking the time today.",
        "Actually, I'd love to hear your thoughts first.",
        "Everyone brings something valuable to the table.",
        "Above all, trust the progress you've already made."
    ]

    // MARK: State
    @State private var currentIndex = 0
    @State private var phase: BreathPhase = .idle
    @State private var breathScale: CGFloat = 0.85
    @State private var completedIndices: Set<Int> = []
    @State private var sessionFinished = false

    // MARK: Shared streak progress (tracked by real calendar date)
    @State private var didMarkDayComplete = StreakManager.isTodayCompleted

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        titleSection

                        if sessionFinished {
                            completionCard
                        } else {
                            progressBar
                            breathCoachCard
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 4) {
            if let onBack {
                HStack {
                    BackButton(action: onBack, textColor: darkTextColor)
                    Spacer()
                }
                .padding(.bottom, 4)
            }

            Text("Easy Start")
                .font(.custom("Georgia", size: 30))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)

            Text("Guided Breath Coach")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary.opacity(0.5))
        }
        .padding(.top, 8)
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Phrase \(currentIndex + 1) of \(phrases.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(darkTextColor.opacity(0.7))
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)

                    Capsule()
                        .fill(greenColor)
                        .frame(width: geo.size.width * progressFraction, height: 6)
                        .animation(.easeInOut(duration: 0.4), value: currentIndex)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 4)
    }

    private var progressFraction: CGFloat {
        CGFloat(completedIndices.count) / CGFloat(phrases.count)
    }

    // MARK: - Breath Coach Card

    private var breathCoachCard: some View {
        VStack(spacing: 24) {
            HStack(spacing: 10) {
                Image(systemName: "lungs.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(darkTextColor)
                Text("Follow the Breath")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(darkTextColor)
                Spacer()
            }

            breathBubble

            phaseCaption

            actionButton
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 6)
        )
    }

    // MARK: - Breathing bubble 

    private var breathBubble: some View {
        ZStack {
            Circle()
                .fill(bubbleColor.opacity(0.18))
                .frame(width: 210, height: 210)
                .scaleEffect(breathScale)

            Circle()
                .fill(bubbleColor.opacity(0.32))
                .frame(width: 150, height: 150)
                .scaleEffect(breathScale)

            Group {
                switch phase {
                case .idle:
                    Image(systemName: "wind")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(darkTextColor.opacity(0.5))

                case .breathingIn:
                    Text("Breathe in…")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(darkTextColor)

                case .glide:
                    Text(phrases[currentIndex])
                        .font(.custom("Georgia", size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(darkTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
            }
        }
        .frame(height: 220)
    }

    private var bubbleColor: Color {
        switch phase {
        case .idle: return Color.gray
        case .breathingIn: return goldColor
        case .glide: return greenColor
        }
    }

    private var phaseCaption: some View {
        Text(captionText)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.primary.opacity(0.5))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private var captionText: String {
        switch phase {
        case .idle:
            return "Tap Begin, then just follow along no need to hold anything down."
        case .breathingIn:
            return "Let your shoulders drop and take a slow breath in."
        case .glide:
            return "Say the phrase gently on your outgoing breath, then confirm below."
        }
    }

    private var actionButton: some View {
        Group {
            switch phase {
            case .idle:
                Button(action: startBreathIn) {
                    Text("Begin")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(greenColor)
                        .cornerRadius(18)
                }

            case .breathingIn:
                Text("Breathing…")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(18)

            case .glide:
                Button(action: confirmSpoken) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("I Said It")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(greenColor)
                    .cornerRadius(18)
                }
            }
        }
    }

    // MARK: - Flow logic

    private func startBreathIn() {
        phase = .breathingIn
        withAnimation(.easeInOut(duration: 2.2)) {
            breathScale = 1.15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            enterGlidePhase()
        }
    }

    private func enterGlidePhase() {
        withAnimation(.easeInOut(duration: 0.4)) {
            phase = .glide
            breathScale = 1.0
        }
    }

    private func confirmSpoken() {
        completedIndices.insert(currentIndex)

        if currentIndex == phrases.count - 1 {
            withAnimation { sessionFinished = true }
            return
        }

        withAnimation(.easeInOut(duration: 0.35)) {
            currentIndex += 1
            phase = .idle
            breathScale = 0.85
        }
    }

    // MARK: - Completion Card

    private var completionCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(goldColor.opacity(0.2))
                    .frame(width: 110, height: 110)
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(goldColor)
            }

            Text("Session Complete!")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)

            Text("You practiced \(phrases.count) gentle, easy starts. A calm breath before you speak makes all the difference.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary.opacity(0.6))
                .multilineTextAlignment(.center)

            Button(action: markDayComplete) {
                HStack(spacing: 8) {
                    Image(systemName: "flag.checkered")
                    Text("Done")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(darkTextColor)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(goldColor)
                .cornerRadius(18)
            }

            Button(action: resetSession) {
                Text("Practice Again")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(greenColor)
                    .cornerRadius(18)
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 6)
        )
        .overlay(alignment: .topTrailing) {
            if let onGoHome {
                Button(action: onGoHome) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(darkTextColor)
                        .padding(8)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Circle())
                }
                .padding(14)
            }
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

    private func resetSession() {
        withAnimation {
            currentIndex = 0
            phase = .idle
            breathScale = 0.85
            completedIndices.removeAll()
            sessionFinished = false
        }
    }
}

// MARK: - Preview

#Preview {
    EasyStartExerciseView()
}
