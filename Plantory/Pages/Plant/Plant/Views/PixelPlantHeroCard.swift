//
//  PixelPlantHeroCard.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelPlantHeroCard: View {
    let plant: Plant

    var body: some View {
        PixelRoundedRectangleCard(fill: .buttonBackground) {
            VStack(spacing: 14) {
                ZStack(alignment: .bottomTrailing) {
                    PixelRectangleCard {
                        plantPhoto
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                    }

                    PixelCareMoodIcon(status: plant.healthStatus)
                        .padding(10)
                }

                HStack(spacing: 10) {
                    PixelMiniStat(
                        title: "Added",
                        value: plant.createdAt.formatted(.dateTime.month(.abbreviated).day()),
                        systemImage: "calendar"
                    )

                    PixelMiniStat(
                        title: "Records",
                        value: "\(plant.records?.count ?? 0)",
                        systemImage: "list.bullet.clipboard"
                    )

                    PixelMiniStat(
                        title: "Issues",
                        value: "\(plant.activeIssues.count)",
                        systemImage: plant.healthStatus.systemImage
                    )
                }
            }
            .padding(4)
        }
    }

}

struct PixelCareMoodIcon: View {
    let status: HealthStatus

    var body: some View {
        PixelTag(systemName: status.systemImage, fill: statusColor)
    }

}

private struct PixelMiniStat: View {
    let title: LocalizedStringKey
    let value: String
    let systemImage: String

    var body: some View {
        PixelRectangleCard {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.black))
                    .foregroundStyle(Color(.pixelLeaf))
                    .frame(height: 20)

                VStack(spacing: 0) {
                    Text(value)
                        .font(.pixel(.title3))
                        .foregroundStyle(Color(.pixelInk))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    Text(title)
                        .font(.pixel(.caption))
                        .foregroundStyle(Color(.pixelInk).opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    PixelPlantHeroCard(plant: .monstera)
        .padding()
}

private extension PixelPlantHeroCard {
    @ViewBuilder
    var plantPhoto: some View {
        if let photoData = plant.photoData,
           let image = Image(data: photoData) {
            image
                .resizable()
                .scaledToFit()
        } else {
            Image(fallbackSpriteName)
                .pixelate()
                .resizable()
                .scaledToFit()
        }
    }

    var fallbackSpriteName: String {
        switch plant.healthStatus {
        case .healthy:
            "PixelMonsteraHealthy"
        case .warning, .critical:
            "PixelSucculentWarning"
        }
    }
}

private extension PixelCareMoodIcon {
    var statusColor: Color {
        switch status {
        case .healthy:
            Color(.pixelLeaf)
        case .warning:
            Color(.pixelSun)
        case .critical:
            Color(.pixelDanger)
        }
    }
}
