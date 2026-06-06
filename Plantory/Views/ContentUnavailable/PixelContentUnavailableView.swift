//
//  PixelContentUnavailableView.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelContentUnavailableView<Actions: View>: View {
    let title: LocalizedStringKey
    let systemImage: String?
    let description: Text?
    let style: Style?
    let actions: Actions
    
    enum Style {
        case plain
        case card
    }

    init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        description: LocalizedStringKey? = nil,
        style: Style? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.systemImage = systemImage
        if let description {
            self.description = Text(description)
        } else {
            self.description = nil
        }
        self.style = style
        self.actions = actions()
    }
    
    @_disfavoredOverload
    init<S: StringProtocol>(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        description: S? = nil,
        style: Style? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.systemImage = systemImage
        if let description {
            self.description = Text(description)
        } else {
            self.description = nil
        }
        self.style = style
        self.actions = actions()
    }
    
    init(
        error: Error,
        style: Style? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            error.title,
            systemImage: error.systemImage,
            description: error.localizedDescription,
            style: style
        ) {
            actions()
        }
    }

    var body: some View {
        switch style {
        case .plain:
            content
        case .card, .none:
            PixelRoundedRectangleCard {
                content
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 16) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 60, weight: .black))
                    .foregroundStyle(.pixelInk)
                    .accessibilityHidden(true)
            }

            VStack(spacing: 0) {
                Text(title)
                    .font(.pixel(.title2))
                    .foregroundStyle(.pixelInk)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if let description {
                    description
                        .font(.pixel(.subheadline))
                        .foregroundStyle(Color.pixelInk.opacity(0.74))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            actions
                .buttonStyle(.pixelRoundedRectangle(size: .small))
        }
        .frame(maxWidth: 360)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .accessibilityElement(children: .combine)
    }
}

extension PixelContentUnavailableView where Actions == EmptyView {
    init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        description: LocalizedStringKey? = nil,
        style: Style? = nil,
    ) {
        self.init(
            title,
            systemImage: systemImage,
            description: description,
            style: style
        ) {
            EmptyView()
        }
    }
    
    @_disfavoredOverload
    init<S: StringProtocol>(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        description: S? = nil,
        style: Style? = nil,
    ) {
        self.init(
            title,
            systemImage: systemImage,
            description: description,
            style: style
        ) {
            EmptyView()
        }
    }
    
    init(
        error: Error,
        style: Style? = nil,
    ) {
        self.init(
            error.title,
            systemImage: error.systemImage,
            description: error.localizedDescription,
            style: style
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        PixelContentUnavailableView(
            "Plant Not Found",
            systemImage: "leaf",
            description: "This plant may have been deleted."
        )

        PixelContentUnavailableView(
            "No Plants Yet",
            description: "Add your first plant and start tracking its growth."
        ){
            Button("Add Plant", systemImage: "plus") {}
        }
    }
    .padding()
}
