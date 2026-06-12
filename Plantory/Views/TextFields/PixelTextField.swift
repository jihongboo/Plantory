//
//  PixelTextField.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelTextField: View {
    let title: LocalizedStringKey?
    let prompt: LocalizedStringKey
    @Binding var text: String
    var axis: Axis

    init(
        _ title: LocalizedStringKey? = nil,
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
            if let title {
                Text(title)
                    .font(.pixel(.headline))
                    .foregroundStyle(.pixelInk)
            }

            if axis == .vertical {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .font(.pixel(.body))
                        .foregroundStyle(.pixelInk)
                        .tint(.pixelLeafDark)
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .padding(8)

                    if text.isEmpty {
                        Text(prompt)
                            .font(.pixel(.body))
                            .foregroundStyle(Color.pixelInk.opacity(0.36))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                            .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
                .background {
                    PixelTextInputBackground()
                }
            } else {
                TextField(prompt, text: $text, axis: axis)
                    .textFieldStyle(
                        .pixel(
                            minHeight: 52,
                            alignment: .topLeading
                        )
                    )
            }
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
                PixelTextInputBackground(
                    fill: fill,
                    stroke: stroke,
                    cornerRadius: cornerRadius
                )
            }
    }
}

private struct PixelTextInputBackground: View {
    var fill: Color = .pixelCream
    var stroke: Color = Color.pixelInk.opacity(0.82)
    var cornerRadius: CGFloat = 12

    var body: some View {
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
            "Nickname",
            prompt: "Nickname",
            text: $value
        )

        TextField("Styled Only", text: $value)
            .textFieldStyle(.pixel)

        PixelTextField(
            "Notes",
            prompt: "Optional care notes",
            text: $value,
            axis: .vertical
        )
    }
    .padding()
    .background(.pixelPaper)
}
