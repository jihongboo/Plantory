//
//  PixelRoundedRectangleButtonStyle.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelRoundedRectangleButtonStyle: ButtonStyle {
    let size: PixelButtonSize
    let fill: Color
    let foreground: Color
    let width: PixelButtonWidth
    let cornerRadius: CGFloat
    
    init(
        size: PixelButtonSize?,
        fill: Color?,
        foreground: Color?,
        width: PixelButtonWidth?,
        cornerRadius: CGFloat?
    ) {
        self.size = size ?? .large
        self.fill = fill ?? .buttonBackground
        self.foreground = foreground ?? .white
        self.width = width ?? .automatic
        self.cornerRadius = cornerRadius ?? 18
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PixelTheme.font(size: size.fontSize, weight: .bold, relativeTo: .title3))
            .fontWeight(.bold)
            .foregroundStyle(foreground)
            .padding(size.padding)
            .frame(maxWidth: width == .expanded ? .infinity : nil)
            .background {
                PixelRoundedRectangleBackground(fillColor: fill, cornerRadius: cornerRadius)
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
        size: PixelButtonSize? = nil,
        fill: Color? = nil,
        foreground: Color? = nil,
        width: PixelButtonWidth? = nil,
        cornerRadius: CGFloat? = nil
    ) -> PixelRoundedRectangleButtonStyle {
        PixelRoundedRectangleButtonStyle(
            size: size,
            fill: fill,
            foreground: foreground,
            width: width,
            cornerRadius: cornerRadius
        )
    }
}

#Preview {
    Button {
        
    } label: {
        Image(systemName: "chevron.left")
            .frame(width: 40, height: 40)
    }
    .buttonStyle(.pixelRoundedRectangle(size: .small, fill: PixelTheme.wood))

    Button("Button", systemImage: "plus") {
        
    }
    .buttonStyle(.pixelRoundedRectangle(width: .automatic))
    
    Button("Expanded Button") {
        
    }
    .buttonStyle(.pixelRoundedRectangle(width: .expanded))
}
