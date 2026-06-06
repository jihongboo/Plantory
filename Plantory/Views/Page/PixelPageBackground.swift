import SwiftUI

struct PixelPageBackground: View {
    enum Style {
        case primary
        case secondary
        
        var gradient: LinearGradient {
            switch self {
            case .primary:
                LinearGradient(
                    colors: [
                        .black.opacity(0.04),
                        Color(.pixelInk).opacity(0.22),
                        Color(.pixelLeafDark).opacity(0.48)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .secondary:
                LinearGradient(
                    colors: [
                        Color(.pixelLeafDark).opacity(0.72),
                        Color(.pixelLeafDark).opacity(0.9),
                        Color(.pixelInk).opacity(0.88)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
    var style: Style = .primary
    
    var body: some View {
        GeometryReader { geometryProxy in
            Image(.pixelHomeRoom)
                .pixelate()
                .resizable()
                .scaledToFill()
                .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
        }
        .overlay {
            style.gradient
        }
        .ignoresSafeArea()
    }
}

#Preview("Primary") {
    PixelPageBackground()
}

#Preview("Secondary") {
    PixelPageBackground(style: .secondary)
}
