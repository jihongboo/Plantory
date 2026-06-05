//
//  PixelRoundedRectangleBackground.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelRoundedRectangleBackground: View {
    let strokeColor: Color
    let fillColor: Color
    let cornerRadius: CGFloat
    let pixelSize: CGFloat
    let lineWidth: CGFloat
    let innerBorderColor: Color
    let innerBorderWidth: CGFloat
    
    init(
        fillColor: Color,
        strokeColor: Color = .black.opacity(0.8),
        cornerRadius: CGFloat = 28,
        pixelSize: CGFloat = 4,
        lineWidth: CGFloat = 4,
        innerBorderColor: Color = .white.opacity(0.6),
        innerBorderWidth: CGFloat = 4
    ) {
        self.cornerRadius = cornerRadius
        self.pixelSize = pixelSize
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        self.innerBorderColor = innerBorderColor
        self.innerBorderWidth = innerBorderWidth
    }

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let outerRadius = min(cornerRadius, min(size.width, size.height) / 2)

            let contentRect = rect.insetBy(dx: lineWidth, dy: lineWidth)
            let contentRadius = max(0, outerRadius - lineWidth)

            let innerCutoutRect = contentRect.insetBy(
                dx: innerBorderWidth,
                dy: innerBorderWidth
            )
            let innerCutoutRadius = max(0, contentRadius - innerBorderWidth)

            let cols = Int(ceil(size.width / pixelSize))
            let rows = Int(ceil(size.height / pixelSize))

            for row in 0..<rows {
                for col in 0..<cols {
                    let cell = CGRect(
                        x: CGFloat(col) * pixelSize,
                        y: CGFloat(row) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )

                    let center = CGPoint(x: cell.midX, y: cell.midY)

                    let inOuter = isInsideRoundedRect(
                        point: center,
                        rect: rect,
                        radius: outerRadius
                    )

                    let inContent = isInsideRoundedRect(
                        point: center,
                        rect: contentRect,
                        radius: contentRadius
                    )

                    let inInnerCutout = isInsideRoundedRect(
                        point: center,
                        rect: innerCutoutRect,
                        radius: innerCutoutRadius
                    )

                    if inContent {
                        context.fill(Path(cell), with: .color(fillColor))
                    } else if inOuter {
                        context.fill(Path(cell), with: .color(strokeColor))
                    }

                    let isInnerBorderBand = inContent && !inInnerCutout

                    // Draw the full inner rounded border band, but remove only
                    // the bottom strip. This keeps the rounded corner pixels.
                    let isBottomStrip = center.y >= contentRect.maxY - innerBorderWidth

                    if isInnerBorderBand && !isBottomStrip {
                        context.fill(Path(cell), with: .color(innerBorderColor))
                    }
                }
            }
        }
    }

}

#Preview {
    PixelRoundedRectangleBackground(fillColor: .buttonBackground)
        .frame(width: 200, height: 100)
        .padding()
}

private extension PixelRoundedRectangleBackground {
    func isInsideRoundedRect(
        point: CGPoint,
        rect: CGRect,
        radius: CGFloat
    ) -> Bool {
        guard rect.contains(point) else { return false }

        let radius = min(radius, min(rect.width, rect.height) / 2)

        let halfWidth = rect.width / 2
        let halfHeight = rect.height / 2

        let dx = abs(point.x - rect.midX) - (halfWidth - radius)
        let dy = abs(point.y - rect.midY) - (halfHeight - radius)

        let clampedX = max(dx, 0)
        let clampedY = max(dy, 0)

        return clampedX * clampedX + clampedY * clampedY <= radius * radius
    }
}
