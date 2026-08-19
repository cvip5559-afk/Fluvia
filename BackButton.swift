//
//  BackButton.swift
//  fluvia
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void
    var textColor: Color = Color(red: 0.35, green: 0.25, blue: 0.15)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(textColor)
        }
    }
}

#Preview {
    BackButton(action: {})
}
