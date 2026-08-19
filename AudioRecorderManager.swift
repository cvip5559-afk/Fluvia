import Foundation
import AVFoundation
import Combine

class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordingTime: TimeInterval = 0
    @Published var isAnalyzing = false
    @Published var assessmentResult: String?
    @Published var assessmentConfidence: Double?
    @Published var showResultsScreen = false
    @Published var errorMessage: String?   // ⬅️ جديد

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    var recordedFileURL: URL?

    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)

            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("recording.m4a")
            self.recordedFileURL = audioFilename
            guard let fileURL = recordedFileURL else { return }

            //  لازم يطابق sampleRate اللي دربت عليه الموديل (16000)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            isRecording = true
            isPaused = false
            recordingTime = 0
            assessmentResult = nil
            showResultsScreen = false
            errorMessage = nil
            startTimer()

        } catch {
            errorMessage = "تعذّر بدء التسجيل: \(error.localizedDescription)"
        }
    }

    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        audioRecorder?.pause()
        stopTimer()
        isPaused = true
    }

    func resumeRecording() {
        guard isRecording, isPaused else { return }
        audioRecorder?.record()
        startTimer()
        isPaused = false
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopTimer()
        isRecording = false
        isPaused = false
        Task { await analyzeAudio() }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @MainActor
    func analyzeAudio() async {
        guard let fileURL = recordedFileURL else { return }
        isAnalyzing = true
        errorMessage = nil

        do {
            let result = try await StutterClassifierService.shared.classify(fileURL: fileURL)
            self.assessmentResult = result.label
            self.assessmentConfidence = result.confidence
            self.isAnalyzing = false
            self.showResultsScreen = true
        } catch {

            self.isAnalyzing = false
            self.errorMessage = "تعذّر تحليل الصوت: \(error.localizedDescription)"
            self.showResultsScreen = false
        }
    }
}
