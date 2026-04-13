//
//  DiagnosisCard.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/3/12.
//

import SwiftUI

struct CardView<Content: View>: View {
    let title: Text?
    let subtitle: Text?
    let systemImage: String?
    let iconTint: Color
    @ViewBuilder let content: Content
    
    init(
        @ViewBuilder content: () -> Content
    ) {
        self.title = nil
        self.subtitle = nil
        self.systemImage = nil
        self.iconTint = .accentColor
        self.content = content()
    }

    init(
        titleKey: LocalizedStringKey,
        subtitleKey: LocalizedStringKey? = nil,
        systemImage: String? = nil,
        iconTint: Color = .accentColor,
        @ViewBuilder content: () -> Content
    ) {
        self.title = Text(titleKey)
        self.subtitle = subtitleKey.map { Text($0) }
        self.systemImage = systemImage
        self.iconTint = iconTint
        self.content = content()
    }

    init<S: StringProtocol>(
        _ title: S,
        subtitle: S? = nil,
        systemImage: String? = nil,
        iconTint: Color = .accentColor,
        @ViewBuilder content: () -> Content
    ) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
        self.systemImage = systemImage
        self.iconTint = iconTint
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showsHeader {
                header
                Divider()
            }

            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
    }

    private var showsHeader: Bool {
        title != nil || subtitle != nil || systemImage != nil
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 2) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                if let title {
                    title
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(iconTint)
            
            if let subtitle {
                subtitle
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack {
        CardView("Care Tips", systemImage: "leaf.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Label("Bright indirect light", systemImage: "sun.max.fill")
                Label("Water every 7-10 days", systemImage: "drop.fill")
                Label("Rotate weekly for even growth", systemImage: "arrow.triangle.2.circlepath")
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
        .padding()
        
        CardView("Care Tips", subtitle: "Bright indirect light Bright indirect light Bright indirect light Bright indirect light ", systemImage: "leaf.fill", iconTint: .red) {
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
    .background(.background.secondary)
}
