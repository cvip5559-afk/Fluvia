//
//  HomeView.swift
//  fluvia


import SwiftUI

// MARK: - Theme (Gold)

struct FluviaTheme {
    let background = Color(red: 0.98, green: 0.96, blue: 0.91)
    let textDark = Color(red: 0.35, green: 0.25, blue: 0.15)
    let accent = Color.fluviaHex("E6A816")
    let accentTrack = Color.fluviaHex("E6A816").opacity(0.22)
    let cardMorning = Color.fluviaHex("F2E5A8")
    let cardEvening = Color.fluviaHex("9DB380")
    let cardPurple = Color.fluviaHex("E3D9F5")
    let cardPink = Color.fluviaHex("F6D9DE")
    let success = Color(red: 0.45, green: 0.55, blue: 0.35)
    let missed = Color.gray.opacity(0.2)
}

extension Color {
    static func fluviaHex(_ hex: String) -> Color {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        return Color(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

// MARK: - Models

enum DayState {
    case completed
    case missed
    case today
    case future
}

struct DayItem: Identifiable {
    let id = UUID()
    let name: String
    let date: Int
    let state: DayState
}

// MARK: - Header

struct HeaderView: View {
    let theme: FluviaTheme
    var body: some View {
        HStack {
            Text("Hello!")
                .font(.custom("Georgia", size: 32))
                .fontWeight(.bold)
                .foregroundColor(theme.textDark)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Weekly Calendar Strip

struct WeeklyCalendarStrip: View {
    let theme: FluviaTheme
    let days: [DayItem]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(days) { day in
                    VStack(spacing: 6) {
                        Text(day.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.textDark)
                        ZStack {
                            Circle()
                                .fill(fillColor(for: day.state))
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)

                            if day.state == .completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            } else if day.state == .today {
                                Text("\(day.date)")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                            } else if day.state == .missed {
                                // Gray, no checkmark or number — a passed,
                                // incomplete day. Not treated as an error.
                                EmptyView()
                            } else {
                                Text("\(day.date)")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary.opacity(0.6))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func fillColor(for state: DayState) -> Color {
        switch state {
        case .completed: return theme.success
        case .missed: return theme.missed
        case .today: return theme.accent
        case .future: return Color.white
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let theme: FluviaTheme
    var seeAllAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(theme.textDark)
            Spacer()
            if let seeAllAction {
                Button(action: seeAllAction) {
                    Text("See all")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(theme.accent)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Today Progress Card


struct ProgressChecklistRow: View {
    let theme: FluviaTheme
    let title: String
    let cumulativeTarget: Int
    let isDone: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isDone ? theme.success : Color.white)
                    .frame(width: 22, height: 22)
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isDone ? theme.success : theme.textDark.opacity(0.25), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.textDark)
                Text("\(cumulativeTarget)%")
                    .font(.system(size: 11))
                    .foregroundColor(theme.textDark.opacity(0.45))
            }

            Spacer()
        }
    }
}

struct TodayProgressCard: View {
    let theme: FluviaTheme
    let level: Int
    let progress: Double
    let voiceDone: Bool
    let exerciseDone: Bool
    let journalDone: Bool
    var onSeeAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Your Progress")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(theme.textDark)
                Spacer()
                
            }
            .padding(.horizontal, 20)

            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    ProgressChecklistRow(theme: theme, title: "Voice Assessment", cumulativeTarget: 35, isDone: voiceDone)
                    ProgressChecklistRow(theme: theme, title: "Exercise", cumulativeTarget: 70, isDone: exerciseDone)
                    ProgressChecklistRow(theme: theme, title: "Journal", cumulativeTarget: 100, isDone: journalDone)
                }

                ZStack {
                    Circle()
                        .stroke(theme.accentTrack, lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: max(progress, 0.015))
                        .stroke(theme.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)

                    Text("\(Int((progress * 100).rounded()))%")
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(theme.textDark)
                }
                .frame(width: 108, height: 108)
            }
            .padding(.horizontal, 20)

            Button(action: onSeeAll) {
                HStack {
                    Spacer()
                    Text("See full progress")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(theme.accent)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 18)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        .padding(.horizontal, 20)
    }
}

// MARK: - Feature Cards

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let background: AnyShapeStyle
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(Color.white.opacity(0.28))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.white)
                }
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .leading)
            .background(background)
            .cornerRadius(22)
        }
        .buttonStyle(.plain)
    }
}

struct FeatureCardsRow: View {
    let theme: FluviaTheme
    var onAssessTap: () -> Void
    var onExercisesTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            FeatureCard(
                icon: "mic",
                title: "Voice Assessment",
                subtitle: "Check your fluency today",
                background: AnyShapeStyle(
                    LinearGradient(colors: [theme.accent, theme.cardMorning],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                ),
                action: onAssessTap
            )
            FeatureCard(
                icon: "checklist",
                title: "Exercises",
                subtitle: "Practice a few minutes",
                background: AnyShapeStyle(theme.cardEvening),
                action: onExercisesTap
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - My Journal Section

struct AddJournalCard: View {
    let theme: FluviaTheme
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(theme.textDark.opacity(0.6))
                .frame(width: 110, height: 130)
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct JournalNoteCard: View {
    let text: String
    let date: String
    let color: Color
    let theme: FluviaTheme

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Text(text)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.textDark)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            Text(date)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(theme.textDark.opacity(0.55))
        }
        .padding(14)
        .frame(width: 110, height: 130)
        .background(color)
        .cornerRadius(18)
    }
}

struct MyJournalSection: View {
    let theme: FluviaTheme
    let entries: [JournalEntry]
    var onAddTap: () -> Void
    var onSeeAll: () -> Void

