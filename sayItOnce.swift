//
//  BuildSentenceView.swift
//  stutter
//
//  Created by reema alharbi on 26/02/1448 AH.
import SwiftUI

struct SayItOnce: View {

enum Level: String, CaseIterable {
case easy = "Easy"
case medium = "Medium"
case hard = "Hard"

var emoji: String {
switch self {
case .easy: return "🟢"
case .medium: return "🟡"
case .hard: return "🔴"
}
}
}

// Sentences per level — adult topics: work, bills, appointments
static let sentences: [Level: [[String]]] = [
.easy: [
["I", "need", "coffee"],
["I", "am", "late"],
["She", "is", "busy"],
["He", "is", "driving"],
["We", "are", "working"]
],
.medium: [
["I", "have", "a", "meeting", "today"],
["She", "paid", "the", "electricity", "bill"],
["We", "booked", "a", "doctor's", "appointment"],
["He", "renewed", "his", "car", "insurance"],
["They", "signed", "the", "rental", "contract"]
],
.hard: [
["I", "need", "to", "submit", "the", "report", "before", "Friday"],
["She", "is", "negotiating", "a", "raise", "with", "her", "manager"],
["We", "are", "refinancing", "our", "mortgage", "this", "month"],
["He", "postponed", "the", "meeting", "due", "to", "a", "conflict"],
["They", "are", "reviewing", "the", "quarterly", "budget", "report"]
]
]

@State private var level: Level = .easy
@State private var sentenceIndex: Int = 0
@State private var wordCount: Int = 0
@State private var isComplete: Bool = false

private var currentSentence: [String] {
Self.sentences[level]![sentenceIndex]
}

private var progress: CGFloat {
currentSentence.isEmpty ? 0 : CGFloat(wordCount) / CGFloat(currentSentence.count)
}

var body: some View {
VStack(spacing: 0) {
ScrollView {
VStack(spacing: 22) {

// Title
Text("Build the Sentence")
.font(.custom("Georgia-Bold", size: 30))
.padding(.top, 30)

// Icon
Image(systemName: "bubble.left.and.bubble.right.fill")
.resizable()
.scaledToFit()
.frame(width: 60, height: 60)
.foregroundColor(.brown)

// Subtitle
Text("Build your sentence word by word,\nthen say it out loud.")
.font(.system(size: 16))
.foregroundColor(.gray)
.multilineTextAlignment(.center)

// Level selector
HStack(spacing: 8) {
ForEach(Level.allCases, id: \.self) { lvl in
Button {
selectLevel(lvl)
} label: {
VStack(spacing: 4) {
Text(lvl.emoji)
.font(.system(size: 15))
Text(lvl.rawValue)
.font(.system(size: 13, weight: .bold))
.foregroundColor(level == lvl ? .black : .gray)
}
.frame(maxWidth: .infinity)
.padding(.vertical, 10)
.background(Color.white)
.cornerRadius(14)
.overlay(
RoundedRectangle(cornerRadius: 14)
.stroke(level == lvl ? Color.yellow : Color.clear, lineWidth: 2)
)
.shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
}
.buttonStyle(.plain)
}
}
.padding(.horizontal)

// Circular ring - fills up with each word
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
.animation(.easeInOut(duration: 0.4), value: progress)

Circle()
.fill(Color.yellow)
.frame(width: 180, height: 180)

VStack(spacing: 4) {
Text(isComplete ? "✓" : "\(wordCount)")
.font(.system(size: 46, weight: .heavy))
.contentTransition(.numericText())
Text(isComplete ? "SAY IT" : "WORD \(wordCount)/\(currentSentence.count)")
.font(.system(size: 12, weight: .semibold))
}
}
.padding(.vertical, 10)

// Sentence card
FlowWords(words: Array(currentSentence.prefix(wordCount)), highlightLast: !isComplete)
.frame(maxWidth: .infinity, minHeight: 96)
.padding()
.background(Color.white)
.cornerRadius(18)
.shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
.padding(.horizontal)

// Prompt
Text(isComplete ? "🔊 Say the complete sentence out loud" : "Tap \"Next\" to add a word")
.font(.system(size: 15, weight: isComplete ? .bold : .regular))
.foregroundColor(isComplete ? .brown : .gray)
.multilineTextAlignment(.center)

// How it works steps
VStack(spacing: 14) {
StepRow(number: 1, text: "Watch each word appear", color: .brown)
StepRow(number: 2, text: "Wait for the sentence to complete", color: Color(red: 0.55, green: 0.75, blue: 0.55))
StepRow(number: 3, text: "Say it out loud", color: Color(red: 0.75, green: 0.68, blue: 0.5))
StepRow(number: 4, text: "Tap \"Done\" and move to the next", color: .yellow)
}
.padding(.horizontal)

// Next / Done button
Button(action: advance) {
Text(isComplete ? "Done ✓" : "Next")
.font(.system(size: 18, weight: .bold))
.foregroundColor(.white)
.frame(maxWidth: .infinity)
.padding()
.background(isComplete ? Color(red: 0.55, green: 0.65, blue: 0.45) : Color.brown)
.cornerRadius(16)
}
.padding(.horizontal)

// Skip
Button(action: skip) {
Text("Skip")
.font(.system(size: 14, weight: .semibold))
.foregroundColor(.gray)
}
.padding(.bottom, 10)
}
.padding(.bottom, 20)
}

// Bottom tab bar (same component as before)
BottomTabBar()
}
.background(Color(red: 0.97, green: 0.95, blue: 0.90).ignoresSafeArea())
}

// MARK: - Exercise logic

private func advance() {
if !isComplete {
withAnimation {
wordCount += 1
if wordCount == currentSentence.count {
isComplete = true
}
}
} else {
nextSentence()
}
}

private func skip() {
nextSentence()
}

private func nextSentence() {
let total = Self.sentences[level]!.count
withAnimation {
sentenceIndex = (sentenceIndex + 1) % total
wordCount = 0
isComplete = false
}
}

private func selectLevel(_ lvl: Level) {
withAnimation {
level = lvl
sentenceIndex = 0
wordCount = 0
isComplete = false
}
}
}

// Displays the sentence words, highlighting the last one added
struct FlowWords: View {
let words: [String]
let highlightLast: Bool

var body: some View {
Text(attributedText)
.font(.custom("Georgia-Bold", size: 26))
.multilineTextAlignment(.center)
.environment(\.layoutDirection, .leftToRight)
}

private var attributedText: AttributedString {
var result = AttributedString("")
for (idx, word) in words.enumerated() {
var piece = AttributedString(word)
piece.foregroundColor = (idx == words.count - 1 && highlightLast) ? .brown : .primary
result += piece
if idx < words.count - 1 {
result += AttributedString(" ")
}
}
return result.characters.isEmpty ? AttributedString(" ") : result
}
}

#Preview {
SayItOnce()
}

