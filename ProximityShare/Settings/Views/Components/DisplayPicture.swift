//
//  DisplayPicture.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI

struct DisplayPicture: View {
    var name: String
    var size: CGFloat
    var font: Font = .title
    var colors: [Color] = [.red, .green, .blue, .yellow, .orange, .mint, .cyan, .teal, .secondary]
    
    var body: some View {
        Text(name.initials())
            .font(font)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .padding()
            .background(colors.randomElement())
            .clipShape(Circle())
    }
}

#Preview {
    DisplayPicture(name: "John Doe", size: 75)
}
