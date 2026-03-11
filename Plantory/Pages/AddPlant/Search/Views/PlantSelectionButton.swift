//
//  PlantSelectionButton.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/3/11.
//

import SwiftUI

struct PlantSelectionButton: View {
    let info: PlantInformation
    @Binding var selection: PlantInformation?

    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button {
            selection = info
            dismiss()
        } label: {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Color.secondary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(info.commonName)
                        .font(.body)
                    Text(info.species)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
