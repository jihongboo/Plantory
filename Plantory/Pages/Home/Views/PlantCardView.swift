import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        VStack {
            Rectangle()
                .fill(.clear)
                .frame(height: 100)
            
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.displayName)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                    
                    Text(plant.information?.commonName ?? " ")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay(alignment: .topTrailing) {
                Label(plant.healthStatus.label, systemImage: plant.healthStatus.systemImage)
                    .font(.title)
                    .labelStyle(.iconOnly)
                    .foregroundStyle(statusColor(for: plant.healthStatus))
                    .padding(8)
            }
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
            }
            .shadow(color: .gray.opacity(0.2), radius: 20)
        }
        .overlay(alignment: .top) {
            plantPhoto
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var plantPhoto: some View {
        ZStack {
            if let photoData = plant.photoData,
               let image = Image(data: photoData) {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                Image(.defaultPlant)
                    .resizable()
                    .scaledToFit()
            }
        }
    }

    private func statusColor(for status: HealthStatus) -> Color {
        switch status {
        case .healthy: .green
        case .warning: .orange
        case .critical: .red
        }
    }
}

#Preview {
    HStack {
        PlantCardView(plant: {
            let p = Plant(nickname: "My Monstera", imageData: PlatformImageData.named("Monstera deliciosa"), information: .init(species: "", commonName: "Plant", light: "", water: "", temperature: "", fertilizer: "", tips: ""))
            return p
        }())

        PlantCardView(plant: {
            let p = Plant()
            p.activeIssues = [PlantIssue(type: .underwatered, severity: .moderate)]
            return p
        }())
    }
    .padding()
}
