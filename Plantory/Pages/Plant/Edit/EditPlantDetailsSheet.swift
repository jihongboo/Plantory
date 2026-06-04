//
//  EditPlantDetailsSheet.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI
import SwiftData

struct EditPlantDetailsSheet: View {
    let plant: Plant

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var nickname: String
    @State private var note: String

    init(plant: Plant) {
        self.plant = plant
        _nickname = State(initialValue: plant.nickname ?? "")
        _note = State(initialValue: plant.note)
    }

    var body: some View {
        NavigationStack {
            PixelPage {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        PixelNavigationBar(title: "Edit Details")
                        
                        PixelRoundedRectangleCard(
                            title: "Plant Details",
                            systemImage: "square.and.pencil"
                        ) {
                            VStack(alignment: .leading, spacing: 16) {
                                PixelTextField(
                                    title: "Nickname",
                                    prompt: "Nickname",
                                    text: $nickname
                                )
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()

                                PixelTextField(
                                    title: "Note",
                                    prompt: "Add a note about this plant",
                                    text: $note,
                                    axis: .vertical
                                )
                            }
                        }

                        if plant.information?.commonName != nil {
                            PixelRoundedRectangleCard(
                                title: "Plant",
                                systemImage: "leaf.fill"
                            ) {
                                VStack(alignment: .leading, spacing: 16) {
                                    if let commonName = plant.information?.commonName {
                                        PixelInfoRow(title: "Recognized As", value: commonName)
                                    }

                                    if let species = plant.information?.species {
                                        PixelInfoRow(title: "Species", value: species)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .pixelBottomActionBar {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
                .buttonStyle(
                    .pixelRoundedRectangle(
                        fill: .pixelPaperShadow,
                        foreground: .pixelInk,
                        width: .expanded
                    )
                )

                Button("Save", systemImage: "checkmark") {
                    saveChanges()
                }
                .buttonStyle(.pixelRoundedRectangle(width: .expanded))
            }
        }
    }

    private func saveChanges() {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        plant.nickname = trimmedNickname.isEmpty ? nil : trimmedNickname
        plant.note = trimmedNote

        try? modelContext.save()
        dismiss()
    }
}

private struct PixelInfoRow: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.pixel(.headline))
                .foregroundStyle(Color.pixelInk.opacity(0.8))

            Spacer(minLength: 12)

            Text(value)
                .font(.pixel(.title3))
                .foregroundStyle(.pixelInk)
                .multilineTextAlignment(.trailing)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    EditPlantDetailsSheet(plant: .monstera)
}
