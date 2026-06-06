import SwiftUI

struct PixelProgressMeter: View {
    enum Style {
        case fixed
        case colorful
    }

    let activeSegments: Set<Int>
    let totalSegments: Int
    let style: Style
    let accessibilityLabel: LocalizedStringKey

    init(
        value: Int,
        totalSegments: Int = 3,
        style: Style = .fixed,
        accessibilityLabel: LocalizedStringKey = "Progress"
    ) {
        self.totalSegments = max(totalSegments, 1)
        self.style = style
        self.accessibilityLabel = accessibilityLabel

        let clampedValue = min(max(value, 0), self.totalSegments)
        activeSegments = clampedValue > 0 ? Set(1 ... clampedValue) : []
    }

    init(
        activeSegments: Set<Int>,
        totalSegments: Int = 3,
        style: Style = .colorful,
        accessibilityLabel: LocalizedStringKey = "Progress"
    ) {
        self.activeSegments = activeSegments
        self.totalSegments = max(totalSegments, 1)
        self.style = style
        self.accessibilityLabel = accessibilityLabel
    }
    
    init(indicator: PixelCareIndicator) {
        switch indicator {
        case let .level(level):
            self.init(value: level,
                      style: .fixed,
                      accessibilityLabel: "Level \(level) of 3")
        case let .temperature(activeBands):
            self.init(activeSegments: activeBands.pixelMeterSegments,
                      style: .colorful,
                      accessibilityLabel: "Temperature range")
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            ForEach(1 ... totalSegments, id: \.self) { segment in
                Rectangle()
                    .fill(fillColor(for: segment))
                    .frame(height: 8)
                    .overlay {
                        Rectangle()
                            .stroke(.pixelInk.opacity(0.38), lineWidth: 1)
                    }
            }
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    VStack(spacing: 16) {
        PixelProgressMeter(value: 2, accessibilityLabel: "Level 2 of 3")
        PixelProgressMeter(activeSegments: [1, 2], accessibilityLabel: "Temperature range")
    }
    .padding()
    .background(.pixelPaper)
}

private extension PixelProgressMeter {
    func fillColor(for segment: Int) -> Color {
        guard activeSegments.contains(segment) else {
            return .pixelPaperShadow.opacity(0.22)
        }

        switch style {
        case .fixed:
            return .pixelLeaf
        case .colorful:
            return colorfulColor(for: segment)
        }
    }

    func colorfulColor(for segment: Int) -> Color {
        switch segment {
        case 1:
            .pixelWater
        case 2:
            .pixelLeaf
        case 3:
            .pixelDanger
        default:
            .pixelSun
        }
    }
}
