//
//  progress.swift
//  fluvia
//
//  Created by Aleen Aldosari on 20/02/1448 AH.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {

    // MARK: Persisted (real) streak progress
    // This is the user's actual saved streak and is NEVER touched by the
    // intro preview animation.
    @AppStorage("streakSavedDays") private var savedDays: Int = 0

    // MARK: Temporary state used ONLY to drive what's on screen.
    // During the intro preview this is animated 0 -> 7 -> 0, then it is
    // set to the real `savedDays` value and left alone.
    @State private var displayedDays: Int = 0
    @State private var ringProgress: CGFloat = 0
    @State private var giftHighlighted: Bool = false
    @State private var didRunIntro: Bool = false

    private let totalDays = 7
    private let dayLabels = ["Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"]

    // MARK: Palette (unified with the rest of the app)
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 34) {
                        titleSection
                        progressRing
                        dayStreakCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                }

                TabBarView()
            }
        }
        .onAppear {
            guard !didRunIntro else { return }
            didRunIntro = true
            Task { await runIntroAnimation() }
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("Your Progress")
            .font(.custom("Georgia", size: 32))
            .fontWeight(.bold)
            .foregroundColor(darkTextColor)
            .padding(.top, 8)
    }

    // MARK: - Circular Progress Ring

    private var ringColor: Color {
        giftHighlighted ? goldColor : greenColor
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 14)

            Circle()
                // small visible cap even at 0%, matching the reference image
                .trim(from: 0, to: max(ringProgress, 0.015))
                .stroke(ringColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int((ringProgress * 100).rounded()))")
                        .font(.custom("Georgia", size: 52))
                        .fontWeight(.bold)
                    Text("%")
                        .font(.custom("Georgia", size: 30))
                        .fontWeight(.bold)
                }
                .foregroundColor(darkTextColor)

                Text("Level 1")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 260, height: 260)
        .padding(.top, 6)
    }

    // MARK: - Day Streak Card

    private var dayStreakCard: some View {
        VStack(alignment: .leading, spacing: 26) {

            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(darkTextColor)

                Text("Day Streak")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(darkTextColor)
            }

            HStack(spacing: 0) {
                ForEach(0..<totalDays, id: \.self) { i in
                    dayColumn(index: i)

                    if i < totalDays - 1 {
                        connectorLine(isCompleted: i < displayedDays)
                    }
                }
            }

            Text("Amazing streak! keep going everyday champ")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 6)
        )
    }

    /// One day = circle + label underneath, kept as a single fixed-width
    /// unit so the connecting line can flex to fill the remaining space.
    private func dayColumn(index: Int) -> some View {
        VStack(spacing: 8) {
            dayCircle(index: index)

            Text(dayLabels[index])
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(darkTextColor.opacity(0.75))
                .fixedSize()
        }
    }

    /// The green connector between two day-circles, styled like Apple's
    /// thin, rounded-cap progress/step indicators.
    private func connectorLine(isCompleted: Bool) -> some View {
        Capsule()
            .fill(isCompleted ? greenColor : Color.gray.opacity(0.18))
            .frame(maxWidth: .infinity)
            .frame(height: 3)
            .offset(y: -13) // aligns with the vertical center of the circles above
    }

    private func dayCircle(index: Int) -> some View {
        let isSunday = index == totalDays - 1
        let isCompleted = index < displayedDays

        return Group {
            if isSunday {
                ZStack {
                    Circle()
                        .fill((isCompleted || giftHighlighted) ? goldColor : Color.gray.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "gift.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor((isCompleted || giftHighlighted) ? .white : .gray.opacity(0.5))
                }
            } else {
                ZStack {
                    Circle()
                        .fill(isCompleted ? greenColor : Color.gray.opacity(0.15))
                        .frame(width: 44, height: 44)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    // MARK: - Intro Preview Animation
    //
    // Runs once when the page first appears: quickly animates the streak
    // from Monday through Sunday (ring 0% -> 100%, gift lights up gold),
    // pauses briefly, animates back down to 0%, then hands control over
    // to the user's real saved progress (`savedDays`). The saved value
    // itself is never modified by this animation.

    private func runIntroAnimation() async {
        // Animate forward, day by day.
        for day in 1...totalDays {
            withAnimation(.easeInOut(duration: 0.28)) {
                displayedDays = day
                ringProgress = CGFloat(day) / CGFloat(totalDays)
                if day == totalDays {
                    giftHighlighted = true
                }
            }
            try? await Task.sleep(nanoseconds: 280_000_000)
        }

        // Hold briefly at the completed state.
        try? await Task.sleep(nanoseconds: 700_000_000)

        // Animate back down to 0%.
        withAnimation(.easeInOut(duration: 0.6)) {
            displayedDays = 0
            ringProgress = 0
            giftHighlighted = false
        }
        try? await Task.sleep(nanoseconds: 650_000_000)

        // Reveal the user's real, saved progress.
        withAnimation(.easeInOut(duration: 0.4)) {
            displayedDays = savedDays
            ringProgress = CGFloat(savedDays) / CGFloat(totalDays)
            giftHighlighted = savedDays == totalDays
        }
    }
}

// MARK: - Shared Tab Bar (unified across pages)

struct TabBarView: View {
    var body: some View {
        HStack {
            TabItem(icon: "mic.fill", label: "Assess", isActive: false)
            TabItem(icon: "person.wave.2", label: "Exercises", isActive: false)
            TabItem(icon: "chart.bar.fill", label: "Progress", isActive: true)
            TabItem(icon: "square.and.pencil", label: "Journal", isActive: false)
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

struct TabItem: View {
    let icon: String
    let label: String
    let isActive: Bool

    var body: some View {
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

// MARK: - Preview

#Preview {
    ContentView()
}
