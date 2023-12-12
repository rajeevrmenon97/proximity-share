//
//  CustomAlert.swift
//  ProximityShare
//
//  Created by Rajeev R Menon on 12/12/23.
//

import SwiftUI

struct CustomAlertView<Content: View>: View {

    @Environment(\.colorScheme) var colorScheme

    let title: String
    let description: String

    var cancelAction: (() -> Void)?
    var cancelActionTitle: String?

    var primaryAction: (() -> Void)?
    var primaryActionTitle: String?

    var customContent: Content?

    init(title: String,
         description: String,
         cancelAction: (() -> Void)? = nil,
         cancelActionTitle: String? = nil,
         primaryAction: (() -> Void)? = nil,
         primaryActionTitle: String? = nil,
         customContent: Content? = EmptyView()) {
        self.title = title
        self.description = description
        self.cancelAction = cancelAction
        self.cancelActionTitle = cancelActionTitle
        self.primaryAction = primaryAction
        self.primaryActionTitle = primaryActionTitle
        self.customContent = customContent
    }

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .padding(.top)
                    .padding(.bottom, 8)

                Text(description)
                    .font(.system(size: 12, weight: .light, design: .default))
                    .multilineTextAlignment(.center)
                    .padding([.bottom, .trailing, .leading])

                customContent

                Divider()

                HStack {
                    if let cancelAction, let cancelActionTitle {
                        Button { cancelAction() } label: {
                            Text(cancelActionTitle)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        }
                    }

                    if cancelActionTitle != nil && primaryActionTitle != nil {
                        Divider()
                    }

                    if let primaryAction, let primaryActionTitle {
                        Button { primaryAction() } label: {
                            Text("**\(primaryActionTitle)**")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        }
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50, alignment: .center)
            }
            .frame(minWidth: 0, maxWidth: 400, alignment: .center)
            .background(.ultraThickMaterial)
            .cornerRadius(10)
            .padding([.trailing, .leading], 50)
        }
        .zIndex(1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(
            colorScheme == .dark
            ? Color(red: 0, green: 0, blue: 0, opacity: 0.7)
            : Color(red: 1, green: 1, blue: 1, opacity: 0.7)
        )
    }
}
#Preview {
    CustomAlertView(title: "Hello", description: "Hello", cancelAction: {}, cancelActionTitle: "Cancel", primaryAction: {}, primaryActionTitle: "Ok")
}
