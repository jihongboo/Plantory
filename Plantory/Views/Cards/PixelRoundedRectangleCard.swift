//
//  PixelRoundedRectanglePanel.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelRoundedRectangleCard<Content: View>: View {
    let fill: Color
    let title: LocalizedStringKey?
    let systemImage: String?
    @ViewBuilder var content: Content
    
    init(
        fill: Color = .cardBackground,
        @ViewBuilder content: () -> Content
    ) {
        self.fill = fill
        self.title = nil
        self.systemImage = nil
        self.content = content()
    }
    
    init(
        fill: Color = .pixelPaper,
        title: LocalizedStringKey,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.fill = fill
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title, let systemImage {
                PixelRoundedRectangleCardHeader(
                    title: title,
                    systemImage: systemImage
                )
                
                PixelDashedDivider()
            }
            
            content
        }
        .padding()
        .background {
            PixelRoundedRectangleBackground(fillColor: fill)
        }
    }
}

private struct PixelRoundedRectangleCardHeader: View {
    let title: LocalizedStringKey
    let systemImage: String
    
    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.pixel(.title2))
            .foregroundStyle(.pixelInk)
            .labelIconToTitleSpacing(8)
    }
}

#Preview {
    VStack(spacing: 16) {
        PixelRoundedRectangleCard {
            Text("Content 内容")
                .padding()
                .font(.pixel(.title2))
        }
        
        PixelRoundedRectangleCard(
            title: "Plant Details",
            systemImage: "square.and.pencil"
        ) {
            Text("Content 内容")
                .font(.pixel(.title2))
        }
    }
    .padding()
}
