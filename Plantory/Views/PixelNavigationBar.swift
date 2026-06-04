import SwiftUI

struct PixelNavigationBar<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.pixelRectangle)
            
            Text(title)
                .font(.pixel(size: 30, relativeTo: .largeTitle))
                .foregroundStyle(.white)
                .shadow(color: Color(.pixelInk), radius: 0, x: 2, y: 2)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            
            Spacer(minLength: 8)
            
            trailing
        }
    }
}

extension PixelNavigationBar where Trailing == EmptyView {
    init(
        title: String,
        backAction: (() -> Void)? = nil
    ) {
        self.init(title: title) {
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PixelNavigationBar(title: "Diagnosis Result") {
            Button {
                
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.pixelRectangle)
        }
        .background(Color(.pixelLeafDark))
    }
    .padding()
}
