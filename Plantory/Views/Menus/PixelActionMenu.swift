//
//  PixelActionMenu.swift
//  Plantory
//
//  Created by Codex on 2026/6/7.
//

import SwiftUI

struct PixelActionMenuItem<ID: Hashable>: Identifiable {
    let id: ID
    let title: LocalizedStringKey
    let systemImage: String
    let tint: Color

    init(
        id: ID,
        title: LocalizedStringKey,
        systemImage: String,
        tint: Color = .pixelLeaf
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
    }
}

struct PixelActionMenu<ID: Hashable>: View {
    let title: LocalizedStringKey
    let systemImage: String
    let items: [PixelActionMenuItem<ID>]
    let action: (ID) -> Void

    @State private var isExpanded = false

    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        items: [PixelActionMenuItem<ID>],
        action: @escaping (ID) -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.items = items
        self.action = action
    }

    var body: some View {
        triggerButton
            .popover(
                isPresented: $isExpanded,
                attachmentAnchor: .rect(.bounds),
                arrowEdge: .bottom
            ) {
                actionPanel
                    .padding(4)
                    .presentationCompactAdaptation(.popover)
                    .presentationBackground(.pixelPaper)
        }
    }
}

#Preview {
    PixelPage {
        Color.clear
            .pixelBottomActionBar {
                Button("Add Log", systemImage: "camera.fill") {
                }

                PixelActionMenu(
                    "Actions",
                    systemImage: "plus.circle.fill",
                    items: [
                        .init(id: "water", title: "Watering", systemImage: "drop.fill", tint: .pixelWater),
                        .init(id: "feed", title: "Fertilizing", systemImage: "leaf.fill", tint: .pixelLeaf),
                        .init(id: "trim", title: "Pruning", systemImage: "scissors", tint: .pixelWood)
                    ]
                ) { _ in
                }
            }
    }
}

private extension PixelActionMenu {
    var triggerButton: some View {
        Button {
            withAnimation(.snappy(duration: 0.18)) {
                isExpanded.toggle()
            }
        } label: {
            Label(title, systemImage: systemImage)
        }
        .accessibilityHint(isExpanded ? "Close actions" : "Show actions")
    }

    var actionPanel: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                actionRow(item)

                if index < items.count - 1 {
                    PixelDashedDivider()
                        .padding(.horizontal, 6)
                }
            }
        }
        .padding(10)
        .frame(width: 240)
    }

    func actionRow(_ item: PixelActionMenuItem<ID>) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.14)) {
                isExpanded = false
            }

            action(item.id)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item.systemImage)
                    .font(.pixel(.headline))
                    .foregroundStyle(item.tint)
                    .frame(width: 28, height: 28)
                    .background {
                        PixelRectangleBackground(fill: .pixelCream)
                    }

                Text(item.title)
                    .font(.pixel(.headline))
                    .foregroundStyle(.pixelInk)

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
