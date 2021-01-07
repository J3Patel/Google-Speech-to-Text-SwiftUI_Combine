//
//  HighlightedString.swift
//  SwiftUI_Combine
//
//  Created by Jatin on 07/01/21.
//

import Foundation

struct HighlightedString: Equatable {
    let start: String
    let middle: String
    let end: String
    
    init() {
        start = ""
        middle = ""
        end = ""
    }
    
    init(start: String = "", middle: String = "", end: String = "") {
        self.start = start
        self.middle = middle
        self.end = end
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.end == rhs.end && lhs.start == rhs.start && lhs.middle == rhs.middle
    }
}
