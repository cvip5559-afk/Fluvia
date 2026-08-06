//
//  Exercise.swift
//  FluviaApp
//
//  Created by Sara Alzannan on 21/02/1448 AH.

import SwiftUI

struct PauseExerciseView: View {
    // MARK: - Config
    private let readInterval = 5            // seconds of reading before each pause
    private let pauseDuration = 5           // seconds of silence per pause
    private let totalDuration = 60          // total reading time for the whole session

    private let sentences = [
        "The weather today is calm and the sky is clear over the quiet hills.",
        "She walked slowly through the garden, enjoying the cool morning breeze.",
        "Every small step forward builds confidence and strengthens your voice."
    ]

    // MARK: - State
    @State private var currentSentenceIndex = 0
    @State private var cycleElapsed = 0          // internal reading tick count, not shown
    @State private var pauseCount = 0            // counts up 1...pauseDuration while pausing
    @State private var totalElapsedSeconds = 0   // drives the centered mm:ss timer
    @State private var isPausing = false
    @State private var isRunning = false
    @State private var isFinished = false
    @State private var timer: Timer?

    private var sentence: String {
        sentences[currentSentenceIndex]
    }

    private var formattedTime: String {
        let minutes = totalElapsedSeconds / 60
        let seconds = totalElapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.91)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Text("Silent Pause")
                        .font(.custom("Georgia-Bold", size: 24))
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.15))

                    HStack {
                        Button(action: {
                            print("go to next page")
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.15))
                        }

                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                

                Text("Practice reading for 1 min with silent pauses to break the filler-word habit.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                // Sentence card with a right arrow to move to the next sentence anytime
                HStack(spacing: 12) {
                    Text(sentence)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.15))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: nextSentence) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.15))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal, 20)

                // Pause indicator circle — no number, circle and label both turn purple while pausing
                ZStack {
                    Circle()
                        .fill(isPausing ? Color(red: 0.55, green: 0.45, blue: 0.85) : Color(white: 0.91))
                        .frame(width: 160, height: 160)
                        .shadow(color: isPausing ? Color(red: 0.55, green: 0.45, blue: 0.85).opacity(0.5) : .clear, radius: 30)

                    Text("Pause")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(
                            isPausing
                                ? .white
                                : Color(red: 0.35, green: 0.25, blue: 0.15).opacity(0.6)
                        )
                }
                .animation(.easeInOut(duration: 0.3), value: isPausing)

                // Centered mm:ss timer, counts up to 01:00
                Text(formattedTime)
                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.15))
                    .frame(maxWidth: .infinity, alignment: .center)

                if isFinished {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 40, height: 40)
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Well done!")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            Text("You completed 1 minute of paced reading.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(red: 0.55, green: 0.45, blue: 0.85))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                }

                // Start / Stop / Restart button
                Button(action: toggleExercise) {
                    Text(buttonTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .background(Color(red: 0.45, green: 0.55, blue: 0.35))
                .cornerRadius(16)
                .padding(.horizontal, 20)

                Spacer().frame(height: 20)
            }
            .frame(maxHeight: .infinity, alignment: .top)        }
        .onDisappear { timer?.invalidate() }
    }

    private var buttonTitle: String {
        if isFinished { return "Restart" }
        return isRunning ? "Stop" : "Start Exercise"
    }

    // MARK: - Logic

    private func toggleExercise() {
        if isFinished {
            resetSession()
            return
        }
        isRunning ? stopTimer() : startTimer()
    }

    private func nextSentence() {
        currentSentenceIndex = (currentSentenceIndex + 1) % sentences.count
    }

    private func startTimer() {
        isRunning = true
        isFinished = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            tick()
        }
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resetSession() {
        cycleElapsed = 0
        pauseCount = 0
        totalElapsedSeconds = 0
        isPausing = false
        isFinished = false
        isRunning = false
    }

    private func tick() {
        if isPausing {
            if pauseCount >= pauseDuration {
                isPausing = false
                pauseCount = 0
                cycleElapsed = 0
            } else {
                pauseCount += 1
            }
            return
        }

        cycleElapsed += 1
        totalElapsedSeconds += 1

        if totalElapsedSeconds >= totalDuration {
            stopTimer()
            isFinished = true
            return
        }

        if cycleElapsed >= readInterval {
            isPausing = true
            pauseCount = 1
        }
    }
}

#Preview {
    PauseExerciseView()
}
