//
//  LaunchView.swift
//  fluvia


import SwiftUI

struct LaunchView: View {
    @State private var showWelcome = true

    var body: some View {
        if showWelcome {
            WelcomeView(onGetStarted: {
                showWelcome = false
            })
        } else {
            HomeView()
        }
    }
}

#Preview {
    LaunchView()
}
