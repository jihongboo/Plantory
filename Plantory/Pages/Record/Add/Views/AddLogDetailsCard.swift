import SwiftUI

struct AddLogDetailsCard: View {
    @Binding var createdAt: Date
    @Binding var note: String

    var body: some View {
        PixelRoundedRectangleCard(
            title: "Log Detail",
            systemImage: "list.clipboard.fill"
        ) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Time", systemImage: "clock.fill")
                        .font(.pixel(.headline))
                        .foregroundStyle(.pixelInk)

                    DatePicker("Time", selection: $createdAt)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .font(.pixel(.body))
                        .tint(.pixelLeafDark)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            PixelRoundedRectangleBackground(
                                fill: .pixelCream,
                                strokeColor: Color.pixelInk.opacity(0.82),
                                cornerRadius: 12,
                                pixelSize: 4,
                                lineWidth: 3,
                                innerBorderColor: Color.white.opacity(0.44),
                                innerBorderWidth: 3
                            )
                        }
                }

                PixelDashedDivider()

                PixelTextField(
                    "Notes (Optional)",
                    prompt: "Write something about this plant",
                    text: $note,
                    axis: .vertical
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var createdAt = Date.now
    @Previewable @State var note = ""

    AddLogDetailsCard(
        createdAt: $createdAt,
        note: $note
    )
    .padding()
    .background(.pixelPaper)
}
