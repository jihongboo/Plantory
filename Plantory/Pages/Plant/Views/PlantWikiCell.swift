import SwiftUI

struct PlantWikiCell: View {
    let info: PlantInformation

    var body: some View {
        NavigationLink {
            PlantInformationPage(info: info)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "book.pages.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
                    .frame(width: 44, height: 44)
                    .background(
                        Color.green.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Plant Information")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("View species details, care guide, and background")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            }
        }
    }
}
