//
//  DiagnosisCard.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/3/12.
//

import SwiftUI

struct CardView<Content: View>: View {
    let title: String?
    let systemImage: String?
    @ViewBuilder let content: Content

    init(
        title: String? = nil,
        systemImage: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                        .font(.title3.bold())
                } else {
                    Text(title)
                        .font(.title3.bold())
                }
            }

            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
        .shadow(color: .primary.opacity(0.08), radius: 10)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color.green.opacity(0.35),
                Color.mint.opacity(0.2),
                Color.yellow.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        CardView(title: "Care Tips", systemImage: "leaf.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Label("Bright indirect light", systemImage: "sun.max.fill")
                Label("Water every 7-10 days", systemImage: "drop.fill")
                Label("Rotate weekly for even growth", systemImage: "arrow.triangle.2.circlepath")
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
        .padding()
    }
}
