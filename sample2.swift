import SwiftUI
import AVFoundation

struct sample2: View {

enum Screen {
case intro, recording, results
}

@State private var screen: Screen = .intro
@State private var finalStoryText: String = ""
@State private var finalDuration: Int = 0

var body: some View {

VStack(spacing: 0) {

switch screen {

case .intro:
StoryIntroView {
screen = .recording
}

case .recording:
StoryRecordingView { storyText, duration in
finalStoryText = storyText
finalDuration = duration
screen = .results
}

case .results:
StoryResultsView(
storyText: finalStoryText,
durationSeconds: finalDuration
) {
screen = .intro
}
}

BottomTabBar()
}
.background(
Color(red: 0.97, green: 0.95, blue: 0.90)
.ignoresSafeArea()
)
}
}

// MARK: - شاشة المقدمة

struct StoryIntroView: View {

let onStart: () -> Void

private let pictures: [(emoji: String, label: String)] = [
("👦", "Boy"),
("🌳", "Park"),
("⚽", "Football"),
("🌧️", "Rain"),
("🏠", "Home")
]

var body: some View {

ScrollView {

VStack(spacing: 22) {

Text("Story Builder")
.font(.custom("Georgia-Bold", size: 30))
.padding(.top, 30)

Text("A Rainy Football Day")
.font(.system(size: 17, weight: .semibold))
.foregroundColor(.brown)

ScrollView(.horizontal, showsIndicators: false) {
HStack(spacing: 12) {
ForEach(Array(pictures.enumerated()), id: \.offset) { index, pic in
StoryPictureCard(
number: index + 1,
emoji: pic.emoji,
label: pic.label
)
}
}
.padding(.horizontal)
}

VStack(alignment: .leading, spacing: 10) {
Text("Challenge")
.font(.system(size: 16, weight: .bold))

StoryBullet(text: "Use all five pictures, in order")
StoryBullet(text: "Speak for 30–45 seconds")
StoryBullet(text: "Avoid repeating the same word too often")
}
.padding()
.frame(maxWidth: .infinity, alignment: .leading)
.background(Color.white)
.cornerRadius(14)
.padding(.horizontal)

LazyVGrid(
columns: [GridItem(.flexible()), GridItem(.flexible())],
spacing: 14
) {
StoryStepSquare(number: 1, text: "Sit comfortably", color: .brown)
StoryStepSquare(number: 2, text: "Look at the pictures", color: Color(red: 0.55, green: 0.75, blue: 0.55))
StoryStepSquare(number: 3, text: "Tell one connected story", color: Color(red: 0.75, green: 0.68, blue: 0.5))
StoryStepSquare(number: 4, text: "Avoid repeating words", color: .yellow)
}
.padding(.horizontal)

Button(action: onStart) {
HStack {
Image(systemName: "mic.fill")
Text("Start Recording")
}
.font(.system(size: 18, weight: .bold))
.foregroundColor(.white)
.frame(maxWidth: .infinity)
.padding()
.background(Color(red: 0.55, green: 0.65, blue: 0.45))
.cornerRadius(16)
}
.padding(.horizontal)
}
.padding(.bottom, 20)
}
}
}

// MARK: - Picture Card

struct StoryPictureCard: View {

let number: Int
let emoji: String
let label: String

var body: some View {

VStack(spacing: 6) {

ZStack(alignment: .topLeading) {

Circle()
.fill(Color.brown)
.frame(width: 18, height: 18)

Text("\(number)")
.font(.system(size: 10, weight: .bold))
.foregroundColor(.white)
.padding(.leading, 5)
.padding(.top, 2)

Text(emoji)
.font(.system(size: 28))
.frame(maxWidth: .infinity)
.padding(.top, 6)
}

Text(label)
.font(.system(size: 12, weight: .semibold))
.foregroundColor(.gray)
}
.frame(width: 76)
.padding(.vertical, 12)
.background(Color.white)
.cornerRadius(14)
}
}

// MARK: - Steps

struct StoryStepSquare: View {

let number: Int
let text: String
let color: Color

var body: some View {

VStack(spacing: 10) {

Circle()
.fill(color)
.frame(width: 34, height: 34)
.overlay(
Text("\(number)")
.font(.system(size: 15, weight: .bold))
.foregroundColor(.white)
)

Text(text)
.font(.system(size: 14, weight: .semibold))
.multilineTextAlignment(.center)
}
.frame(maxWidth: .infinity, minHeight: 120)
.padding()
.background(Color.white)
.cornerRadius(16)
}
}

