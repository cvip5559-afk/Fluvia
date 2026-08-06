//
//  AudioRecorderManager.swift
//  test
//
//  Created by Jinan Mahdi Alanazi on 23/02/1448 AH.
//
import Foundation
import AVFoundation
import Combine

class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordingTime: TimeInterval = 0
    @Published var isAnalyzing = false
    @Published var assessmentResult: String?
    @Published var showResultsScreen = false
    
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
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
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
            
            startTimer()
            
        } catch {
            print("Failed to set up recording session: \(error.localizedDescription)")
        }
    }
    
    // ⏸️ إيقاف مؤقت
    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        audioRecorder?.pause()
        stopTimer()
        isPaused = true
    }
    
    // ▶️ استئناف التسجيل
    func resumeRecording() {
        guard isRecording, isPaused else { return }
        audioRecorder?.record()
        startTimer()
        isPaused = false
    }
    
    // 🛑 إيقاف كلي وإطلاق التحليل
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopTimer()
        isRecording = false
        isPaused = false
        
        // 📍 استدعاء التحليل تلقائياً فور الانتهاء من التسجيل
        Task {
            await analyzeAudio()
        }
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
    
    // 📍 دالة التحليل
    func analyzeAudio() async {
        guard let fileURL = recordedFileURL else { return }
        
        Task { @MainActor in
            self.isAnalyzing = true
        }
        
        do {
            let text = try await AIService.shared.transcribeAudio(fileURL: fileURL)
            let category = try await AIService.shared.classifyStutter(transcription: text)
            
            Task { @MainActor in
                self.assessmentResult = category
                self.isAnalyzing = false
                self.showResultsScreen = true // 📍 تفعيل الانتقال لشاشة النتائج
            }
        } catch {
            print("Error during assessment: \(error.localizedDescription)")
            Task { @MainActor in
                self.isAnalyzing = false
                // حتى لو حدث خطأ في الـ API، نفتح الشاشة بالقيم الافتراضية للتجربة
                self.showResultsScreen = true
            }
        }
    }
}
