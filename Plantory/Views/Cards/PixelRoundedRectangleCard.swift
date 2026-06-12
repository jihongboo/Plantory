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
    let padding: CGFloat?
    let cornerRadius: CGFloat?
    @ViewBuilder var content: Content
    
    init(
        fill: Color = .pixelPaper,
        title: LocalizedStringKey? = nil,
        systemImage: String? = nil,
        padding: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.fill = fill
        self.title = title
        self.systemImage = systemImage
        self.padding = padding
        self.cornerRadius = cornerRadius
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
        .padding(.all, padding)
        .background {
            PixelRoundedRectangleBackground(
                fill: fill,
                cornerRadius: cornerRadius
            )
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
