//
//  JournalStore.swift
//  FluviaFinal1
//
//  Created by Aleen Aldosari on 28/02/1448 AH.

import Foundation
import Combine

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var text: String
    var date: Date

    init(text: String, date: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.date = date
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

class JournalStore: ObservableObject {
    @Published var entries: [JournalEntry] = [] {
        didSet { save() }
    }

    private let key = "positive_journal_entries"

    init() {
        load()
    }

    func addEntry(_ text: String) {
        let entry = JournalEntry(text: text)
        entries.insert(entry, at: 0) // newest first
        DailyProgressManager.markJournalDone(for: entry.date)
    }

    func updateEntry(_ entry: JournalEntry, newText: String) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index].text = newText
    }

    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
}
