//
//  PixelRoundedRectangleButtonStyle.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

enum PixelButtonWidth {
    case automatic
    case expanded
}

struct PixelRoundedRectangleButtonStyle: ButtonStyle {
    var fill: Color = .buttonBackground
    var foreground: Color = .white
    var width: PixelButtonWidth = .automatic

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PixelTheme.font(size: 24, weight: .bold, relativeTo: .title3))
            .foregroundStyle(foreground)
            .padding(.vertical, 14)
            .padding(.horizontal, 32)
            .frame(maxWidth: width == .expanded ? .infinity : nil)
            .background {
                PixelBackground(fillColor: fill, cornerRadius: 18)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PixelRoundedRectangleButtonStyle {
    static var pixelRoundedRectangle: PixelRoundedRectangleButtonStyle {
        pixelRoundedRectangle()
    }
    
    static func pixelRoundedRectangle(
        fill: Color = .buttonBackground,
        foreground: Color = .white,
        width: PixelButtonWidth = .expanded
    ) -> PixelRoundedRectangleButtonStyle {
        PixelRoundedRectangleButtonStyle(
            fill: fill,
            foreground: foreground,
            width: width
        )
    }
}

#Preview {
    Button("Button") {
        
    }
    .buttonStyle(.pixelRoundedRectangle(width: .automatic))
    
    Button("Expanded Button") {
        
    }
    .buttonStyle(.pixelRoundedRectangle(width: .expanded))
}
