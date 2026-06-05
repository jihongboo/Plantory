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
                    .stroke(.white.opacity(0.2), lineWidth: 2)
                    .padding(4)
            }
            .overlay {
                Rectangle()
                    .stroke(.black.opacity(0.6), lineWidth: 4)
            }
    }
}

#Preview {
    PixelRectangleBackground(fill: .cardBackground)
        .padding()
}
