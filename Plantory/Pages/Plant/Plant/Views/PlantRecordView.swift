import SwiftUI

struct PlantRecordView: View {
    let record: PlantRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: record.type.systemImage)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(record.type.themeColor)
                    .overlay {
                        Rectangle()
                            .stroke(Color(.pixelInk).opacity(0.58), lineWidth: 2)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(record.type.label)
                        .font(.pixel(.title3))
                        .foregroundStyle(Color(.pixelInk))

                    Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.pixel(.footnote))
                        .foregroundStyle(Color(.pixelInk).opacity(0.54))
                }

                Spacer(minLength: 0)
            }

            if !record.note.isEmpty {
                Text(record.note)
                    .font(.pixel(.callout))
                    .foregroundStyle(Color(.pixelInk).opacity(0.76))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let photoData = record.photoData,
               let image = Image(data: photoData) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .padding(6)
                    .background(Color(.pixelCream))
                    .overlay {
                        Rectangle()
                            .stroke(Color(.pixelPaperShadow).opacity(0.72), lineWidth: 2)
                    }
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    PixelRoundedRectangleCard {
        PlantRecordView(
            record: PlantRecord(
                actionType: .watering,
                createdAt: .now.addingTimeInterval(-86_400)
            )
        )
    }
    .padding()
}