// MARK: - Bullet

struct StoryBullet: View {

let text: String

var body: some View {

HStack {
Text("•")
.foregroundColor(.gray)

Text(text)
.font(.system(size: 14))
.foregroundColor(.gray)
}
}
}

// MARK: - شاشة 2: التسجيل

struct StoryRecordingView: View {

let onFinish: (String, Int) -> Void

private let totalSeconds = 45

@State private var secondsElapsed = 0
@State private var progress: CGFloat = 0
@State private var timer: Timer?

@StateObject private var speechRecognize = SpeechRecognizer()

private let pictures = ["👦", "🌳", "⚽", "🌧️", "🏠"]

var body: some View {

ScrollView {

VStack(spacing: 22) {

Text("Story Builder")
.font(.custom("Georgia-Bold", size: 30))
.padding(.top, 30)

Text("🎤 Recording…")
.font(.system(size: 15, weight: .bold))
.foregroundColor(.brown)

Text(
speechRecognize.text.isEmpty
? "Start speaking..."
: speechRecognize.text
)
.font(.system(size: 14))
.foregroundColor(.gray)
.multilineTextAlignment(.center)
.padding(.horizontal)

ZStack {

Circle()
.stroke(Color.yellow.opacity(0.25), lineWidth: 14)
.frame(width: 220, height: 220)

Circle()
.trim(from: 0, to: progress)
.stroke(
Color.yellow,
style: StrokeStyle(lineWidth: 14, lineCap: .round)
)
.frame(width: 220, height: 220)
.rotationEffect(.degrees(-90))

Circle()
.fill(Color.yellow)
.frame(width: 180, height: 180)

VStack(spacing: 4) {
Image(systemName: "mic.fill")
.font(.system(size: 30))

Text("00:\(String(format: "%02d", secondsElapsed)) / 00:45")
.font(.system(size: 14, weight: .semibold))
}
}
.padding(.vertical, 10)

HStack(spacing: 10) {
ForEach(pictures, id: \.self) { emoji in
Text(emoji)
.font(.system(size: 18))
.frame(width: 36, height: 36)
.background(Color.white)
.cornerRadius(10)
}
}

Button {
speechRecognize.stopRecording()
stopTimer()
onFinish(speechRecognize.text, secondsElapsed)
} label: {
HStack {
Image(systemName: "stop.fill")
Text("Stop Recording")
}
.font(.system(size: 18, weight: .bold))
.foregroundColor(.white)
.frame(maxWidth: .infinity)
.padding()
.background(Color.brown)
.cornerRadius(16)
}
.padding(.horizontal)
}
.padding(.bottom, 20)
}
.onAppear {
startTimer()

speechRecognize.requestPermission { granted in
if granted {
speechRecognize.startRecording()
} else {
print("❌ Speech or microphone permission denied")
}
}
}
.onDisappear {
speechRecognize.stopRecording()
stopTimer()
}
}

// MARK: - Timer

private func startTimer() {

stopTimer()

secondsElapsed = 0
progress = 0

timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in

if secondsElapsed < totalSeconds {
secondsElapsed += 1
withAnimation {
progress = CGFloat(secondsElapsed) / CGFloat(totalSeconds)
}
}

if secondsElapsed >= totalSeconds {
speechRecognize.stopRecording()
stopTimer()
onFinish(speechRecognize.text, secondsElapsed)
}
}
}

private func stopTimer() {
timer?.invalidate()
timer = nil
}
}

// MARK: - شاشة 3: النتائج

