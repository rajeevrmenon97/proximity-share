//
//  SplashView.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/12/23.
//

import SwiftUI

struct SplashView: View {
    
    var body: some View {
        VStack {
            Spacer()
            Image("Logo")
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
            Text("Proximity Share")
                .font(.largeTitle)
                .bold()
                .padding()
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}

#Preview {
    SplashView()
}
