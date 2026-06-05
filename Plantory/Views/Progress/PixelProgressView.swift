import SwiftUI

struct PixelProgressView: View {
    let title: LocalizedStringKey?
    let segmentCount: Int
    let activeColor: Color

    @State private var activeIndex = 0

    init(
        _ title: LocalizedStringKey? = nil,
        segmentCount: Int = 8,
        activeColor: Color = .pixelLeaf
    ) {
        self.title = title
        self.segmentCount = max(segmentCount, 3)
        self.activeColor = activeColor
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                ForEach(0 ..< segmentCount, id: \.self) { index in
                    Rectangle()
                        .fill(fillColor(for: index))
                        .frame(width: 12, height: 18)
                        .overlay {
                            Rectangle()
                                .stroke(Color.pixelInk.opacity(0.48), lineWidth: 2)
                        }
                }
            }
            .padding(8)
            .background {
                PixelRectangleBackground(fill: .pixelCream)
            }

            if let title {
                Text(title)
                    .font(.pixel(.body))
                    .foregroundStyle(Color.pixelInk.opacity(0.68))
                    .multilineTextAlignment(.center)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title ?? "Loading")
        .task {
            await animate()
        }
    }
}

#Preview {
    VStack(spacing: 18) {
        PixelProgressView("Loading CloudKit plants...")
        PixelProgressView("Analyzing photo...", activeColor: .pixelSun)
    }
    .padding()
    .background(.pixelPaper)
}

private extension PixelProgressView {
    func fillColor(for index: Int) -> Color {
        if index == activeIndex {
            return activeColor
        }

        if index == previousIndex {
            return activeColor.opacity(0.58)
        }

        return Color.pixelPaperShadow.opacity(0.26)
    }

    var previousIndex: Int {
        (activeIndex - 1 + segmentCount) % segmentCount
    }

    func animate() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(130))
            activeIndex = (activeIndex + 1) % segmentCount
        }
    }
}
