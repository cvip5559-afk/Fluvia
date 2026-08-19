import Foundation

// MARK: - DailyProgressManager
//


struct DailyActivity: OptionSet {
    let rawValue: Int

    static let voiceAssessment = DailyActivity(rawValue: 1 << 0)
    static let exercise        = DailyActivity(rawValue: 1 << 1)
    static let journal         = DailyActivity(rawValue: 1 << 2)

    static let all: DailyActivity = [.voiceAssessment, .exercise, .journal]
}

enum DailyProgressManager {
    private static let storageKey = "dailyProgressActivities"

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()

    static func dayKey(for date: Date) -> String {
        dayFormatter.string(from: date)
    }

    /// [dayKey: rawValue of completed DailyActivity flags]
    private static var store: [String: Int] {
        get {
            (UserDefaults.standard.dictionary(forKey: storageKey) as? [String: Int]) ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: storageKey)
        }
    }

    private static func activities(for date: Date) -> DailyActivity {
        let raw = store[dayKey(for: date)] ?? 0
        return DailyActivity(rawValue: raw)
    }

    private static func setActivities(_ activities: DailyActivity, for date: Date) {
        var current = store
        current[dayKey(for: date)] = activities.rawValue
        store = current
    }

    private static func markDone(_ activity: DailyActivity, for date: Date) {
        var current = activities(for: date)
        guard !current.contains(activity) else { return }
        current.insert(activity)
        setActivities(current, for: date)
    }

    // MARK: - Public marking API

    static func markVoiceAssessmentDone(for date: Date = Date()) {
        markDone(.voiceAssessment, for: date)
    }

    static func markExerciseDone(for date: Date = Date()) {
        markDone(.exercise, for: date)
    }

    static func markJournalDone(for date: Date = Date()) {
        markDone(.journal, for: date)
    }

    // MARK: - Public reading API

    static func isVoiceAssessmentDone(for date: Date = Date()) -> Bool {
        activities(for: date).contains(.voiceAssessment)
    }

    static func isExerciseDone(for date: Date = Date()) -> Bool {
        activities(for: date).contains(.exercise)
    }

    static func isJournalDone(for date: Date = Date()) -> Bool {
        activities(for: date).contains(.journal)
    }

    /// 0, 0.35, 0.70, or 1.0
    static func progress(for date: Date = Date()) -> Double {
        let done = activities(for: date)
        var total = 0.0
        if done.contains(.voiceAssessment) { total += 0.35 }
        if done.contains(.exercise) { total += 0.35 }
        if done.contains(.journal) { total += 0.30 }
        return total
    }

    static func isDayComplete(for date: Date = Date()) -> Bool {
        activities(for: date) == .all
    }

    /// Total number of days (ever) where all 3 activities were completed.
    /// Used to drive the simple "Level" badge on the Progress Card.
    static func totalCompletedDays() -> Int {
        store.values.filter { DailyActivity(rawValue: $0) == .all }.count
    }

    /// Wipes all daily-activity tracking. Pair with StreakManager.resetAll()
    /// for a full, clean reset of everything progress-related.
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
