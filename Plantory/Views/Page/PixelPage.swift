//
//  PixelPage.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelPage<Content: View>: View {
    let backgroundStyle: PixelPageBackground.Style
    @ViewBuilder var content: Content
    
    init(
        backgroundStyle: PixelPageBackground.Style = .secondary,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundStyle = backgroundStyle
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scenePadding(.horizontal)
            .scenePadding(.top)
            .background {
                PixelPageBackground(style: backgroundStyle)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    PixelPage {
        Text("Content")
    }
}
