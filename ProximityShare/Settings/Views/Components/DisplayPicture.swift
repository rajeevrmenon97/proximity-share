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
    
    var body: some View {
        Text(name.initials())
            .font(font)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .padding()
            .background(Color.secondary)
            .clipShape(Circle())
    }
}

#Preview {
    DisplayPicture(name: "John Doe", size: 75)
}
