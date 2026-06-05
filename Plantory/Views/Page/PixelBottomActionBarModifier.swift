import SwiftUI

struct PixelBottomActionBarModifier<Buttons: View>: ViewModifier {
    let fill: Color
    let spacing: CGFloat
    let buttons: Buttons

    init(
        fill: Color = Color(.pixelWood),
        spacing: CGFloat = 12,
        @ViewBuilder buttons: () -> Buttons
    ) {
        self.fill = fill
        self.spacing = spacing
        self.buttons = buttons()
    }

    func body(content: Content) -> some View {
        content
            .safeAreaBar(edge: .bottom, spacing: 0) {
                HStack(spacing: spacing) {
                    buttons
                }
                .padding(.horizontal)
                .padding(.top)
                .background {
                    PixelRoundedRectangleBackground(fill: fill)
                        .ignoresSafeArea()
                }
            }
    }
}

extension View {
    func pixelBottomActionBar<Buttons: View>(
        fill: Color = Color(.pixelWood),
        spacing: CGFloat = 12,
        @ViewBuilder buttons: () -> Buttons
    ) -> some View {
        modifier(
            PixelBottomActionBarModifier(
                fill: fill,
                spacing: spacing,
                buttons: buttons
            )
        )
    }
}

#Preview {
    Color.clear
        .pixelBottomActionBar {
            Button("Button") {
                
            }
            .buttonStyle(.pixelRoundedRectangle(width: .expanded))
        }
}
