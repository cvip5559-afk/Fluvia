//
//  page4.swift
//  fluvia2
//
//  Created by Jinan Mahdi Alanazi on 22/02/1448 AH.
//
//
//  ContentView.swift
//  fluvia5
//
//  Created by Jinan Mahdi Alanazi on 21/02/1448 AH.
//
import SwiftUI

struct EasyStartExerciseView: View {
    // حالة الأقسام المتحركة (Pulsing / Breathing Effect)
    @State private var isPulsing: Bool = false
    
    var body: some View {
        ZStack {
            // 1. Background Color
            Color(red: 0.98, green: 0.96, blue: 0.91)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        // Action for back button
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    // Title in Georgia font
                    Text("Easy Start")
                        .font(.custom("Georgia-Bold", size: 20))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Hidden view for balancing navigation title center
                    Image(systemName: "chevron.left")
                        .opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Main Practice Section
                        VStack(spacing: 20) {
                            
                            // Animated Circles
                            ZStack {
                                // Outer Pulse Circle
                                Circle()
                                    .fill(Color.orange.opacity(0.25))
                                    .frame(width: 230, height: 230)
                                    .scaleEffect(isPulsing ? 1.08 : 0.95)
                                
                                // Middle Circle
                                Circle()
                                    .fill(Color.orange.opacity(0.45))
                                    .frame(width: 180, height: 180)
                                    .scaleEffect(isPulsing ? 1.04 : 0.98)
                                
                                // Inner Circle
                                Circle()
                                    .fill(Color(red: 0.98, green: 0.91, blue: 0.72))
                                    .frame(width: 130, height: 130)
                                
                                // Center Text
                                Text("The calm river..")
                                    .font(.custom("Georgia", size: 18))
                                    .foregroundColor(Color.green.opacity(0.8))
                            }
                            .frame(height: 240)
                            .padding(.top, 20)
                            
                            // Haptic Feedback Indicator (Animated Sound Wave)
                            HStack(spacing: 6) {
                                Image(systemName: "wave.3.left")
                                    .font(.system(size: 22))
                                    .foregroundColor(.orange.opacity(0.6))
                                    .scaleEffect(isPulsing ? 1.1 : 0.9)
                                
                                Image(systemName: "waveform")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.orange)
                                
                                Image(systemName: "wave.3.right")
                                    .font(.system(size: 22))
                                    .foregroundColor(.orange.opacity(0.6))
                                    .scaleEffect(isPulsing ? 1.1 : 0.9)
                            }
                            .padding(.bottom, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        
                        // Instructions Section (System Font)
                        VStack(alignment: .leading, spacing: 16) {
                            EasyStartInstructionRow(
                                number: "[1]",
                                title: "Release Vocal Tension:",
                                description: "Focus on relaxation before you start."
                            )
                            
                            EasyStartInstructionRow(
                                number: "[2]",
                                title: "Gentle Airflow:",
                                description: "Let a tiny whisper of air slip out."
                            )
                            
                            EasyStartInstructionRow(
                                number: "[3]",
                                title: "Speak on the Flow:",
                                description: "Softly glide into the first sound."
                            )
                            
                            EasyStartInstructionRow(
                                number: "[4]",
                                title: "Connect the Phrase:",
                                description: "Keep the words connected smoothly."
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Action Button
                        Button(action: {
                            // Action for Done
                        }) {
                            Text("Done")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.55, green: 0.68, blue: 0.45))
                                .cornerRadius(25)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 10)
                }
                
                // Custom Tab Bar
                EasyStartTabBarView()
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Helper Views

struct EasyStartInstructionRow: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(number)
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.black)
            
            Text(description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .italic()
        }
    }
}

// MARK: - Custom Tab Bar

struct EasyStartTabBarView: View {
    var body: some View {
        HStack {
            EasyStartTabItem(icon: "mic.fill", label: "Assess", isActive: false)
            EasyStartTabItem(icon: "person.wave.2", label: "Exercises", isActive: true)
            EasyStartTabItem(icon: "chart.bar.fill", label: "Progress", isActive: false)
            EasyStartTabItem(icon: "square.and.pencil", label: "Journal", isActive: false)
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
}

struct EasyStartTabItem: View {
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

#Preview {
    EasyStartExerciseView()
}
