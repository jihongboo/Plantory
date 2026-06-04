//
//  PixelRoundedRectanglePanel.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelRoundedRectangleCard<Content: View>: View {
    let fill: Color
    @ViewBuilder var content: Content
    
    init(
        fill: Color = .cardBackground,
        @ViewBuilder content: () -> Content
    ) {
        self.fill = fill
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background {
                PixelRoundedRectangleBackground(fillColor: fill)
            }
    }
}

#Preview {
    PixelRoundedRectangleCard {
        Text("Content 内容")
            .padding()
            .font(PixelTheme.font(size: 24))
    }
}
