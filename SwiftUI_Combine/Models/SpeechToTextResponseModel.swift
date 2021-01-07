//
//  SpeechToTextResponseModel.swift
//  SwiftUI_Combine
//
//  Created by Jatin on 06/01/21.
//

import Foundation

// MARK: - Response
struct SpeechToTextResponseModel: Codable {
    let results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let alternatives: [Alternative]
}

// MARK: - Alternative
struct Alternative: Codable {
    let transcript: String
    let confidence: Double
    let words: [Word]?
}

// MARK: - Word
struct Word: Codable {
    let startTime, endTime, word: String
}
