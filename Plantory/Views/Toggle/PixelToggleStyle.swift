import SwiftUI

struct PixelToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 12) {
                configuration.label
                
                Spacer(minLength: 8)
                
                PixelNotificationToggleIndicator(isOn: configuration.isOn)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension ToggleStyle where Self == PixelToggleStyle {
    static var pixel: PixelToggleStyle {
        PixelToggleStyle()
    }
}

#Preview {
    @Previewable @State var isOn = true
    
    Toggle(isOn: $isOn) {
        Label("Watering Reminder", systemImage: "drop.fill")
            .font(.pixel(.title3))
            .foregroundStyle(.pixelInk)
    }
    .toggleStyle(.pixel)
    .padding()
    .background(.pixelPaper)
}

private struct PixelNotificationToggleIndicator: View {
    let isOn: Bool
    
    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            PixelRectangleBackground(
                fill: isOn ? .pixelLeaf : .pixelPaperShadow,
            )
            
            PixelRectangleBackground(fill: .pixelCream)
                .frame(width: 26, height: 24)
        }
        .frame(width: 58, height: 24)
        .animation(.snappy(duration: 0.15), value: isOn)
    }
}
