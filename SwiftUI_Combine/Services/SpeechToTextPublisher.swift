//
//  SpeechToTextService.swift
//  SwiftUI_Combine
//
//  Created by Jatin on 06/01/21.
//

import Foundation
import Combine

enum HTTPError: LocalizedError {
    case statusCode
}
let API_KEY = "ADD API KEY HERE"



extension Publishers {
    
    class SpeechToTextSubscription<S: Subscriber>: Subscription where S.Input == SpeechToTextResponseModel,
                                                                      S.Failure == Error {
        private let session = URLSession.shared
        private let audioURL: URL
        private var subscriber: S?
        
        init(audioURL: URL, subscriber: S) {
            self.audioURL = audioURL
            self.subscriber = subscriber
            sendRequest()
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() {
            subscriber = nil
        }
        
        //TODO: - Can use pods instead
        private func sendRequest() {
            guard let subscriber = subscriber else { return }
            var service = "https://speech.googleapis.com/v1/speech:recognize"
            service += "?key="
            service += API_KEY
            
            guard let data = try? Data(contentsOf: audioURL) else {
                return
            }
            
            
            let configRequest: [String : Any] = ["encoding":"LINEAR16",
                                                 "sampleRateHertz": 16000,
                                                 "languageCode":"en-US",
                                                 "maxAlternatives":30,
                                                 "enableWordTimeOffsets": true]
            let audioRequest = ["content": data.base64EncodedString()]
            
            let requestDictionary = ["config": configRequest,
                                     "audio": audioRequest]
            
            guard let requestData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .sortedKeys) else {
                return
            }
            
            let url = URL(string: service)!
            
            var request = URLRequest(url: url)
            request.addValue(Bundle.main.bundleIdentifier ?? "",
                             forHTTPHeaderField: "X-Ios-Bundle-Identifier")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            request.httpMethod = "POST"
            
            session.dataTaskPublisher(for: request)
                .tryMap { output -> Data in
                    guard let response = output.response as? HTTPURLResponse,
                          response.statusCode == 200 else {
                        throw HTTPError.statusCode
                    }
                    return output.data
                }
                .decode(type: SpeechToTextResponseModel.self, decoder: JSONDecoder())
                .subscribe(subscriber)
        }
        
    }
    
    
    struct SpeechToTextPublisher: Publisher {
        
        typealias Output = SpeechToTextResponseModel
        typealias Failure = Error
        
        private let audioURL: URL
        
        init(audioURL: URL) {
            self.audioURL = audioURL
        }
        
        func receive<S>(subscriber: S) where S : Subscriber,
                                             Self.Failure == S.Failure,
                                             Self.Output == S.Input {
            let subscription = SpeechToTextSubscription(audioURL: audioURL,
                                                        subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}
