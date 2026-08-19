//
//  JournalListView.swift
//  FluviaApp
//
//  Created by Sara Alzannan on 29/02/1448 AH.
//


import SwiftUI

struct JournalListView: View {
    let theme: FluviaTheme
    @ObservedObject var store: JournalStore
    var onBack: () -> Void = {}

    @State private var editingEntry: JournalEntry? = nil
    @State private var editText: String = ""
    @State private var entryPendingDelete: JournalEntry? = nil

    private let deleteColor = Color(red: 0.75, green: 0.35, blue: 0.30)

    private let cardColors: [(FluviaTheme) -> Color] = [
        { $0.cardPurple }, { $0.cardMorning }, { $0.cardPink }, { $0.cardEvening }
    ]

    private var sortedEntries: [JournalEntry] {
        store.entries.sorted { $0.date > $1.date }
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if sortedEntries.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                                journalRow(entry: entry, color: cardColors[index % cardColors.count](theme))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                        .padding(.bottom, 40)
                    }
                }
            }

            if let entry = editingEntry {
                ComposeNoteOverlay(
                    theme: theme,
                    title: "Edit Note",
                    text: $editText,
                    onCancel: { editingEntry = nil },
                    onSave: {
                        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        store.updateEntry(entry, newText: trimmed)
                        editingEntry = nil
                    }
                )
                .zIndex(1)
            }
        }
        .alert(
            "Delete this note?",
            isPresented: Binding(
                get: { entryPendingDelete != nil },
                set: { if !$0 { entryPendingDelete = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { entryPendingDelete = nil }
            Button("Delete", role: .destructive) {
                if let entry = entryPendingDelete {
                    store.deleteEntry(entry)
                }
                entryPendingDelete = nil
            }
        } message: {
            Text("This can't be undone.")
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            HStack {
                BackButton(action: onBack, textColor: theme.textDark)
                Spacer()
            }
            .padding(.bottom, 4)

            Text("My Journal")
                .font(.custom("Georgia", size: 30))
                .fontWeight(.bold)
                .foregroundColor(theme.textDark)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "book.closed")
                .font(.system(size: 34))
                .foregroundColor(theme.textDark.opacity(0.3))
            Text("No journal entries yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(theme.textDark.opacity(0.5))
            Spacer()
        }
    }

    private func journalRow(entry: JournalEntry, color: Color) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.text)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.textDark)
                    .fixedSize(horizontal: false, vertical: true)

                Text(entry.formattedDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.textDark.opacity(0.5))
            }

            Spacer(minLength: 8)

            HStack(spacing: 14) {
                Button(action: {
                    editText = entry.text
                    editingEntry = entry
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(theme.accent)
                }

                Button(action: {
                    entryPendingDelete = entry
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(deleteColor)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}

#Preview {
    JournalListView(theme: FluviaTheme(), store: JournalStore())
}
