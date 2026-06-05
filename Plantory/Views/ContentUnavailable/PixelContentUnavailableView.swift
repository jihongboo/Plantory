//
//  PixelContentUnavailableView.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelContentUnavailableView<Icon: View, Actions: View>: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey?
    @ViewBuilder let icon: Icon
    @ViewBuilder let actions: Actions

    init(
        _ title: LocalizedStringKey,
        description: LocalizedStringKey? = nil,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.description = description
        self.icon = icon()
        self.actions = actions()
    }

    var body: some View {
        VStack(spacing: 16) {
            icon

            VStack(spacing: 8) {
                Text(title)
                    .font(.pixel(.title2))
                    .foregroundStyle(.pixelInk)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if let description {
                    Text(description)
                        .font(.pixel(.subheadline))
                        .foregroundStyle(Color.pixelInk.opacity(0.74))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            actions
        }
        .frame(maxWidth: 360)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

extension PixelContentUnavailableView where Icon == PixelContentUnavailableSymbol {
    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        description: LocalizedStringKey? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title,
            description: description
        ) {
            PixelContentUnavailableSymbol(systemImage: systemImage)
        } actions: {
            actions()
        }
    }
}

extension PixelContentUnavailableView where Actions == EmptyView {
    init(
        _ title: LocalizedStringKey,
        description: LocalizedStringKey? = nil,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(
            title,
            description: description,
            icon: icon
        ) {
            EmptyView()
        }
    }
}

extension PixelContentUnavailableView where Icon == PixelContentUnavailableSymbol, Actions == EmptyView {
    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        description: LocalizedStringKey? = nil
    ) {
        self.init(
            title,
            systemImage: systemImage,
            description: description
        ) {
            EmptyView()
        }
    }
}

struct PixelContentUnavailableSymbol: View {
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 34, weight: .black))
            .foregroundStyle(.pixelLeafDark)
            .frame(width: 78, height: 78)
            .background {
                PixelRoundedRectangleBackground(
                    fillColor: .pixelCream,
                    strokeColor: Color.pixelInk.opacity(0.82),
                    cornerRadius: 18,
                    pixelSize: 4,
                    lineWidth: 3,
                    innerBorderColor: Color.white.opacity(0.52),
                    innerBorderWidth: 3
                )
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 20) {
        PixelRoundedRectangleCard {
            PixelContentUnavailableView(
                "Plant Not Found",
                systemImage: "leaf",
                description: "This plant may have been deleted."
            )
        }

        PixelRoundedRectangleCard {
            PixelContentUnavailableView(
                "No Plants Yet",
                description: "Add your first plant and start tracking its growth."
            ) {
                Image(.Plants.monsteraHealthy)
                    .pixelate()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .accessibilityHidden(true)
            } actions: {
                Button("Add Plant", systemImage: "plus") {}
                    .buttonStyle(.pixelRoundedRectangle(size: .small))
            }
        }
    }
    .padding()
}
