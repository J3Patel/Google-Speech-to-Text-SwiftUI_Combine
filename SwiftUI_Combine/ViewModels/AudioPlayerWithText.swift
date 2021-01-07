//
//  AudioPlayer.swift
//  SwiftUI_Combine
//
//  Created by Jatin on 06/01/21.
//

import Foundation
import AVFoundation
import Combine

final class AudioPlayerWithText: NSObject {
    
    
    var highlightedString: AnyPublisher<HighlightedString, Never> {
        return highlightedStringSubject.eraseToAnyPublisher()
    }
    
    private var player: AVPlayer!
    private var recordingSession: AVAudioSession!
    private var subscribers = Set<AnyCancellable>()
    private let url: URL
    private let speechToTextData: Alternative
    private let highlightedStringSubject = PassthroughSubject<HighlightedString, Never>()
    private let playerTimeIntervalPublisher = PassthroughSubject<TimeInterval, Never>()
    private var timeObservation: Any?
    private var indexArray: [(start: String.Index,end: String.Index)] = []
    private var timeStamps: [Double] = []
    
    init(url: URL, speechToTextData: Alternative) {
        self.url = url
        self.speechToTextData = speechToTextData
        super.init()
        var tempString = ""
        if let words = speechToTextData.words {
            for word in words {
                let start = tempString.endIndex
                tempString += word.word + " "
                indexArray.append((start,
                                   tempString.index(start,
                                                    offsetBy: word.word.count)))
                var startTimeString = word.startTime
                startTimeString.removeLast() // removing 's' character from timestamp
                if let startTime = Double(startTimeString) {
                    timeStamps.append(startTime)
                }
            }
            timeStamps.append(Double.infinity)
        }

        playerTimeIntervalPublisher.sink { [weak self] value in
            self?.setupForTime(time: value)
        }
        .store(in: &subscribers)
    }
    
    private func setupForTime(time: Double) {
        let time = Double(round(1000*time)/1000)
        var i = 0
        while i < timeStamps.count - 1 {
            if timeStamps[i] <= time && time <= timeStamps[i + 1] {
                let origionalString = speechToTextData.transcript
                let middleString = origionalString[indexArray[i].0..<indexArray[i].1]
                let startString = origionalString[origionalString.startIndex..<indexArray[i].0]
                let endString = origionalString[indexArray[i].1..<origionalString.endIndex]
                
                let t = HighlightedString(start: String(startString), middle: String(middleString), end: String(endString))
                highlightedStringSubject.send(t)
                break
            }
            i += 1
        }
        
        
    }
    
    func play() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playback, mode: .default)
            try recordingSession.setActive(true)
            player = AVPlayer(url: url)
            player.volume = 1.0
            player.play()
            
            timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 200),
                                                             queue: nil) { [weak self] time in
                self?.playerTimeIntervalPublisher.send(time.seconds)
            }
        } catch {
            print("errror")
        }
    }
    
    func stop() {
        player.pause()
    }
}
