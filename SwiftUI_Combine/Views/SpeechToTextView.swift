//
//  SpeechToTextView.swift
//  SwiftUI_Combine
//
//  Created by Jatin on 06/01/21.
//

import SwiftUI

struct SpeechToTextView: View {
    
    @ObservedObject var viewModel = SCViewModel()
    
    var body: some View {
        VStack {
            HighlightedTextView(highlightedString: viewModel.highlightedString)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            HStack {

                Button(viewModel.recordButtonString) {
                    self.viewModel.startRecording()
                }
                .font(.title)
                .foregroundColor(.white)
                .padding(15)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.blue)
                .cornerRadius(40.0)
                .padding(10)
                
                
                Button("Play") {
                    self.viewModel.play()
                }
                .font(.title)
                .foregroundColor(.white)
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(40.0)
                .padding(10)
                
            }.padding(.bottom, 100)
        }
    }
    
    
}

struct SpeechToTextView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechToTextView()
    }
}
