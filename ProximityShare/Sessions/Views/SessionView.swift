//
//  SessionView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import SwiftUI
import SwiftData

struct SessionView: View {
    
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @EnvironmentObject private var preferences: Preferences
    
    @State var messageTextField: String = ""
    @Bindable var session: SharingSession
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewReader in
                List {
                    ForEach(session.events.sorted(by: { event1, event2 in
                        event1.timestamp < event2.timestamp
                    }), id: \.id) { event in
                        Text("\(event.user!.name): \(event.content)")
                    }
                }
                .listStyle(.plain)
                .onChange(of: session.events.count) {
                    if let last = session.events.last {
                        withAnimation {
                            scrollViewReader.scrollTo(last.id)
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                if session.isActive {
                    TextField("Type your message", text: $messageTextField)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            if !messageTextField.isEmpty {
                                sessionViewModel.sendMessage(messageTextField, session: session)
                                messageTextField = ""
                            }
                        }
                }
                else {
                    Text("Disconnected from chat")
                        .font(.caption)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(session.name)

    }
}

#Preview {
    contentViewPreview
}
