import SwiftUI

struct AddPlantRecognitionStatView: View {
    let title: Text
    let value: Text
    
    init(title: LocalizedStringKey, value: String) {
        self.title = Text(title)
        self.value = Text(value)
    }
    
    init(title: LocalizedStringKey, value: LocalizedStringKey) {
        self.title = Text(title)
        self.value = Text(value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            title
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            value
                .font(.headline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    AddPlantRecognitionStatView(title: "Confidence", value: "96%")
        .padding()
}
