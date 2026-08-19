////
//  PauseExercise.swift
//  FluviaApp
//
//  Created by Sara Alzannan on 21/02/1448 AH.
//

import SwiftUI

struct PauseExerciseView: View {

    var onBack: (() -> Void)? = nil
    var onGoHome: (() -> Void)? = nil

    // MARK: Palette
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow
    private let purpleColor     = Color(red: 0.58, green: 0.40, blue: 0.68)

    // MARK: - Config
    private let readInterval = 5
    private let pauseDuration = 5
    private let totalDuration = 60

    private let sentences = [
        "\"The weather today is calm and the sky is clear over the quiet hills.\"",
        "\"She walked slowly through the garden, enjoying the cool morning breeze.\"",
        "\"Every small step forward builds confidence and strengthens your voice.\""
    ]

    // MARK: - State
    @State private var currentSentenceIndex = 0
    @State private var cycleElapsed = 0
    @State private var pauseCount = 0
    @State private var totalElapsedSeconds = 0
    @State private var isPausing = false
    @State private var isRunning = false
    @State private var isFinished = false
    @State private var timer: Timer?
    @State private var didMarkDayComplete = StreakManager.isTodayCompleted

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
            // Main Background Color
            backgroundColor.ignoresSafeArea()

            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    titleSection
                    practiceContent
                    Spacer().frame(height: 20)
                }
                .padding(.bottom, 90)
            }

            // MARK: - Pop-up Modal Overlay
            if isFinished {
                
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)

              
                completionCard
                    .padding(.horizontal, 28)
                    .transition(.scale(scale: 0.88).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isFinished)
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 4) {
            HStack {
                BackButton(action: { onBack?() }, textColor: darkTextColor)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            Text("Silent Pause")
                .font(.custom("Georgia", size: 30))
                .fontWeight(.bold)
                .foregroundColor( darkTextColor)
            
           
        }
    }

    // MARK: - Practice Content

    private var practiceContent: some View {
        VStack(spacing: 20) {
            Text("Practice reading for 1 min with silent pauses to break the filler-word habit.")
                .font(.system(size: 15))
                .foregroundColor(.primary.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            readingCardView
                .padding(.horizontal, 20)

            pauseCoachCard
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Reading Card View

    private var readingCardView: some View {
        VStack(spacing: 20) {
            Text(sentences[currentSentenceIndex])
                .font(.system(size: 16, weight: .semibold))
                .lineSpacing(4)
                .foregroundColor(darkTextColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding(.horizontal, 16)
                .padding(.top, 20)

            HStack {
                Button(action: {
                    if currentSentenceIndex > 0 {
                        currentSentenceIndex -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(darkTextColor)
                        .frame(width: 32, height: 32)
                        .background(backgroundColor)
                        .clipShape(Circle())
                }
                .disabled(currentSentenceIndex == 0)
                .opacity(currentSentenceIndex == 0 ? 0.3 : 1.0)

                Spacer()

                HStack(spacing: 6) {
                    ForEach(0..<sentences.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentSentenceIndex ? darkTextColor : darkTextColor.opacity(0.2))
                            .frame(width: index == currentSentenceIndex ? 18 : 6, height: 6)
                            .animation(.easeInOut, value: currentSentenceIndex)
                    }
                }

                Spacer()

                Button(action: {
                    if currentSentenceIndex < sentences.count - 1 {
                        currentSentenceIndex += 1
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(darkTextColor)
                        .frame(width: 32, height: 32)
                        .background(backgroundColor)
                        .clipShape(Circle())
                }
                .disabled(currentSentenceIndex == sentences.count - 1)
                .opacity(currentSentenceIndex == sentences.count - 1 ? 0.3 : 1.0)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    // MARK: - Pause Coach Card

    private var pauseCoachCard: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 2)

            pauseBubble

            Text(formattedTime)
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .foregroundColor(darkTextColor)
                .frame(maxWidth: .infinity, alignment: .center)

            Button(action: toggleExercise) {
                Text(isRunning ? "End Exercise" : "Start Exercise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .background(greenColor)
            .cornerRadius(16)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 6)
        )
    }

    private var pauseBubble: some View {
        ZStack {
            Circle()
                .fill(pauseBubbleColor.opacity(0.18))
                .frame(width: 210, height: 210)

            Circle()
                .fill(pauseBubbleColor.opacity(0.32))
                .frame(width: 150, height: 150)

            Text("Pause")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isPausing ? .white : darkTextColor.opacity(0.6))
        }
        .frame(height: 220)
        .animation(.easeInOut(duration: 0.3), value: isPausing)
    }

    private var pauseBubbleColor: Color {
        isPausing ? purpleColor : Color.gray.opacity(0.4)
    }

    // MARK: - Pop-up Completion Card

    private var completionCard: some View {
        VStack(spacing: 18) {
           
            HStack {
                Spacer()
                Button(action: {
                    if let onGoHome {
                        onGoHome()
                    } else {
                        withAnimation { isFinished = false }
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(darkTextColor.opacity(0.6))
                        .padding(8)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, -10)

            ZStack {
                Circle()
                    .fill(goldColor.opacity(0.25))
                    .frame(width: 90, height: 90)
                Image(systemName: "sparkles")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundColor(goldColor)
            }

            Text("Session Complete!")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)

            Text("You practiced 1 minute of paced reading with silent pauses. Slow and steady builds the habit!")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            VStack(spacing: 12) {
                Button(action: markDayComplete) {
                    HStack(spacing: 8) {
                        Image(systemName: "flag.checkered")
                        Text("Done")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(darkTextColor)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(goldColor)
                    .cornerRadius(18)
                }

                Button(action: resetSession) {
                    Text("Practice Again")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(greenColor)
                        .cornerRadius(18)
                }
            }
            .padding(.top, 6)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 10)
        )
    }

    // MARK: - Logic

    private func toggleExercise() {
        isRunning ? endExercise() : startTimer()
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            tick()
        }
    }

    private func endExercise() {
        timer?.invalidate()
        timer = nil
        resetSession()
    }

    private func resetSession() {
        currentSentenceIndex = 0
        cycleElapsed = 0
        pauseCount = 0
        totalElapsedSeconds = 0
        isPausing = false
        isFinished = false
        isRunning = false
        didMarkDayComplete = false
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
            timer?.invalidate()
            timer = nil
            isRunning = false
            withAnimation { isFinished = true }
            return
        }

        if cycleElapsed >= readInterval {
            isPausing = true
            pauseCount = 1
        }
    }

    private func markDayComplete() {
        if !didMarkDayComplete {
            withAnimation {
                StreakManager.markTodayComplete()
                DailyProgressManager.markExerciseDone()
                didMarkDayComplete = true
            }
        }
        onGoHome?()
    }
}

#Preview {
    PauseExerciseView()
}
