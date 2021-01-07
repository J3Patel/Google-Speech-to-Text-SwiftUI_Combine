//
//  HighlightedTextView.swift
//  SwiftUI_Combine
//
//  Created by Jatin on 07/01/21.
//

import SwiftUI

struct HighlightedTextView: View {
    var highlightedString: HighlightedString
    var body: some View {
        Text(highlightedString.start)
            .font(.subheadline)
            +
            Text(highlightedString.middle)
            .font(.title)
            +
            Text(highlightedString.end)
            .font(.subheadline)
    }
}

struct HighlightedTextView_Previews: PreviewProvider {
    static var previews: some View {
        let hs = HighlightedString(start: "My ", middle: "Name", end: " is not")
        HighlightedTextView(highlightedString: hs)
    }
}
