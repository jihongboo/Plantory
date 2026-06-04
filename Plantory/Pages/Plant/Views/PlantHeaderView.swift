import SwiftUI

struct PlantHeaderView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(plant.displayName)
                        .font(PixelTheme.font(size: 28, weight: .bold, relativeTo: .title))
                        .foregroundStyle(PixelTheme.ink)
                        .lineLimit(2)

                    if let commonName = plant.information?.commonName {
                        Text(commonName)
                            .font(PixelTheme.font(size: 18, weight: .bold, relativeTo: .headline))
                            .foregroundStyle(PixelTheme.leaf)
                    }

                    if let species = plant.information?.species {
                        Text(species)
                            .font(PixelTheme.font(size: 15, relativeTo: .subheadline))
                            .foregroundStyle(PixelTheme.ink.opacity(0.58))
                            .italic()
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: 8)

                if let information = plant.information {
                    NavigationLink {
                        PlantInformationPage(info: information)
                    } label: {
                        Image(systemName: "book.pages.fill")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                            .frame(width: 42, height: 42)
                            .background(PixelTheme.leaf)
                            .overlay {
                                Rectangle()
                                    .stroke(.white.opacity(0.55), lineWidth: 2)
                                    .padding(3)
                            }
                            .overlay {
                                Rectangle()
                                    .stroke(PixelTheme.ink.opacity(0.65), lineWidth: 3)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption.weight(.black))
                    .foregroundStyle(PixelTheme.paperShadow)

                Text("Added \(plant.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(PixelTheme.font(size: 15, weight: .bold, relativeTo: .footnote))
                    .foregroundStyle(PixelTheme.ink.opacity(0.62))
            }

            Text(plant.note.isEmpty ? String(localized: "No notes yet") : plant.note)
                .font(PixelTheme.font(size: 17, relativeTo: .body))
                .foregroundStyle(PixelTheme.ink.opacity(plant.note.isEmpty ? 0.48 : 0.82))
                .fixedSize(horizontal: false, vertical: true)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(PixelTheme.cream, in: .rect(cornerRadius: 4))
                .overlay {
                    Rectangle()
                        .stroke(PixelTheme.paperShadow.opacity(0.62), lineWidth: 2)
                }
        }
    }
}
