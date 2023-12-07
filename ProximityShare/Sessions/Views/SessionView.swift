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
    
    var events: [SharingSessionEvent] {
        return session.events.sorted(by: { event1, event2 in
            event1.timestamp < event2.timestamp
        })
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewReader in
                List {
                    ForEach(events) { event in
                        HStack {
                            Text("\(event.user!.name): \(event.content)")
                        }.id(event.id)
                    }
                }
                .listStyle(.plain)
                .onChange(of: session.events.count) {
                    withAnimation {
                        scrollViewReader.scrollTo(events.last!.id)
                    }
                }
                .task {
                    scrollViewReader.scrollTo(events.last!.id)
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
