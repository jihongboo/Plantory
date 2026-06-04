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

    @ViewBuilder
    private var plantPhoto: some View {
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

    private var fallbackSpriteName: String {
        switch plant.healthStatus {
        case .healthy:
            "PixelMonsteraHealthy"
        case .warning, .critical:
            "PixelSucculentWarning"
        }
    }
}

struct PixelCareMoodIcon: View {
    let status: HealthStatus

    var body: some View {
        PixelTag(systemName: status.systemImage, fill: statusColor)
    }

    private var statusColor: Color {
        switch status {
        case .healthy:
            PixelTheme.leaf
        case .warning:
            PixelTheme.sun
        case .critical:
            PixelTheme.danger
        }
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
                    .foregroundStyle(PixelTheme.leaf)
                    .frame(height: 20)

                VStack(spacing: 0) {
                    Text(value)
                        .font(PixelTheme.font(size: 20, weight: .bold, relativeTo: .headline))
                        .foregroundStyle(PixelTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    Text(title)
                        .font(PixelTheme.font(size: 12, weight: .bold, relativeTo: .caption))
                        .foregroundStyle(PixelTheme.ink.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    PixelPlantHeroCard(plant: PreviewData.healthyPlant)
        .padding()
}
