//
//  ItemBubble.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/7/23.
//

import SwiftUI

struct ItemBubble: View {
    
    var event: SharingSessionEvent
    var isSelfMessage: Bool
    
    @State var currentDate: Date = Date()
    
    var latestTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let formattedDate = formatter.localizedString(for: event.timestamp, relativeTo: currentDate)
        return formattedDate == "in 0 seconds" ? "now" : formattedDate
    }
    
    var body: some View {
        HStack {
            if isSelfMessage {
                Spacer()
            }
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text(event.user?.name ?? "")
                            .bold()
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    
                    switch event.contentType {
                    case .message:
                        Text(event.content)
                            .padding(.vertical, 0.1)
                    case .image:
                        if let data = event.attachment {
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                ZStack {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        } else {
                            ZStack {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                ProgressView()
                            }
                        }
                        
                    default:
                        EmptyView()
                    }
                    
                    
                    HStack {
                        
                        
                        Spacer()
                        
                        Text(latestTimestamp)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(16)
                .frame(maxWidth: 250, alignment: .leading)
            }
            if !isSelfMessage {
                Spacer()
            }
        }
        .onAppear(perform: {
            currentDate = Date()
        })
    }
}
