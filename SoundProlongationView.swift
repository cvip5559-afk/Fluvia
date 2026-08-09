//
//  SoundProlongationView.swift
//  Fluvia
//
//  Created by Wateen on 21/02/1448 AH.
//

import SwiftUI

struct SoundProlongationView: View {

    @State private var showExcellent = false

    let steps: [ExerciseStep] = [
        ExerciseStep(number: "1", title: "Step 1: Read slowly",
                     description: "Pick a word and read it at a very slow, relaxed pace.",
                     color: Color(red: 0.35, green: 0.25, blue: 0.15)),
        ExerciseStep(number: "2", title: "Step 2: Repeat the word",
                     description: "Say the same word a few times, keeping it steady.",
                     color: Color(red: 0.55, green: 0.65, blue: 0.4)),
        ExerciseStep(number: "3", title: "Step 3: Focus on smooth airflow",
                     description: "Keep a continuous, gentle airflow as you speak.",
                     color: Color(red: 0.75, green: 0.65, blue: 0.5)),
        ExerciseStep(number: "4", title: "Step 4: Try again with a full sentence",
                     description: "Apply the same technique to a complete sentence.",
                     color: Color(red: 0.95, green: 0.75, blue: 0.2))
    ]

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.91)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Back button
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 16) {

                        Spacer().frame(height: 20)

                        // Header card
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.95, green: 0.75, blue: 0.2))
                                    .frame(width: 64, height: 64)

                                Image(systemName: "waveform")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Say It Slow")
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundColor(.black)

                                Text("Stretch sounds to improve control and ease tension at the start of a word.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }

                            Spacer()
                        }
                        .padding(18)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)

                        Spacer().frame(height: 10)

                        // Steps list
                        VStack(spacing: 14) {
                            ForEach(steps) { step in
                                StepRow(step: step)
                            }
                        }

                        // Done button
                        Button(action: {
                            showExcellent = true
                        }) {
                            Text("Done")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .background(Color(red: 0.55, green: 0.65, blue: 0.4))
                        .cornerRadius(16)
                        .padding(.top, 6)

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                }

                TabBarView()
            }

            // Excellent screen appears instantly, no animation
            if showExcellent {
                ContentView(onBack: {
                    showExcellent = false
                })
                .zIndex(1)
            }
        }
    }
}

// Data model for one step
struct ExerciseStep: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let description: String
    let color: Color
}

// One row in the steps list
struct StepRow: View {
    let step: ExerciseStep

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(step.color)
                    .frame(width: 40, height: 40)

                Text(step.number)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)

                Text(step.description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            // Example of an Array
          

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

#Preview {
    SoundProlongationView()
}


