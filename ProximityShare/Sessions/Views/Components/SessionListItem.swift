//
//  SessionListItem.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import SwiftUI

struct SessionListItem: View {
    
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var session: SharingSession
    
    init(_ session: SharingSession) {
        self.session = session
    }
    
    var latestMessage: String {
        if let lastEvent = session.events.sorted(by: { event1, event2 in
            event1.timestamp < event2.timestamp
        }).last {
            return "\(lastEvent.user!.name): \(lastEvent.content)"
        }
        return ""
    }
    
    var latestTimestamp: String {
        if let lastEvent = session.events.sorted(by: { event1, event2 in
            event1.timestamp < event2.timestamp
        }).last {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let formattedDate = formatter.localizedString(for: lastEvent.timestamp, relativeTo: currentDate)
            return formattedDate == "in 0 seconds" ? "now" : formattedDate
        }
        return ""
    }
    
    @State var currentDate: Date = Date()
    
    var body: some View {
        HStack {

            DisplayPicture(name: session.name, size: 25, font: .subheadline)
            
            VStack(alignment: .leading){
                
                HStack{
                    Text("\(session.name)")
                    if let activeSession = sessionViewModel.activeSession {
                        if session.id == activeSession.id && sessionViewModel.isLeader() && !sessionViewModel.joinRequestUsers.isEmpty {
                            Label("", systemImage: "person.crop.circle.badge.exclamationmark")
                                .foregroundStyle(Color.red)
                        }
                    }
                    Spacer()
                    HStack {
                        Text(latestTimestamp)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                    }
                }
                Text(latestMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
        }
        .onAppear(perform: {
            currentDate = Date()
        })
    }
}

#Preview {
    List {
        SessionListItem(SharingSession(id: "1", name: "Session 1"))
        SessionListItem(SharingSession(id: "2", name: "Session 2"))
    }
    .listStyle(GroupedListStyle())
}
