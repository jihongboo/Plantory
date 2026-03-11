//
//  PlantInfoResultCard.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/3/11.
//

import SwiftUI

struct PlantInfoInformationCard: View {
    let info: PlantInformation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 名称行
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text(info.commonName)
                        .font(.headline)
                    Text(info.species)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            Divider()

            // 养护摘要
            careRow(icon: "sun.max", label: "Light", value: info.light)
            careRow(icon: "drop", label: "Water", value: info.water)
            careRow(icon: "thermometer", label: "Temp", value: info.temperature)
        }
        .padding(.vertical, 4)
    }

    private func careRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}
