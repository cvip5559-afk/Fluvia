//
//  GoalCompleteView.swift
//  Fluvia
//
//  Created by Wateen on 21/02/1448 AH.
//

import SwiftUI

struct GoalCompleteView: View {
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.96, blue: 0.91)
                .ignoresSafeArea()

            // Confetti pieces scattered around
            ConfettiView()

            VStack {
                Spacer()

                // Reward card
                VStack(spacing: 16) {

                    // Gift icon circle
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.25))
                            .frame(width: 90, height: 90)

                        Circle()
                            .fill(Color(red: 0.95, green: 0.75, blue: 0.2))
                            .frame(width: 64, height: 64)

                        Image(systemName: "gift.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 32)

                    // Title
                    Text("Goal Complete !")
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.15))

                    // Subtitle
                    Text("Keep it up, consistency builds fluency")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    // Points badge
                    Text("+100 points")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.15))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.93, green: 0.91, blue: 0.87))
                        .cornerRadius(20)
                        .padding(.top, 4)

                    // Claim Reward button
                    Button(action: {}) {
                        Text("Claim Reward")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(Color(red: 0.45, green: 0.55, blue: 0.35))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 8)
                .padding(.horizontal, 20)

                Spacer()
                Spacer()
            }
        }
    }
}

// Confetti piece
struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let color: Color
    let rotation: Double
    let size: CGFloat
    let duration: Double
    let delay: Double
}

// Scattered confetti background with continuous falling animation
struct ConfettiView: View {

    let pieces: [ConfettiPiece] = [
        ConfettiPiece(x: 0.08, color: .yellow, rotation: -20, size: 10, duration: 3.2, delay: 0.0),
        ConfettiPiece(x: 0.20, color: Color.brown, rotation: 25, size: 9, duration: 4.0, delay: 0.6),
        ConfettiPiece(x: 0.32, color: Color(red: 0.8, green: 0.7, blue: 0.5), rotation: 10, size: 8, duration: 3.6, delay: 1.1),
        ConfettiPiece(x: 0.45, color: .purple.opacity(0.6), rotation: -15, size: 9, duration: 4.4, delay: 0.3),
        ConfettiPiece(x: 0.58, color: .yellow, rotation: 30, size: 9, duration: 3.0, delay: 1.4),
        ConfettiPiece(x: 0.70, color: .purple.opacity(0.5), rotation: -10, size: 9, duration: 3.8, delay: 0.8),
        ConfettiPiece(x: 0.83, color: .green.opacity(0.6), rotation: 15, size: 8, duration: 3.4, delay: 0.2),
        ConfettiPiece(x: 0.92, color: Color(red: 0.8, green: 0.7, blue: 0.5), rotation: -25, size: 8, duration: 4.2, delay: 1.7)
    ]

    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 1.6)
                        .rotationEffect(.degrees(animate ? piece.rotation + 720 : piece.rotation))
                        .position(
                            x: geo.size.width * piece.x,
                            y: animate ? geo.size.height + 40 : -40
                        )
                        .animation(
                            Animation.linear(duration: piece.duration)
                                .repeatForever(autoreverses: false)
                                .delay(piece.delay),
                            value: animate
                        )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    GoalCompleteView()
}
