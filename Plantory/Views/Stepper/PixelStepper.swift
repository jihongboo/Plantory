import SwiftUI

struct PixelStepper<Label: View>: View {
    @Binding var value: Int
    let bounds: ClosedRange<Int>
    let step: Int
    @ViewBuilder let label: Label
    
    init(
        value: Binding<Int>,
        in bounds: ClosedRange<Int>,
        step: Int = 1,
        @ViewBuilder label: () -> Label
    ) {
        self._value = value
        self.bounds = bounds
        self.step = max(1, step)
        self.label = label()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            label
            
            Spacer(minLength: 8)
            
            HStack(spacing: 8) {
                stepButton(
                    systemImage: "minus",
                    isDisabled: decrementDisabled,
                    fill: .pixelWood
                ) {
                    value = max(bounds.lowerBound, value - step)
                }
                
                Text(value, format: .number)
                    .font(.pixel(.title3))
                    .foregroundStyle(.pixelInk)
                    .contentTransition(.numericText())
                    .frame(minWidth: 20)
                    .animation(.smooth, value: value)
                
                stepButton(
                    systemImage: "plus",
                    isDisabled: incrementDisabled,
                    fill: .pixelLeafDark
                ) {
                    value = min(bounds.upperBound, value + step)
                }
            }
            .fixedSize()
            .overlay {
                Rectangle()
                    .stroke(lineWidth: 4)
            }
        }
    }
}

#Preview {
    @Previewable @State var days = 7
    
    PixelStepper(value: $days, in: 1...30) {
        VStack(alignment: .leading, spacing: 4) {
            Text("Interval")
                .font(.pixel(.headline))
                .foregroundStyle(.pixelInk)
            
            Text("Every \(days) days")
                .font(.pixel(.subheadline))
                .foregroundStyle(Color.pixelInk.opacity(0.66))
        }
    }
    .padding()
    .background(.pixelCream)
}

private extension PixelStepper {
    var decrementDisabled: Bool {
        value <= bounds.lowerBound
    }
    
    var incrementDisabled: Bool {
        value >= bounds.upperBound
    }
    
    func stepButton(
        systemImage: String,
        isDisabled: Bool,
        fill: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.black))
                .foregroundStyle(isDisabled ? Color.pixelInk.opacity(0.42) : .white)
                .frame(width: 16, height: 16)
        }
        .buttonStyle(.pixelRectangle(fill: isDisabled ? .pixelPaperShadow : fill, padding: 8))
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.58 : 1)
    }
}
