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
                        PixelRoundedRectangleCard(
                            title: "Plant Details",
                            systemImage: "square.and.pencil"
                        ) {
                            VStack(alignment: .leading, spacing: 16) {
                                PixelTextField(
                                    "Nickname",
                                    prompt: "Nickname",
                                    text: $nickname
                                )
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()

                                PixelTextField(
                                    "Note",
                                    prompt: "Add a note about this plant",
                                    text: $note,
                                    axis: .vertical
                                )
                            }
                        }
                    }
                }
                .pixelNavigationTitle(title: "Edit Details")
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

}

#Preview {
    EditPlantDetailsSheet(plant: .monstera)
}

private extension EditPlantDetailsSheet {
    func saveChanges() {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        plant.nickname = trimmedNickname.isEmpty ? nil : trimmedNickname
        plant.note = trimmedNote

        try? modelContext.save()
        dismiss()
    }
}
