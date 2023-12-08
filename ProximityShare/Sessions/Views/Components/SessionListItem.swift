//
//  SessionListItem.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import SwiftUI

struct SessionListItem: View {
    
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
            return formatter.localizedString(for: lastEvent.timestamp, relativeTo: Date())
        }
        return ""
    }
    
    var body: some View {
        HStack {

            DisplayPicture(name: session.name, size: 25, font: .subheadline)
            
            VStack(alignment: .leading){
                
                HStack{
                    Text("\(session.name)")
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
    }
}

#Preview {
    List {
        SessionListItem(SharingSession(id: "1", name: "Session 1"))
        SessionListItem(SharingSession(id: "2", name: "Session 2"))
    }
    .listStyle(GroupedListStyle())
}
