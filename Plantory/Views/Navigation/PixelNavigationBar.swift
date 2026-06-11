import SwiftUI

struct PixelNavigationBar<Trailing: View>: View {
    let title: Text
    let subtitle: Text?
    let trailing: Trailing
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
        self.trailing = trailing()
    }
    
    init(
        title: Text,
        subtitle: Text? = nil,
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
            
            VStack(alignment: .leading, spacing: -6) {
                title
                    .font(.pixel(.title))
                    .foregroundStyle(.white)
                    .shadow(color: Color(.pixelInk), radius: 0, x: 2, y: 2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                if let subtitle {
                    subtitle
                        .font(.pixel(.body))
                        .foregroundStyle(.pixelCream)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
                        
            trailing
        }
        .buttonStyle(.pixelRectangle)
    }
}

extension PixelNavigationBar where Trailing == EmptyView {
    init(title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil) {
        self.init(title: title, subtitle: subtitle) {
            EmptyView()
        }
    }
    
    init(title: Text, subtitle: Text? = nil) {
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
