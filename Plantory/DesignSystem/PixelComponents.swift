import SwiftUI

struct PixelPanel<Content: View>: View {
    var fill = Color.green
    var border: Color = Color.black.opacity(0.8)
    var shadow: Color = PixelTheme.ink.opacity(0.24)
    var padding: CGFloat = 14
    @ViewBuilder var content: Content

    var body: some View {
        content
            .font(.title3.bold())
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .padding(.horizontal)
            .frame(minWidth: 100)
            .frame(maxWidth: .infinity)
            .background {
                PixelStepBorder()
                    .fill(fill)
            }
            .overlay {
                PixelTopBorder()
                    .stroke(.white.opacity(0.6), lineWidth: 3)
            }
            .overlay {
                PixelStepBorder()
                    .stroke(border, lineWidth: 3)
            }
    }
    
    struct TopLeftRightBorder: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()

            // top
            path.move(to: CGPoint(x: 3, y: 3))
            path.addLine(to: CGPoint(x: rect.width - 3, y: 3))

            // left
            path.move(to: CGPoint(x: 3, y: 3))
            path.addLine(to: CGPoint(x: 3, y: rect.height))

            // right
            path.move(to: CGPoint(x: rect.width - 3, y: 0))
            path.addLine(to: CGPoint(x: rect.width - 3, y: rect.height))
            return path
        }
    }
    
    struct PixelStepBorder: Shape {
        var step: CGFloat = 4
        var levels: Int = 3

        func path(in rect: CGRect) -> Path {
            let s = step
            let n = CGFloat(levels)

            var p = Path()

            p.move(to: CGPoint(x: s * n, y: 0))

            // top
            p.addLine(to: CGPoint(x: rect.width - s * n, y: 0))

            // top-right: 横、竖、横、竖、横、竖
            for i in 0..<levels {
                let fi = CGFloat(i + 1)
                p.addLine(to: CGPoint(x: rect.width - s * (n - fi), y: s * CGFloat(i)))
                p.addLine(to: CGPoint(x: rect.width - s * (n - fi), y: s * fi))
            }

            // right
            p.addLine(to: CGPoint(x: rect.width, y: rect.height - s * n))

            // bottom-right
            for i in 0..<levels {
                let fi = CGFloat(i + 1)
                p.addLine(to: CGPoint(x: rect.width - s * CGFloat(i), y: rect.height - s * (n - fi)))
                p.addLine(to: CGPoint(x: rect.width - s * fi, y: rect.height - s * (n - fi)))
            }

            // bottom
            p.addLine(to: CGPoint(x: s * n, y: rect.height))

            // bottom-left
            for i in 0..<levels {
                let fi = CGFloat(i + 1)
                p.addLine(to: CGPoint(x: s * (n - fi), y: rect.height - s * CGFloat(i)))
                p.addLine(to: CGPoint(x: s * (n - fi), y: rect.height - s * fi))
            }

            // left
            p.addLine(to: CGPoint(x: 0, y: s * n))

            // top-left
            for i in 0..<levels {
                let fi = CGFloat(i + 1)
                p.addLine(to: CGPoint(x: s * CGFloat(i), y: s * (n - fi)))
                p.addLine(to: CGPoint(x: s * fi, y: s * (n - fi)))
            }

            p.closeSubpath()
            return p
        }
    }
    
    struct PixelTopBorder: Shape {
        var step: CGFloat = 4
        var levels: Int = 3

        func path(in rect: CGRect) -> Path {
            let inset: CGFloat = 3

            let rect = rect.insetBy(
                dx: inset,
                dy: inset
            )

            let s = step
            let n = CGFloat(levels)

            var p = Path()

            // 左下
            p.move(to: CGPoint(
                x: rect.minX,
                y: rect.maxY
            ))

            // left
            p.addLine(to: CGPoint(
                x: rect.minX,
                y: rect.minY + s * n
            ))

            // top-left
            for i in 0..<levels {
                let fi = CGFloat(i + 1)

                p.addLine(to: CGPoint(
                    x: rect.minX + s * CGFloat(i),
                    y: rect.minY + s * (n - fi)
                ))

                p.addLine(to: CGPoint(
                    x: rect.minX + s * fi,
                    y: rect.minY + s * (n - fi)
                ))
            }

            // top
            p.addLine(to: CGPoint(
                x: rect.maxX - s * n,
                y: rect.minY
            ))

            // top-right
            for i in 0..<levels {
                let fi = CGFloat(i + 1)

                p.addLine(to: CGPoint(
                    x: rect.maxX - s * (n - fi),
                    y: rect.minY + s * CGFloat(i)
                ))

                p.addLine(to: CGPoint(
                    x: rect.maxX - s * (n - fi),
                    y: rect.minY + s * fi
                ))
            }

            // right
            p.addLine(to: CGPoint(
                x: rect.maxX,
                y: rect.maxY
            ))

            return p
        }
    }
}

#Preview {
    PixelPanel {
        Text("Haha")
    }
    .padding()
}

struct PixelButtonLabel: View {
    let title: LocalizedStringKey
    let systemImage: String
    var fill: Color = PixelTheme.leaf
    var foreground: Color = .white

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline.weight(.black))
            .labelIconToTitleSpacing(8)
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(fill)
            .clipShape(.rect(cornerRadius: 4))
            .overlay {
                Rectangle()
                    .stroke(PixelTheme.ink.opacity(0.45), lineWidth: 2)
            }
            .shadow(color: PixelTheme.ink.opacity(0.35), radius: 0, y: 4)
    }
}

struct PixelIconButtonLabel: View {
    let systemImage: String
    var fill: Color = PixelTheme.wood
    var foreground: Color = .white

    var body: some View {
        Image(systemName: systemImage)
            .font(.headline.weight(.black))
            .foregroundStyle(foreground)
            .frame(width: 42, height: 42)
            .background(fill)
            .clipShape(.rect(cornerRadius: 5))
            .overlay {
                Rectangle()
                    .stroke(PixelTheme.cream.opacity(0.55), lineWidth: 2)
                    .padding(2)
            }
            .overlay {
                Rectangle()
                    .stroke(PixelTheme.ink.opacity(0.45), lineWidth: 2)
            }
            .shadow(color: PixelTheme.ink.opacity(0.28), radius: 0, y: 3)
    }
}

struct PixelStatusBadge: View {
    let status: HealthStatus

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: status.systemImage)
                .font(.caption.weight(.black))
            Text(status.label)
                .font(.caption.weight(.black))
                .lineLimit(1)
        }
        .foregroundStyle(statusColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(statusColor.opacity(0.14))
        .clipShape(.rect(cornerRadius: 3))
        .overlay {
            Rectangle()
                .stroke(statusColor.opacity(0.55), lineWidth: 1.5)
        }
    }

    private var statusColor: Color {
        switch status {
        case .healthy:
            PixelTheme.leaf
        case .warning:
            PixelTheme.sun
        case .critical:
            PixelTheme.danger
        }
    }
}

struct PixelHomeBackground: View {
    var body: some View {
        Image("PixelHomeRoom")
            .pixelArt()
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .overlay {
                LinearGradient(
                    colors: [
                        .black.opacity(0.04),
                        PixelTheme.ink.opacity(0.22),
                        PixelTheme.leafDark.opacity(0.48)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
    }
}
