import SwiftUI

// MARK: - progressView
//
// StreakDayStatus / StreakDay / StreakWeek now live in
// StreakManager.swift (single source of truth for week math). This
// view just asks StreakManager for the data instead of recomputing
// it — which is also the fix for it disagreeing with HomeView.

struct progressView: View {

    var onBack: (() -> Void)? = nil

    // MARK: Temporary state used ONLY to drive the ring animation on open.
    @State private var ringProgress: CGFloat = 0
    @State private var weeks: [StreakWeek] = []

    private let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private let weekMotivations = [
        "Every journey starts with a single step, you've got this.",
        "Consistency builds confidence. Keep the momentum going.",
        "You're not the same speaker you were a few weeks ago.",
        "This is becoming a habit now, trust the process."
    ]

    private func motivation(forWeek index: Int) -> String {
        weekMotivations[index % weekMotivations.count]
    }

    // MARK: Palette
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow
    private let missedColor     = Color(red: 0.75, green: 0.35, blue: 0.30)

    
    private var currentWeekNumber: Int {
        StreakManager.currentWeekNumber
    }

    private var currentWeekRatio: CGFloat {
        let week = StreakManager.currentWeek()
        return CGFloat(week.completedCount) / 7.0
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 34) {
                        titleSection
                        progressRing
                        weeksSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 100)                 }
            }
        }
        .onAppear {
            reloadWeeks()
            withAnimation(.easeInOut(duration: 0.6)) {
                ringProgress = currentWeekRatio
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

            Text("Your Progress")
                .font(.custom("Georgia", size: 30))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)
Spacer()
            Text("Week \(currentWeekNumber)")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary.opacity(0.5))
        }
        .padding(.top, 8)
    }

    // MARK: - Circular Progress Ring

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 14)

            Circle()
                .trim(from: 0, to: max(ringProgress, 0.015))
                .stroke(greenColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int((ringProgress * 100).rounded()))")
                        .font(.custom("Georgia", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(Color.fluviaHex("4A3728"))
                    Text("%")
                        .font(.system(size: 30, weight: .bold, design: .default))
                }
                .foregroundColor(darkTextColor)

                Text("This Week")
                    .font(.system(size: 18))
                    .foregroundColor(.primary.opacity(0.6))
                    .fontWeight(.medium)
            }
        }
        .frame(width: 260, height: 260)
        .padding(.top, 6)
    }

    // MARK: - Weekly History (stacked, oldest week on top)

    private var weeksSection: some View {
        VStack(spacing: 20) {
            ForEach(weeks) { week in
                weekCard(week)
            }
        }
    }

    private func weekCard(_ week: StreakWeek) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(darkTextColor)

                Text("Week \(week.id + 1)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(darkTextColor)

                if week.isFullyCompleted {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 16))
                        .foregroundColor(goldColor)
                }

                Spacer()
            }

            HStack(spacing: 2) {
                ForEach(Array(week.days.enumerated()), id: \.offset) { index, day in
                    dayColumn(day: day, label: dayLabels[index])

                    if index < week.days.count - 1 {
                        connectorLine(isCompleted: day.status == .completed)
                    }
                }
            }

            Text(motivation(forWeek: week.id))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 6)
        )
    }

    private func dayColumn(day: StreakDay, label: String) -> some View {
        VStack(spacing: 8) {
            dayCircle(status: day.status)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(darkTextColor.opacity(0.75))
                .fixedSize()
        }
    }

    private func connectorLine(isCompleted: Bool) -> some View {
        Capsule()
            .fill(isCompleted ? greenColor : Color.gray.opacity(0.18))
            .frame(maxWidth: .infinity)
            .frame(height: 3)
            .offset(y: -13)
    }

    private func dayCircle(status: StreakDayStatus) -> some View {
        ZStack {
            switch status {
            case .completed:
                Circle()
                    .fill(greenColor)
                    .frame(width: 44, height: 44)
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

            case .missed:
                Circle()
                    .fill(missedColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(missedColor)

            case .today:
                Circle()
                    .fill(goldColor.opacity(0.18))
                    .frame(width: 44, height: 44)
                Circle()
                    .stroke(goldColor, lineWidth: 2.5)
                    .frame(width: 44, height: 44)

            case .future:
                Circle()
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 44, height: 44)
            }
        }
    }

    // MARK: - Data

    private func reloadWeeks() {
        weeks = StreakManager.weeks(minimumCount: 4)
    }
}

// MARK: - Preview

#Preview {
    progressView()
}
