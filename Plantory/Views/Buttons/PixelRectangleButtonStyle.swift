//
//  PixelRectangleButtonStyle.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelRectangleButtonStyle: ButtonStyle {
    var fill: Color = .buttonBackground
    var foreground: Color = .white
    var width: PixelButtonWidth = .automatic
    var padding: CGFloat? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pixel(.title2))
            .foregroundStyle(foreground)
            .padding(.all, padding)
            .frame(maxWidth: width == .expanded ? .infinity : nil)
            .background {
                PixelRectangleBackground(fill: fill)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PixelRectangleButtonStyle {
    static var pixelRectangle: PixelRectangleButtonStyle {
        pixelRectangle()
    }

    static func pixelRectangle(
        fill: Color = .buttonBackground,
        foreground: Color = .white,
        width: PixelButtonWidth = .automatic,
        padding: CGFloat? = nil
    ) -> PixelRectangleButtonStyle {
        PixelRectangleButtonStyle(
            fill: fill,
            foreground: foreground,
            width: width,
            padding: padding
        )
    }
}

#Preview {
    Button("Add", systemImage: "plus") {
        
    }
    .buttonStyle(.pixelRectangle)
    
    Button("Add", systemImage: "plus") {
        
    }
    .buttonStyle(.pixelRectangle(width: .expanded))
}
