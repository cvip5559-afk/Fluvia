//
//  SoundProlongationView.swift
//  Fluvia


import SwiftUI

struct SoundProlongationView: View {

    var onBack: (() -> Void)? = nil
    var onGoHome: (() -> Void)? = nil

    // MARK: Palette 
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow

    @State private var showExcellent = false

    // MARK: Flip-card game state
    
    @State private var currentStepIndex: Int = 0
    @State private var flippedStepID: UUID? = nil

    // MARK: Shared streak progress
    @State private var didMarkDayComplete = StreakManager.isTodayCompleted

    
    private let steps: [ExerciseStep] = [
        ExerciseStep(number: "1", title: "Read slowly",
                     description: "Pick a word and read it at a very slow, relaxed pace.",
                     color: Color(red: 0.35, green: 0.25, blue: 0.15)),
        ExerciseStep(number: "2", title: "Repeat the word",
                     description: "Say the same word a few times, keeping it steady.",
                     color: Color(red: 0.45, green: 0.55, blue: 0.35)),
        ExerciseStep(number: "3", title: "Focus on smooth airflow",
                     description: "Keep a continuous, gentle airflow as you speak.",
                     color: Color(red: 0.75, green: 0.65, blue: 0.5)),
        ExerciseStep(number: "4", title: "Try a full sentence",
                     description: "Apply the same technique to a complete sentence.",
                     color: Color.yellow)
    ]

    private var allStepsCompleted: Bool { currentStepIndex >= steps.count }

    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        titleSection
                        headerCard
                        cardGrid
                        finishButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 40)
                }
            }

         
            if showExcellent {
                completionCard
                    .zIndex(1)
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

            Text("Say It Slow")
                .font(.custom("Georgia", size: 30))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)

            Text("Prolongation Practice")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary.opacity(0.5))
        }
        .padding(.top, 8)
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(goldColor.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: "waveform")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(darkTextColor)
            }

            Text("Tap a card to reveal the step. Flip through all four to finish.")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
    }

    // MARK: - Card Grid

    private var cardGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                FlipCard(
                    step: step,
                    status: status(for: index),
                    isFlipped: flippedStepID == step.id,
                    darkTextColor: darkTextColor,
                    greenColor: greenColor,
                    onTap: { handleTap(step: step, index: index) },
                    onComplete: { completeCard(index: index) }
                )
            }
        }
        .padding(.top, 4)
    }

    private func status(for index: Int) -> NodeStatus {
        if index < currentStepIndex { return .completed }
        if index == currentStepIndex { return .current }
        return .locked
    }

    private func handleTap(step: ExerciseStep, index: Int) {
        guard status(for: index) != .locked else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            flippedStepID = (flippedStepID == step.id) ? nil : step.id
        }
    }

    private func completeCard(index: Int) {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentStepIndex = min(currentStepIndex + 1, steps.count)
            flippedStepID = nil
        }
    }

    // MARK: - Finish Button

    private var finishButton: some View {
        Button(action: { showExcellent = true }) {
            HStack(spacing: 8) {
                Image(systemName: allStepsCompleted ? "trophy.fill" : "lock.fill")
                Text(allStepsCompleted ? "Finish" : "Flip all 4 cards to finish")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(allStepsCompleted ? goldColor : Color.gray.opacity(0.35))
            .cornerRadius(18)
        }
        .disabled(!allStepsCompleted)
        .animation(.easeInOut(duration: 0.2), value: allStepsCompleted)
    }

    // MARK: - Completion Card
    private var completionCard: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(goldColor.opacity(0.2))
                        .frame(width: 110, height: 110)
                    Image(systemName: "sparkles")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(goldColor)
                }

                Text("Excellent!")
                    .font(.custom("Georgia", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(darkTextColor)

                Text("You practiced slow, controlled prolongation. Small, steady gains like this add up fast.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Button(action: markDayComplete) {
                    HStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "flag.checkered")
                            Text("Done")
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(darkTextColor)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(goldColor)
                    .cornerRadius(18)
                }

                Button(action: { showExcellent = false }) {
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
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
            )
            .padding(.horizontal, 32)
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
                    .padding(.trailing, 40)
                    .padding(.top, 14)
                }
            }
        }
    }

    private func markDayComplete() {
        if !didMarkDayComplete {
            StreakManager.markTodayComplete()
            DailyProgressManager.markExerciseDone()
            didMarkDayComplete = true
        }
        onGoHome?()
    }
}

// MARK: - Node status

enum NodeStatus {
    case completed, current, locked
}

// MARK: - Data model for one step

struct ExerciseStep: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Flip Card

struct FlipCard: View {
    let step: ExerciseStep
    let status: NodeStatus
    let isFlipped: Bool
    let darkTextColor: Color
    let greenColor: Color
    let onTap: () -> Void
    let onComplete: () -> Void

    var body: some View {
        ZStack {
                        frontFace
                .opacity(isFlipped ? 0 : 1)
                .allowsHitTesting(!isFlipped)

                        backFace
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
                .allowsHitTesting(isFlipped)
        }
        .frame(height: 170)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(status == .locked ? 0 : 0.06), radius: 8, y: 4)
        )
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture { if status != .locked { onTap() } }
    }

    // MARK: Front

    private var frontFace: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(nodeFillColor)
                    .frame(width: 52, height: 52)

                switch status {
                case .completed:
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                case .current:
                    Text(step.number)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                case .locked:
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            Text(step.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(status == .locked ? .gray.opacity(0.6) : darkTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding()
    }

    // MARK: Back

    private var backFace: some View {
        VStack(spacing: 10) {
            Text(step.description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)

            if status == .current {
                Button(action: onComplete) {
                    Text("I practiced this")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(greenColor)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }

    private var nodeFillColor: Color {
        switch status {
        case .completed: return greenColor
        case .current: return step.color
        case .locked: return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Preview

#Preview {
    SoundProlongationView()
}
