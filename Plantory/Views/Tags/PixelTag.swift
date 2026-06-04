//
//  PixelTag.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelTag: View {
    let systemName: String
    let fill: Color
    
    var body: some View {
        PixelRectangleCard(fill: fill) {
            Image(systemName: systemName)
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
    }
}

#Preview {
    PixelTag(systemName: "plus", fill: .buttonBackground)
}
