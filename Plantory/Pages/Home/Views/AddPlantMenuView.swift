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
                    Label("Processing...", systemImage: "hourglass")
                        .symbolEffect(.rotate, options: .speed(0.5))
                } else {
                    Label("Add Plant", systemImage: "plus")
                }

            case .actionCard:
                HomeActionCardLabel(
                    title: "Identify",
                    subtitle: "Recognize and add plants",
                    systemImage: isPreparingImage ? "hourglass" : "leaf.fill",
                    foregroundStyle: .white,
                    backgroundStyle: AnyShapeStyle(.green.gradient),
                    borderStyle: AnyShapeStyle(.clear),
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
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(subtitle)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundStyle(foregroundStyle.opacity(0.72))
        }
        .foregroundStyle(foregroundStyle)
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(backgroundStyle, in: .rect(cornerRadius: 28, style: .continuous))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: accessorySystemImage)
                .font(.system(size: 58, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(foregroundStyle.opacity(0.24))
                .padding()
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(borderStyle, lineWidth: 1.5)
        }
        .contentShape(.rect(cornerRadius: 28, style: .continuous))
        .shadow(radius: 20)
    }
}

#Preview {
    AddPlantMenuView()
}

#Preview("Action Card") {
    AddPlantMenuView(presentation: .actionCard)
        .padding()
}
