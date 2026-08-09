import Foundation
import Speech
import AVFoundation
import Combine

class SpeechRecognizer: ObservableObject {

private let speechRecognizer =
SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
private var recognitionTask: SFSpeechRecognitionTask?
private let audioEngine = AVAudioEngine()

@Published var text = ""
@Published var errorMessage: String?

// MARK: - Permission

func requestPermission(completion: @escaping (Bool) -> Void) {

AVAudioSession.sharedInstance().requestRecordPermission { microphoneGranted in

guard microphoneGranted else {
DispatchQueue.main.async {
self.errorMessage = "Microphone permission denied"
completion(false)
}
return
}

SFSpeechRecognizer.requestAuthorization { status in
DispatchQueue.main.async {
if status == .authorized {
completion(true)
} else {
self.errorMessage = "Speech recognition permission denied"
completion(false)
}
}
}
}
}

// MARK: - Start Speech Recognition

func startRecording() {

recognitionTask?.cancel()
recognitionTask = nil
errorMessage = nil
text = ""

recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

guard let recognitionRequest = recognitionRequest else {
errorMessage = "Unable to create recognition request"
return
}

recognitionRequest.shouldReportPartialResults = true

recognitionTask = speechRecognizer?.recognitionTask(
with: recognitionRequest
) { [weak self] result, error in

guard let self = self else { return }

if let result = result {
DispatchQueue.main.async {
self.text = result.bestTranscription.formattedString
}
}

if let error = error {
DispatchQueue.main.async {
self.errorMessage = error.localizedDescription
self.audioEngine.stop()
self.audioEngine.inputNode.removeTap(onBus: 0)
}
}
}

let audioSession = AVAudioSession.sharedInstance()

do {
try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

let inputNode = audioEngine.inputNode
let recordingFormat = inputNode.outputFormat(forBus: 0)

guard recordingFormat.sampleRate > 0,
recordingFormat.channelCount > 0 else {
errorMessage = "Invalid audio format"
return
}

inputNode.removeTap(onBus: 0)

inputNode.installTap(
onBus: 0,
bufferSize: 1024,
format: recordingFormat
) { buffer, _ in
recognitionRequest.append(buffer)
}

audioEngine.prepare()
try audioEngine.start()

print("🎤 Speech recognition started")

} catch {
errorMessage = error.localizedDescription
print("❌ Speech recognition error:", error.localizedDescription)
}
}

// MARK: - Stop

func stopRecording() {

if audioEngine.isRunning {
audioEngine.stop()
}

audioEngine.inputNode.removeTap(onBus: 0)

recognitionRequest?.endAudio()
recognitionTask?.cancel()

recognitionRequest = nil
recognitionTask = nil

do {
try AVAudioSession.sharedInstance()
.setActive(false, options: .notifyOthersOnDeactivation)
} catch {
print("⚠️ Could not deactivate audio session:", error.localizedDescription)
}
}
}
