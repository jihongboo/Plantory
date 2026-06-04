//
//  PixelSheetDashedDivider.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelDashedDivider: View {
    private let color: Color
    private let lineWidth: CGFloat
    private let dashLength: CGFloat
    private let gapLength: CGFloat

    init(
        color: Color = Color(.pixelPaperShadow).opacity(0.42),
        lineWidth: CGFloat = 3,
        dashLength: CGFloat = 8,
        gapLength: CGFloat = 4
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.dashLength = dashLength
        self.gapLength = gapLength
    }

    var body: some View {
        PixelSheetDashedLine()
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .butt,
                    dash: [dashLength, gapLength]
                )
            )
            .frame(height: lineWidth)
            .accessibilityHidden(true)
    }
}

private struct PixelSheetDashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview {
    VStack {
        PixelDashedDivider()
        PixelDashedDivider(
            color: Color(.pixelLeaf).opacity(0.7),
            lineWidth: 3,
            dashLength: 8,
            gapLength: 4
        )
    }
    .padding()
}
