//
//  PixelRectangleCard.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelRectangleCard<Content: View>: View {
    let fill: Color
    @ViewBuilder var content: Content
    
    init(
        fill: Color = .pixelCream,
        @ViewBuilder content: () -> Content
    ) {
        self.fill = fill
        self.content = content()
    }
    
    var body: some View {
        content
            .background {
                PixelRectangleBackground(fill: fill)
            }
    }
}

#Preview {
    PixelRectangleCard(fill: .cardBackground) {
        Text("PixelRectangleCard")
            .padding()
    }
}
