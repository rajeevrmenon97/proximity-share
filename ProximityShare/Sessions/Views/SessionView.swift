//
//  SessionView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import SwiftUI
import SwiftData
import PhotosUI

struct SessionView: View {
    
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @EnvironmentObject private var preferences: Preferences
    
    @State var messageTextField: String = ""
    @State var showImagePicker = false
    @State private var pickedImage: PhotosPickerItem?
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
                        ItemBubble(event: event, isSelfMessage: preferences.userID == event.user?.id ?? "")
                            .id(event.id)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .onChange(of: session.events.count) {
                    withAnimation {
                        scrollViewReader.scrollTo(events.last?.id)
                    }
                }
                .task {
                    scrollViewReader.scrollTo(events.last?.id)
                }
            }
            
            Spacer()
            
            HStack {
                if let activeSession = sessionViewModel.activeSession {
                    if activeSession.id == session.id {
                        Menu(content: {
                            Button {
                                showImagePicker.toggle()
                            } label: {
                                Label("Photos", systemImage: "photo")
                            }
                        }, label: {
                            Label("", systemImage: "plus")
                                .foregroundStyle(.secondary)
                                .font(.title)
                        })
                        .foregroundStyle(.secondary)
                        TextField("Type your message", text: $messageTextField, axis: .vertical)
                            .frame(maxWidth: .infinity)
                            .padding(6)
                            .overlay{
                                RoundedRectangle(cornerRadius: 10.0)
                                    .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 2.0))
                            }
                            .onSubmit{
                                sendMessage()
                            }
                        Button("", systemImage: "chevron.right.circle") {
                            sendMessage()
                        }
                        .font(.title)
                        .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Disconnected from chat")
                        .font(.caption)
                }
            }
            .padding()
        }
        .photosPicker(isPresented: $showImagePicker, selection: $pickedImage)
        .onChange(of: pickedImage) { _, _ in
            Task {
                if let data = try? await pickedImage?.loadTransferable(type: Data.self) {
                    sessionViewModel.sendImage(data)
                    pickedImage = nil
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    NavigationLink(destination: SessionInfoView(session: session)) {
                        Text(session.name)
                            .foregroundStyle(Color.primary)
                        if let activeSession = sessionViewModel.activeSession {
                            if session.id == activeSession.id && sessionViewModel.isLeader() && !sessionViewModel.joinRequestUsers.isEmpty {
                                Label("Pending invite", systemImage: "person.crop.circle.badge.exclamationmark")
                                    .foregroundStyle(Color.red)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func sendMessage() {
        if !messageTextField.isEmpty {
            sessionViewModel.sendMessage(messageTextField)
            messageTextField = ""
        }
    }
}

#Preview {
    contentViewPreview
}
