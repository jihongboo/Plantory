//
//  PixelTextField.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelTextField: View {
    let title: LocalizedStringKey
    let prompt: LocalizedStringKey
    @Binding var text: String
    var axis: Axis

    init(
        title: LocalizedStringKey,
        prompt: LocalizedStringKey,
        text: Binding<String>,
        axis: Axis = .horizontal
    ) {
        self.title = title
        self.prompt = prompt
        self._text = text
        self.axis = axis
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.pixel(.headline))
                .foregroundStyle(.pixelInk)

            TextField(prompt, text: $text, axis: axis)
                .textFieldStyle(
                    .pixel(
                        minHeight: axis == .vertical ? 116 : 52,
                        alignment: .topLeading
                    )
                )
        }
    }
}

struct PixelTextFieldStyle: TextFieldStyle {
    let minHeight: CGFloat
    let alignment: Alignment
    let fill: Color
    let stroke: Color
    let cornerRadius: CGFloat

    init(
        minHeight: CGFloat = 52,
        alignment: Alignment = .center,
        fill: Color = .pixelCream,
        stroke: Color = Color.pixelInk.opacity(0.82),
        cornerRadius: CGFloat = 12
    ) {
        self.minHeight = minHeight
        self.alignment = alignment
        self.fill = fill
        self.stroke = stroke
        self.cornerRadius = cornerRadius
    }

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.pixel(.body))
            .foregroundStyle(.pixelInk)
            .tint(.pixelLeafDark)
            .textFieldStyle(.plain)
            .padding(12)
            .frame(minHeight: minHeight, alignment: alignment)
            .background {
                PixelRoundedRectangleBackground(
                    fill: fill,
                    strokeColor: stroke,
                    cornerRadius: cornerRadius,
                    pixelSize: 4,
                    lineWidth: 3,
                    innerBorderColor: Color.white.opacity(0.44),
                    innerBorderWidth: 3
                )
            }
    }
}

extension TextFieldStyle where Self == PixelTextFieldStyle {
    static var pixel: PixelTextFieldStyle {
        pixel()
    }

    static func pixel(
        minHeight: CGFloat = 52,
        alignment: Alignment = .center,
        fill: Color = .pixelCream,
        stroke: Color = Color.pixelInk.opacity(0.82),
        cornerRadius: CGFloat = 12
    ) -> PixelTextFieldStyle {
        PixelTextFieldStyle(
            minHeight: minHeight,
            alignment: alignment,
            fill: fill,
            stroke: stroke,
            cornerRadius: cornerRadius
        )
    }
}

#Preview {
    @Previewable @State var value = ""

    VStack(spacing: 16) {
        PixelTextField(
            title: "Nickname",
            prompt: "Nickname",
            text: $value
        )

        TextField("Styled Only", text: $value)
            .textFieldStyle(.pixel)
    }
    .padding()
    .background(.pixelPaper)
}
