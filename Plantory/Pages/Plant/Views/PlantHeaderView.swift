import SwiftUI

struct PlantHeaderView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(plant.displayName)
                    .font(.largeTitle.bold())

                HStack {
                    if let commonName = plant.information?.commonName {
                        Text(commonName)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    if let species = plant.information?.species {
                        Text(species)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }

                Text("Added \(plant.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)

                Text(plant.note)
            }
        }
    }
}
