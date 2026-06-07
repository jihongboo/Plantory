//
//  PixelRectangleBackground.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelRectangleBackground: View {
    let fill: Color

    var body: some View {
        Rectangle()
            .fill(fill)
            .overlay {
                Rectangle()
                    .stroke(.pixelInk.opacity(0.4), lineWidth: 3)
                    .padding(3)
            }
            .overlay {
                Rectangle()
                    .stroke(.pixelInk.opacity(0.8), lineWidth: 3)
            }
    }
}

#Preview {
    PixelRectangleBackground(fill: .red)
        .padding()
}
