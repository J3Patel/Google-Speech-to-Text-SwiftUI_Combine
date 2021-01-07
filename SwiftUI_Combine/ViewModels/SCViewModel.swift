//
//  SCViewModel.swift
//  SwiftUI_Combine
//
//  Created by Jatin on 05/01/21.
//

import Foundation
import Combine
import SwiftUI

final class SCViewModel: ObservableObject {

    @Published private var speechToTextSubject: SpeechToTextResponseModel?
    @Published var recordButtonString: String = "Record"
    @Published var highlightedString = HighlightedString()
    
    private var currentRecordingURL: URL?
    private var player: AudioPlayerWithText?
    private let recorder = AudioRecorder()
    private var subscribers = Set<AnyCancellable>()
    
    func startRecording() {
        recorder.recordOrStop()
    }
    
    private func speechToText(from url: URL) -> AnyPublisher<SpeechToTextResponseModel, Error> {
        return Publishers
            .SpeechToTextPublisher(audioURL: url)
            .eraseToAnyPublisher()
    }
    
    init() {
        recorder.permission.sink { (permission) in
            if permission == .denied {
                // TODO: Show Alert
                print("permission denied")
            }
        }.store(in: &subscribers)
        
        recorder.audioURL
            .mapError({ $0 as Error })
            .flatMap ({ url -> AnyPublisher<SpeechToTextResponseModel, Error> in
                self.currentRecordingURL = url
                return self.speechToText(from : url)
            })
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                print(completion)
            } receiveValue: { [weak self] (data) in
                self?.speechToTextSubject = data
                if let text = data.results.first?.alternatives.first?.transcript {
                    self?.highlightedString = HighlightedString(start: text)
                }
            }
            .store(in: &subscribers)
        
        recorder.state
            .map({$0 ? "Stop" : "Record"})
            .assign(to: \.recordButtonString, on: self)
            .store(in: &subscribers)
    }
    
    func play() {
        guard let firstAlternative = speechToTextSubject?.results.first?.alternatives.first, let url = currentRecordingURL else {
            return
        }
        player = AudioPlayerWithText(url: url, speechToTextData: firstAlternative)
        player?.highlightedString
            .receive(on: DispatchQueue.main)
            .removeDuplicates(by: {$0 == $1})
            .sink(receiveValue: { (string) in
            self.highlightedString = string
        }).store(in: &subscribers)
        player?.play()
 
    }
}
