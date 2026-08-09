//
//  TabBarView.swift
//  MergeFluvia
//
//  Created by Aleen Aldosari on 23/02/1448 AH.
//

import SwiftUI

// MARK: - App Tab
//
// Identifies every tab in the app. To add a NEW tab/page later, add a
// case here, add its icon/label in TabBarView below, and add its
// screen to the switch in RootView.swift. That's it — no other file
// needs to change.

enum AppTab: CaseIterable {
    case assess, exercises, progress, journal
}

// MARK: - Shared Tab Bar
//
// ONE tab bar, used everywhere via RootView.swift. It doesn't know
// how navigation works — it just reports which tab was tapped.

struct TabBarView: View {
    var activeTab: AppTab
    var onSelect: (AppTab) -> Void

    var body: some View {
        HStack {
            tab(.assess, icon: "mic.fill", label: "Assess")
            tab(.exercises, icon: "person.wave.2", label: "Exercises")
            tab(.progress, icon: "chart.bar.fill", label: "Progress")
            tab(.journal, icon: "square.and.pencil", label: "Journal")
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

    private func tab(_ tabCase: AppTab, icon: String, label: String) -> some View {
        Button {
            onSelect(tabCase)
        } label: {
            TabItem(icon: icon, label: label, isActive: activeTab == tabCase)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab Item

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
    VStack {
        Spacer()
        TabBarView(activeTab: .exercises, onSelect: { _ in })
    }
    .background(Color(red: 0.98, green: 0.96, blue: 0.91).ignoresSafeArea())
}
