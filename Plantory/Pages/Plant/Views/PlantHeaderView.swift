import SwiftUI

struct PlantHeaderView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(plant.displayName)
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    if let information = plant.information {
                        NavigationLink {
                            PlantInformationPage(info: information)
                        } label: {
                            Label("Wiki", systemImage: "chevron.forward")
                                .labelStyle(.iconOnly)
                                .font(.footnote.bold())
                                .tint(.white)
                                .padding(10)
                                .background {
                                    Color.blue
                                        .clipShape(.circle)
                                }
                        }
                    }
                }

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

                if plant.note.isEmpty {
                    Text("No notes yet")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                } else {
                    Text(plant.note)
                        .font(.subheadline)
                }
            }
        }
    }
}
