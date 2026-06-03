//
//  PixelPanel.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct Card<Content: View>: View {
    let fill: Color
    let border: Color
    @ViewBuilder var content: Content
    
    init(
        fill: Color = .cardBackground,
        border: Color = .cardBorder,
        @ViewBuilder content: () -> Content
    ) {
        self.fill = fill
        self.border = border
        self.content = content()
    }
    
    var body: some View {
        content
            .background {
                PixelBackground(fill: fill, border: border)
            }
    }
}

#Preview {
    Card {
        Text("Content")
            .padding()
        .font(.custom("Menlo", size: 18))    }
}
