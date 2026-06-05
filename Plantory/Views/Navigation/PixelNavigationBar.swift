import SwiftUI

struct PixelNavigationBar<Trailing: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder var trailing: Trailing
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
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
            
            VStack(alignment: .leading, spacing: -6) {
                Text(title)
                    .font(.pixel(.title))
                    .foregroundStyle(.white)
                    .shadow(color: Color(.pixelInk), radius: 0, x: 2, y: 2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                if let subtitle {
                    Text(subtitle)
                        .font(.pixel(.body))
                        .foregroundStyle(.pixelCream)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
                        
            trailing
        }
    }
}

extension PixelNavigationBar where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil,) {
        self.init(title: title, subtitle: subtitle) {
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PixelNavigationBar(title: "Diagnosis Result")
        PixelNavigationBar(title: "Diagnosis Result", subtitle: "SubTitle")
        PixelNavigationBar(title: "Diagnosis Result") {
            Button {
                
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.pixelRectangle)
        }
    }
    .padding()
    .background(Color(.pixelLeafDark))
}
