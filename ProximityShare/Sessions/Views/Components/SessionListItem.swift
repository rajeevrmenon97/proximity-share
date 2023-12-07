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
    
    var body: some View {
        HStack {

            DisplayPicture(name: session.name, size: 25, font: .subheadline)
            
            VStack(alignment: .leading){
                
                HStack{
                    Text("\(session.name)")
                    Spacer()
                    HStack {
                        Text("12:00pm")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                    }
                }
                Text("The last message placeholder")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
