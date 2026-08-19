import SwiftUI

// MARK: - SoundRepetitionExerciseView

struct SoundRepetitionExerciseView: View {

    var onBack: (() -> Void)? = nil
    var onGoHome: (() -> Void)? = nil

    // MARK: Shared streak progress
    @State private var didMarkDayComplete = StreakManager.isTodayCompleted

    // MARK: Palette
    private let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let darkTextColor   = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let greenColor      = Color(red: 0.45, green: 0.55, blue: 0.35)
    private let goldColor       = Color.yellow

    // MARK: Practice content
    private struct PracticeWord {
        let repeatedSound: String
        let restOfWord: String
        var fullWord: String { repeatedSound + restOfWord }
    }

    private let wordBank: [PracticeWord] = [
        PracticeWord(repeatedSound: "s",   restOfWord: "ophisticated"),
        PracticeWord(repeatedSound: "str", restOfWord: "ategically"),
        PracticeWord(repeatedSound: "sp",  restOfWord: "ontaneously"),
        PracticeWord(repeatedSound: "c",   restOfWord: "ircumstances"),
        PracticeWord(repeatedSound: "un",  restOfWord: "precedented"),
        PracticeWord(repeatedSound: "con", restOfWord: "troversial")
    ]

    // MARK: State
    @State private var currentIndex = 0
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false
    @State private var stretchComplete = false
    @State private var completedIndices: Set<Int> = []
    @State private var sessionFinished = false
    @State private var showTryAgainHint = false
    @State private var timer: Timer? = nil

    private let holdDuration: Double = 2.0
    private let tickInterval: Double = 0.02

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        titleSection

                        if sessionFinished {
                            completionCard
                        } else {
                            wordProgressRow
                            practiceCard
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 100) // room above the global tab bar
                }
            }
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 4) {
            if let onBack {
                HStack {
                    BackButton(action: onBack, textColor: darkTextColor)
                    Spacer()
                }
                .padding(.bottom, 4)
            }

            Text("Sound Repetition")
                .font(.custom("Georgia", size: 30))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)

            Text("Smooth Start Practice")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary.opacity(0.5))
        }
        .padding(.top, 8)
    }

    // MARK: - Word progress row

    private var wordProgressRow: some View {
        HStack(spacing: 0) {
            ForEach(0..<wordBank.count, id: \.self) { i in
                wordDot(index: i)
                if i < wordBank.count - 1 {
                    Capsule()
                        .fill(completedIndices.contains(i) ? greenColor : Color.gray.opacity(0.18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 3)
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private func wordDot(index: Int) -> some View {
        let isCompleted = completedIndices.contains(index)
        let isCurrent = index == currentIndex && !isCompleted

        return ZStack {
            Circle()
                .fill(isCompleted ? greenColor : (isCurrent ? goldColor.opacity(0.25) : Color.gray.opacity(0.15)))
                .frame(width: 30, height: 30)

            if isCurrent {
                Circle()
                    .stroke(goldColor, lineWidth: 2.5)
                    .frame(width: 30, height: 30)
            }

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isCurrent ? darkTextColor : .gray)
            }
        }
    }

    // MARK: - Practice Card

    private var practiceCard: some View {
        VStack(spacing: 22) {

            HStack(spacing: 10) {
                Image(systemName: "waveform")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(darkTextColor)
                Text("Stretch & Glide")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(darkTextColor)
                Spacer()
            }

            wordDisplay

            holdButton

            instructionText

            if showTryAgainHint {
                Text("Almost! hold a touch longer, nice and gentle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(goldColor.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 6)
        )
    }

    private var wordDisplay: some View {
        let word = wordBank[currentIndex]
        return HStack(spacing: 2) {
            Text(word.repeatedSound)
                .foregroundColor(stretchComplete ? greenColor : goldColor)
            Text(word.restOfWord)
                .foregroundColor(darkTextColor)
        }
        .font(.custom("Georgia", size: 30))
        .fontWeight(.bold)
    }

    private var instructionText: some View {
        Text(stretchComplete
             ? "Now glide into the word, nice and smooth!"
             : "Press and hold, gently stretch the sound for 2 seconds")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Hold-to-Stretch Button

    private var ringColor: Color {
        if stretchComplete { return greenColor }
        return holdProgress > 0.85 ? goldColor : greenColor
    }

    private var holdButton: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 14)

            Circle()
                .trim(from: 0, to: stretchComplete ? 1 : max(holdProgress, 0.015))
                .stroke(ringColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: tickInterval), value: holdProgress)

            VStack(spacing: 6) {
                if stretchComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(greenColor)
                    Text("Great!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(darkTextColor)
                } else {
                    Text(wordBank[currentIndex].repeatedSound + "…")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(darkTextColor)
                        .scaleEffect(isHolding ? 1.08 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isHolding)
                    Text(isHolding ? "keep going…" : "hold to stretch")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: 220, height: 220)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !stretchComplete else { return }
                    if !isHolding { beginHold() }
                }
                .onEnded { _ in
                    guard !stretchComplete else { return }
                    endHold()
                }
        )
        .padding(.top, 4)
    }

    private func beginHold() {
        isHolding = true
        showTryAgainHint = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            holdProgress = min(holdProgress + CGFloat(tickInterval / holdDuration), 1.0)
            if holdProgress >= 1.0 {
                completeStretch()
            }
        }
    }

    private func endHold() {
        isHolding = false
        timer?.invalidate()
        timer = nil
        if holdProgress < 0.98 {
            withAnimation(.easeInOut(duration: 0.4)) {
                holdProgress = 0
            }
            withAnimation { showTryAgainHint = true }
        }
    }

    private func completeStretch() {
        timer?.invalidate()
        timer = nil
        isHolding = false
        withAnimation(.easeOut(duration: 0.3)) {
            stretchComplete = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            advanceToNextWord()
        }
    }

    private func advanceToNextWord() {
        completedIndices.insert(currentIndex)

        if currentIndex == wordBank.count - 1 {
            withAnimation { sessionFinished = true }
            return
        }

        withAnimation(.easeInOut(duration: 0.35)) {
            currentIndex += 1
            holdProgress = 0
            stretchComplete = false
            showTryAgainHint = false
        }
    }

    // MARK: - Completion Card

    private var completionCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(goldColor.opacity(0.2))
                    .frame(width: 110, height: 110)
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(goldColor)
            }

            Text("Session Complete!")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.bold)
                .foregroundColor(darkTextColor)

            Text("You practiced \(wordBank.count) smooth starts. Slow and steady builds the habit, see you tomorrow!")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

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
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 6)
        )
        .overlay(alignment: .topTrailing) {
            if let onGoHome {
                Button(action: onGoHome) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(darkTextColor)
                        .padding(8)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Circle())
                }
                .padding(14)
            }
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

    private func resetSession() {
        withAnimation {
            currentIndex = 0
            holdProgress = 0
            isHolding = false
            stretchComplete = false
            completedIndices.removeAll()
            sessionFinished = false
            showTryAgainHint = false
        }
    }
}


// MARK: - Preview

#Preview {
    SoundRepetitionExerciseView()
}
