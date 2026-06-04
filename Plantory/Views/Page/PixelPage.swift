//
//  PixelPage.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelPage<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scenePadding(.horizontal)
            .scenePadding(.top)
            .background {
                PixelPageBackground(style: .secondary)
            }
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    PixelPage {
        Text("Content")
    }
}