struct StoryResultsView: View {

let storyText: String
let durationSeconds: Int
let onTryAgain: () -> Void

@StateObject private var analyzer = StoryAnalyzer()

var body: some View {

ScrollView {

VStack(spacing: 22) {

Text("Nice work!")
.font(.custom("Georgia-Bold", size: 30))
.padding(.top, 30)

if analyzer.isAnalyzing {

VStack(spacing: 16) {
ProgressView()
.scaleEffect(1.5)
Text("Analyzing your story...")
.font(.system(size: 15, weight: .semibold))
.foregroundColor(.gray)
}
.padding(.top, 60)

} else if let error = analyzer.errorMessage {

VStack(spacing: 16) {
Image(systemName: "exclamationmark.triangle.fill")
.font(.system(size: 40))
.foregroundColor(.orange)
Text(error)
.font(.system(size: 14))
.foregroundColor(.gray)
.multilineTextAlignment(.center)
.padding(.horizontal)
}
.padding(.top, 60)

} else if let analysis = analyzer.result {

resultsContent(analysis)
}
}
}
.task {
await analyzer.analyze(storyText: storyText, durationSeconds: durationSeconds)
}
}

@ViewBuilder
private func resultsContent(_ analysis: StoryAnalysis) -> some View {

ZStack {

Circle()
.stroke(Color.yellow.opacity(0.25), lineWidth: 14)
.frame(width: 190, height: 190)

Circle()
.trim(from: 0, to: CGFloat(analysis.overallScore) / 100)
.stroke(
Color(red: 0.55, green: 0.65, blue: 0.45),
style: StrokeStyle(lineWidth: 14, lineCap: .round)
)
.frame(width: 190, height: 190)
.rotationEffect(.degrees(-90))

Circle()
.fill(Color.white)
.frame(width: 150, height: 150)

VStack {
Text("\(analysis.overallScore)")
.font(.system(size: 34, weight: .bold))

Text("OVERALL SCORE")
.font(.system(size: 11, weight: .semibold))
.foregroundColor(.gray)
}
}

HStack {
ForEach(0..<3) { i in
Image(systemName: i < analysis.stars ? "star.fill" : "star")
.foregroundColor(.yellow)
}
}

LazyVGrid(
columns: [GridItem(.flexible()), GridItem(.flexible())],
spacing: 12
) {
StoryStatCard(label: "WORD REPETITION", value: "\(analysis.wordRepetition)")
StoryStatCard(label: "FLUENCY", value: analysis.fluency, good: true)
StoryStatCard(label: "SPEAKING PACE", value: analysis.pace, good: true)
StoryStatCard(
label: "STORY COMPLETION",
value: analysis.storyComplete ? "✓ Complete" : "Incomplete",
good: analysis.storyComplete
)
}
.padding(.horizontal)

VStack(alignment: .leading, spacing: 10) {

HStack {
Image(systemName: "checkmark.circle.fill")
.foregroundColor(Color(red: 0.55, green: 0.65, blue: 0.45))

Text(analysis.feedback)
.font(.system(size: 15, weight: .bold))
}

if analysis.wordRepetition > 1 {

Text("You repeated the word \"\(analysis.repeatedWord)\" \(analysis.wordRepetition) times. Try swapping in a different word next time:")
.font(.system(size: 14))

HStack {
ForEach(analysis.alternatives, id: \.self) { word in
Text(word)
.foregroundColor(.brown)
.padding(.horizontal, 10)
.padding(.vertical, 4)
.background(Color.yellow.opacity(0.25))
.clipShape(Capsule())
}
}
}
}
.padding()
.background(Color.white)
.cornerRadius(14)
.padding(.horizontal)

HStack {
StoryTag(text: "🎯 Goal: 0–1 repeats")
StoryTag(text: "⏱️ \(durationSeconds) sec")
}

Button(action: onTryAgain) {
HStack {
Image(systemName: "arrow.clockwise")
Text("Try Again")
}
.font(.system(size: 18, weight: .bold))
.foregroundColor(.white)
.frame(maxWidth: .infinity)
.padding()
.background(Color(red: 0.55, green: 0.65, blue: 0.45))
.cornerRadius(16)
}
.padding(.horizontal)

Button(action: onTryAgain) {
Text("Done")
.font(.system(size: 16, weight: .bold))
.foregroundColor(.brown)
.frame(maxWidth: .infinity)
.padding()
.overlay(
RoundedRectangle(cornerRadius: 16)
.stroke(Color.brown, lineWidth: 2)
)
}
.padding(.horizontal)
}
}

// MARK: - Cards

struct StoryStatCard: View {

let label: String
let value: String
var good: Bool = false

var body: some View {

VStack(alignment: .leading) {

Text(label)
.font(.system(size: 11, weight: .semibold))
.foregroundColor(.gray)

Text(value)
.font(.system(size: 16, weight: .bold))
.foregroundColor(
good
? Color(red: 0.4, green: 0.55, blue: 0.35)
: .black
)
}
.padding()
.background(Color.white)
.cornerRadius(14)
}
}

struct StoryTag: View {

let text: String

var body: some View {

Text(text)
.font(.system(size: 12, weight: .semibold))
.foregroundColor(.brown)
.padding(.horizontal, 12)
.padding(.vertical, 6)
.background(Color.white)
.clipShape(Capsule())
}
}

#Preview {
sample2()
}