    private let cardColors: [(FluviaTheme) -> Color] = [
        { $0.cardPurple }, { $0.cardMorning }, { $0.cardPink }, { $0.cardEvening }
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Positive Journal", theme: theme, seeAllAction: onSeeAll)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    AddJournalCard(theme: theme, action: onAddTap)

                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        JournalNoteCard(
                            text: entry.text,
                            date: entry.formattedDate,
                            color: cardColors[index % cardColors.count](theme),
                            theme: theme
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Compose Note Overlay

struct ComposeNoteOverlay: View {
    let theme: FluviaTheme
    var title: String = "New Positive Note"
    @Binding var text: String
    var onCancel: () -> Void
    var onSave: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(theme.textDark)

                TextField("Write something positive...", text: $text, axis: .vertical)
                    .focused($isFocused)
                    .lineLimit(3...6)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }

                    Button(action: onSave) {
                        Text("Save")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(theme.accent)
                            .cornerRadius(14)
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(theme.background)
            )
            .padding(.horizontal, 30)
        }
        .onAppear { isFocused = true }
    }
}

// MARK: - Home View

struct HomeView: View {
    let theme = FluviaTheme()

    @StateObject private var journalStore = JournalStore()

    @State private var days: [DayItem] = []
    @State private var todayProgress: Double = 0
    @State private var voiceDone = false
    @State private var exerciseDone = false
    @State private var journalDone = false
    @State private var level: Int = 1

    @State private var showAssess = false
    @State private var showExercises = false
    @State private var showProgressPage = false
    @State private var showJournalList = false
    @State private var pendingExerciseTitle: String? = nil

    @State private var showCompose = false
    @State private var draftNoteText = ""

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    HeaderView(theme: theme)
                    WeeklyCalendarStrip(theme: theme, days: days)

                    TodayProgressCard(
                        theme: theme,
                        level: level,
                        progress: todayProgress,
                        voiceDone: voiceDone,
                        exerciseDone: exerciseDone,
                        journalDone: journalDone,
                        onSeeAll: { showProgressPage = true }
                    )

                    FeatureCardsRow(
                        theme: theme,
                        onAssessTap: { showAssess = true },
                        onExercisesTap: { showExercises = true }
                    )

                    MyJournalSection(
                        theme: theme,
                        entries: journalStore.entries,
                        onAddTap: {
                            draftNoteText = ""
                            showCompose = true
                        },
                        onSeeAll: { showJournalList = true }
                    )

                    Spacer(minLength: 30)
                }
                .padding(.top, 10)
            }

            if showAssess {
                AssessView(
                    onBack: {
                        showAssess = false
                        reloadHome()
                    },
                    onStartExercise: { title in
                        pendingExerciseTitle = title
                        showAssess = false
                        showExercises = true
                    },
                    onGoHome: goHome
                )
                .zIndex(1)
            }

            if showExercises {
                ExercisesView(
                    autoOpenCategoryTitle: pendingExerciseTitle,
                    onBack: {
                        showExercises = false
                        pendingExerciseTitle = nil
                        reloadHome()
                    },
                    onGoHome: goHome
                )
                .zIndex(1)
            }

            if showProgressPage {
                progressView(onBack: { showProgressPage = false })
                    .zIndex(1)
            }

            if showJournalList {
                JournalListView(
                    theme: theme,
                    store: journalStore,
                    onBack: { showJournalList = false }
                )
                .zIndex(1)
            }

            if showCompose {
                ComposeNoteOverlay(
                    theme: theme,
                    text: $draftNoteText,
                    onCancel: { showCompose = false },
                    onSave: {
                        let trimmed = draftNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        journalStore.addEntry(trimmed)
                        showCompose = false
                        reloadHome()
                    }
                )
                .zIndex(2)
            }
        }
        .onAppear {
            performOneTimeSundayMigrationResetIfNeeded()
            reloadHome()
        }
    }

    // MARK: - Real data
    private func goHome() {
        showAssess = false
        showExercises = false
        pendingExerciseTitle = nil
        reloadHome()
    }

    private func reloadHome() {
        let today = Date()
        voiceDone = DailyProgressManager.isVoiceAssessmentDone(for: today)
        exerciseDone = DailyProgressManager.isExerciseDone(for: today)
        journalDone = DailyProgressManager.isJournalDone(for: today)
        level = 1 + (DailyProgressManager.totalCompletedDays() / 7)

        withAnimation(.easeInOut(duration: 0.5)) {
            todayProgress = DailyProgressManager.progress(for: today)
        }

        reloadWeek()
    }

    private func performOneTimeSundayMigrationResetIfNeeded() {
        let migrationKey = "didMigrateToSundayAlignedWeeks_v1"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }
        StreakManager.resetAll()
        DailyProgressManager.resetAll()
        UserDefaults.standard.set(true, forKey: migrationKey)
    }

    private func reloadWeek() {
        let week = StreakManager.currentWeek()
        let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let calendar = Calendar.current

        var result: [DayItem] = []
        for (index, streakDay) in week.days.enumerated() {
            let dayNumber = calendar.component(.day, from: streakDay.date)

            let state: DayState
            switch streakDay.status {
            case .completed: state = .completed
            case .missed:    state = .missed
            case .today:     state = .today
            case .future:    state = .future
            }

            result.append(DayItem(name: dayLabels[index], date: dayNumber, state: state))
        }
        days = result
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
