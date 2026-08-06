//
//  PositiveJournalView.swift
//  Fluvia
//
//  Created by Sara Alzannan on 20/02/1448 AH.
//

import SwiftUI
import Combine

// MARK: - Model

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
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Persistence Store

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
        entries.insert(entry, at: 0) // newest on top
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

// MARK: - Main View

struct PositiveJournalView: View {
    @StateObject private var store = JournalStore()
    @State private var draftText: String = ""
    private let characterLimit = 50

    // Rotating icon colors/symbols for entries (purely cosmetic)
    private let iconStyles: [(String, Color)] = [
        ("star.fill", Color.teal),
        ("face.smiling.fill", Color.orange),
        ("heart.fill", Color.purple)
    ]

    var body: some View {
        ZStack {
            Color(red: 0.47, green: 0.55, blue: 0.35)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        header
                        entryCard
                        saveButton

                        if !store.entries.isEmpty {
                            notesSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100) // room above tab bar
                }
            }

            VStack {
                Spacer()
                bottomTabBar
            }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 13) {
            Text("Positive Journal")
                .font(.custom("Georgia-Bold", size :24))
                .foregroundColor(.white)

            Image(systemName: "sun.max.fill") .foregroundColor(.yellow).font(.system(size: 50))

            Text("Celebrate progress, and build confidence")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: Text Entry Card

    private var entryCard: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ZStack(alignment: .topLeading) {
                if draftText.isEmpty {
                    Text("Write your positive reflection...")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }
                TextEditor(text: $draftText)
                    .frame(minHeight: 180)
                    .padding(6)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .onChange(of: draftText) {
                        if draftText.count > characterLimit {
                            draftText = String(draftText.prefix(characterLimit))
                        
                        }
                    }
            }
            Text("\(draftText.count)/\(characterLimit)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.trailing, 12)
                .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: Save Button

    private var saveButton: some View {
        Button(action: saveEntry) {
            HStack {
                Image(systemName: "pencil")
                Text("Save Entry")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(red: 0.98, green: 0.75, blue: 0.09))
            .cornerRadius(16)
        }
        .disabled(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
    }

    private func saveEntry() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addEntry(trimmed)
        draftText = ""
        // Optional: dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: Notes List

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Positive notes")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(Array(store.entries.enumerated()), id: \.element.id) { index, entry in
                noteRow(entry: entry, styleIndex: index % iconStyles.count)
            }
        }
    }

    private func noteRow(entry: JournalEntry, styleIndex: Int) -> some View {
        let (symbol, color) = iconStyles[styleIndex]
        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: symbol)
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.text)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                Text(entry.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: Bottom Tab Bar

    private var bottomTabBar: some View {
        HStack {
            tabItem(icon: "mic.fill", label: "Assess", active: false)
            tabItem(icon: "person.wave.2.fill", label: "Exercises", active: false)
            tabItem(icon: "chart.bar.fill", label: "Progress", active: false)
            tabItem(icon: "pencil.and.list.clipboard", label: "Journal", active: true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color(red: 0.98, green: 0.75, blue: 0.09), lineWidth: 2))
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    private func tabItem(icon: String, label: String, active: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                if active {
                    Circle()
                        .fill(Color(red: 0.98, green: 0.75, blue: 0.09))
                        .frame(width: 36, height: 36)
                }
                Image(systemName: icon)
                    .foregroundColor(active ? .white : .black)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

struct PositiveJournalView_Previews: PreviewProvider {
    static var previews: some View {
        PositiveJournalView()
    }
}
