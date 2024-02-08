//
//  ContentView.swift
//  InterviewPractice
//
//  Created by Luke Thompson on 8/2/2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var gptManager = GPTManager()
    @State var input = ""
    
    var body: some View {
        VStack {
            // Scroll View to display messages in the style of a messenger conversation
            ScrollView {
                ForEach(gptManager.conversationHistory) { message in
                    HStack (alignment: .top) {
                        if message.sender == "Interviewer" {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        }
                        
                        Text(message.content)
                            .frame(maxWidth: 300, alignment: message.sender == "Interviewer" ? .leading : .trailing)
                            .padding()
                            .background(message.sender == "Interviewer" ? Color.gray.opacity(0.2) : Color.blue.opacity(0.6))
                            .cornerRadius(9)
                        
                        if message.sender != "Interviewer" {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .foregroundColor(Color.blue.opacity(0.6))
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            
            Spacer()
            HStack {
                TextField("Type your response here", text: $input)
                    .textFieldStyle(.roundedBorder)
                Button(action: {
                    gptManager.conversationHistory.append(Message(sender: "user", content: input))
                    input = ""
                    gptManager.getQuestion() { _ in}
                }) {
                    Text("Send")
                        .padding(8)
                        .cornerRadius(10)
                        .background(.blue)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            gptManager.getQuestion{ result in
                
            }
        }
    }


    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
