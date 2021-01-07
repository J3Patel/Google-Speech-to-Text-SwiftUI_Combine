//
//  AudioRecorder.swift
//  SwiftUI_Combine
//
//  Created by Jatin on 06/01/21.
//

import Foundation
import Combine
import AVFoundation

final class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    var audioURL: AnyPublisher<URL, Never> {
        return audioSubject.eraseToAnyPublisher()
    }
    var state: AnyPublisher<Bool, Never> {
        return recordingState.eraseToAnyPublisher()
    }
    var permission: AnyPublisher<AVAudioSession.RecordPermission, Never> {
        return permissionState.eraseToAnyPublisher()
    }
    
    private let audioSubject = PassthroughSubject<URL, Never>()
    private let recordingState = PassthroughSubject<Bool, Never>()
    private var permissionState = PassthroughSubject<AVAudioSession.RecordPermission, Never>()
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    private var subscribers = Set<AnyCancellable>()
    
    override init() {
        super.init()
        checkPermission()
    }
    
    private func checkPermission() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        permissionState.send(.denied)
                    }
                }
            }
        } catch {
            permissionState.send(.denied)
        }
    }
    
    func recordOrStop() {
        if AVAudioSession.sharedInstance().recordPermission != .granted {
            permissionState.send(.denied)
            return
        }
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.caf")
        
        let settings = [
            AVEncoderBitRateKey: 16,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            
            audioRecorder.publisher(for: \.isRecording)
                .subscribe(recordingState)
                .store(in: &subscribers)
            
            
            audioRecorder.delegate = self
            audioRecorder.record()
            recordingState.send(true)
        } catch {
            finishRecording(success: false)
        }
    }
    
    internal func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag {
            audioSubject.send(recorder.url)
        } else {
            finishRecording(success: flag)
        }
    }
    
    private func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        recordingState.send(false)
    }
    
}
