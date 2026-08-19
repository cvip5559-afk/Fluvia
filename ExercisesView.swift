//
//  ExercisesView.swift
//  fluvia
//
//  Created by Aleen Aldosari.



import SwiftUI

// MARK: - Model

struct ExerciseCategory: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let tint: Color
}

// MARK: - ExercisesView

struct ExercisesView: View {

    // MARK: Palette (unified with the rest of the app)
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow
    private let purpleColor     = Color(red: 0.52, green: 0.40, blue: 0.60)

    private var categories: [ExerciseCategory] {
        [
            ExerciseCategory(
                title: "Say It Slow",
                description: "Elongated syllable, e.g. M[mmm]ommy",
                icon: "waveform.path",
                tint: greenColor
            ),
            ExerciseCategory(
                title: "Easy Start",
                description: "Gasps for air or stuttered pauses",
                icon: "lungs.fill",
                tint: purpleColor
            ),
            ExerciseCategory(
                title: "Smooth Start",
                description: "Repeated syllables, e.g. I [pr-pr-pr-] prepared dinner",
                icon: "repeat",
                tint: greenColor
            ),
            ExerciseCategory(
                title: "Say It Once",
                description: "Word or phrase is repeated, e.g. I made [made] dinner",
                icon: "text.word.spacing",
                tint: purpleColor
            ),
            ExerciseCategory(
                title: "Silent Pause",
                description: "Filler words like \"um\" or \"uh\" used to cope with a stutter",
                icon: "quote.bubble.fill",
                tint: goldColor
            )
        ]
    }

    @State private var selectedCategory: ExerciseCategory? = nil
    var autoOpenCategoryTitle: String? = nil
    var onBack: (() -> Void)? = nil
    var onGoHome: () -> Void = {}

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        titleSection

                        VStack(spacing: 14) {
                            ForEach(categories) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    ExerciseCard(category: category, darkTextColor: darkTextColor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 100) // room above the global tab bar
                }
            }

           
            if let category = selectedCategory {
                PreExerciseGateView(onBack: { selectedCategory = nil }) {
                    destination(for: category, onBack: { selectedCategory = nil })
                }
                .zIndex(1)
            }
        }
        .onAppear {
            guard selectedCategory == nil, let title = autoOpenCategoryTitle else { return }
            selectedCategory = categories.first { $0.title == title }
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

            Text("Exercises")
                .font(.custom("Georgia", size: 30))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)

            Text("Pick a stutter type to practice")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary.opacity(0.5))
        }
        .padding(.top, 8)
    }

    // MARK: - Routing

    @ViewBuilder
    private func destination(for category: ExerciseCategory, onBack: @escaping () -> Void) -> some View {
        if category.title == "Smooth Start" {
            SoundRepetitionExerciseView(onBack: onBack, onGoHome: onGoHome)
        } else if category.title == "Silent Pause" {
            PauseExerciseView(onBack: onBack, onGoHome: onGoHome)
        } else if category.title == "Easy Start" {
            EasyStartExerciseView(onBack: onBack, onGoHome: onGoHome)
        } else if category.title == "Say It Slow" {
            SoundProlongationView(onBack: onBack, onGoHome: onGoHome)
        } else if category.title == "Say It Once" {
            SayItOnceExerciseView(onBack: onBack, onGoHome: onGoHome)
        } else {
            ComingSoonExerciseView(category: category, onBack: onBack)
        }
    }
}

// MARK: - Exercise Card

private struct ExerciseCard: View {
    let category: ExerciseCategory
    let darkTextColor: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(category.tint.opacity(0.18))
                    .frame(width: 52, height: 52)

                Image(systemName: category.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(category.tint == Color.yellow ? .orange : category.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(darkTextColor)

                Text(category.description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Placeholder Exercise Screen


struct ComingSoonExerciseView: View {
    let category: ExerciseCategory
    var onBack: (() -> Void)? = nil

    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {
                        if let onBack {
                            HStack {
                                BackButton(action: onBack, textColor: darkTextColor)
                                Spacer()
                            }
                            .padding(.top, 8)
                        }

                        Text(category.title)
                            .font(.custom("Georgia", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(darkTextColor)
                            .padding(.top, 8)

                        VStack(spacing: 18) {
                            ZStack {
                                Circle()
                                    .fill(category.tint.opacity(0.18))
                                    .frame(width: 110, height: 110)
                                Image(systemName: category.icon)
                                    .font(.system(size: 44, weight: .semibold))
                                    .foregroundColor(category.tint == Color.yellow ? .orange : category.tint)
                            }

                            Text("This exercise is being crafted by the team.")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(darkTextColor)
                                .multilineTextAlignment(.center)

                            Text(category.description)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)

                            Text("Check back soon!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 6)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 100) 
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ExercisesView()
}
