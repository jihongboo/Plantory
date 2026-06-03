import SwiftUI

struct AddPlantMenuView: View {
    enum Presentation {
        case toolbar
        case actionCard
    }

    let presentation: Presentation

    @State private var imageData: Data?

    init(presentation: Presentation = .toolbar) {
        self.presentation = presentation
    }

    var body: some View {
        switch presentation {
        case .toolbar:
            menuContent
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

        case .actionCard:
            menuContent
                .buttonStyle(.plain)
                .controlSize(.large)
        }
    }

    private var menuContent: some View {
        PlantImageImportMenu { preparedImageData in
            imageData = preparedImageData
        } label: { isPreparingImage in
            switch presentation {
            case .toolbar:
                if isPreparingImage {
                    PixelButtonLabel(title: "Processing...", systemImage: "hourglass", fill: PixelTheme.wood)
                        .symbolEffect(.rotate, options: .speed(0.5))
                } else {
                    PixelButtonLabel(title: "Add Plant", systemImage: "plus")
                }

            case .actionCard:
                HomeActionCardLabel(
                    title: "Identify",
                    subtitle: "Recognize and add plants",
                    systemImage: isPreparingImage ? "hourglass" : "leaf.fill",
                    foregroundStyle: PixelTheme.ink,
                    backgroundStyle: AnyShapeStyle(PixelTheme.leaf),
                    borderStyle: AnyShapeStyle(PixelTheme.leafDark),
                    accessorySystemImage: "camera.macro"
                )
            }
        }
        .compositingGroup()
        .accessibilityLabel("Identify")
        .accessibilityHint("Recognize a plant from a photo and add it to your collection.")
        .sheet(item: $imageData) { imageData in
            AddPlantView(imageData: imageData)
        }
    }
}

struct HomeActionCardLabel: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let systemImage: String
    let foregroundStyle: Color
    let backgroundStyle: AnyShapeStyle
    let borderStyle: AnyShapeStyle
    let accessorySystemImage: String

    var body: some View {
        PixelPanel(fill: .white.opacity(0.88), border: PixelTheme.paperShadow, padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: systemImage)
                        .font(.title3.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(backgroundStyle, in: .rect(cornerRadius: 4))
                        .overlay {
                            Rectangle()
                                .stroke(borderStyle, lineWidth: 2)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title3.weight(.black))
                            .foregroundStyle(foregroundStyle)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(subtitle)
                            .font(.caption.weight(.semibold))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(foregroundStyle.opacity(0.72))
                    }
                }

                HStack {
                    Spacer()
                    Image(systemName: accessorySystemImage)
                        .font(.title.weight(.black))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(PixelTheme.paperShadow.opacity(0.75))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .contentShape(.rect(cornerRadius: 6))
    }
}

#Preview {
    AddPlantMenuView()
}

#Preview("Action Card") {
    AddPlantMenuView(presentation: .actionCard)
        .padding()
}
