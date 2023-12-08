//
//  DisplayPicture.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/6/23.
//

import SwiftUI

extension String {
    func initials() -> String {
        let words = self.components(separatedBy: " ")
        var initials = words.compactMap { $0.first }.map { String($0) }.joined()
        if initials.count > 2 {
            initials = String(initials.first!) + String(initials.last!)
        }
        return initials.uppercased()
    }
}

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
