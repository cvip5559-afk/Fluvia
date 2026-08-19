import Foundation

// MARK: - StreakManager

enum StreakDayStatus {
    case completed
    case missed
    case today
    case future
}

struct StreakDay: Identifiable {
    let id = UUID()
    let date: Date
    let status: StreakDayStatus
}

struct StreakWeek: Identifiable {
    let id: Int
    let days: [StreakDay]

    var isFullyCompleted: Bool {
        days.allSatisfy { $0.status == .completed }
    }

    var completedCount: Int {
        days.filter { $0.status == .completed }.count
    }
}

enum StreakManager {
    private static let completedDatesKey = "streakCompletedDates"
    private static let startDateKey = "streakStartDate"

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()

    static func dayKey(for date: Date) -> String {
        dayFormatter.string(from: date)
    }

    
    static var completedDates: Set<String> {
        get {
            let raw = UserDefaults.standard.string(forKey: completedDatesKey) ?? ""
            guard !raw.isEmpty else { return [] }
            return Set(raw.split(separator: ",").map(String.init))
        }
        set {
            UserDefaults.standard.set(newValue.sorted().joined(separator: ","), forKey: completedDatesKey)
        }
    }

    
   
    static var startDate: Date {
        let calendar = Calendar.current
        if let stored = UserDefaults.standard.object(forKey: startDateKey) as? Date {
            return calendar.startOfDay(for: stored)
        }
        let today = calendar.startOfDay(for: Date())
        UserDefaults.standard.set(today, forKey: startDateKey)
        return today
    }

    static var isTodayCompleted: Bool {
        completedDates.contains(dayKey(for: Date()))
    }

   
    static func markTodayComplete() {
        _ = startDate // make sure a start date exists
        var dates = completedDates
        dates.insert(dayKey(for: Date()))
        completedDates = dates
    }

    
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: completedDatesKey)
        UserDefaults.standard.removeObject(forKey: startDateKey)
    }

    // MARK: - Sunday-aligned week math
    

    private static func startOfWeek(containing date: Date, calendar: Calendar) -> Date {
        let day = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: day)
        return calendar.date(byAdding: .day, value: -(weekday - 1), to: day) ?? day
    }

    
    static func weeks(minimumCount: Int = 1) -> [StreakWeek] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let completed = completedDates

        let firstWeekStart = startOfWeek(containing: startDate, calendar: calendar)
        let currentWeekStart = startOfWeek(containing: today, calendar: calendar)
        let weeksElapsed = calendar.dateComponents([.weekOfYear], from: firstWeekStart, to: currentWeekStart).weekOfYear ?? 0
        let weekCount = max(minimumCount, weeksElapsed + 1)

        var result: [StreakWeek] = []
        for w in 0..<weekCount {
            guard let weekStart = calendar.date(byAdding: .day, value: w * 7, to: firstWeekStart) else { continue }
            var days: [StreakDay] = []
            for d in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: d, to: weekStart) else { continue }
                let key = dayKey(for: date)
                let status: StreakDayStatus

                if date > today {
                    status = .future
                } else if calendar.isDate(date, inSameDayAs: today) {
                    status = completed.contains(key) ? .completed : .today
                } else {
                    status = completed.contains(key) ? .completed : .missed
                }
                days.append(StreakDay(date: date, status: status))
            }
            result.append(StreakWeek(id: w, days: days))
        }
        return result
    }


    static func currentWeek() -> StreakWeek {
        weeks(minimumCount: 1).last!
    }


    static var currentWeekNumber: Int {
        weeks(minimumCount: 1).count
    }
}
