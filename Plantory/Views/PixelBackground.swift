//
//  PixelBackground.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PixelBackground: View {
    let fill: Color
    let border: Color
    
    init(fill: Color = .cardBackground, border: Color = .cardBorder) {
        self.fill = fill
        self.border = border
    }
    
    var body: some View {
        Background()
            .fill(fill)
            .overlay {
                Highlight()
                    .stroke(.white.opacity(0.6), lineWidth: 3)
            }
            .overlay {
                Background()
                    .stroke(border, lineWidth: 3)
            }
    }
}

private extension PixelBackground {
    private struct Background: Shape {
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
    
    private struct Highlight: Shape {
        let step: CGFloat
        let levels: Int
        let inset: CGFloat
        
        init(step: CGFloat = 4, levels: Int = 3, inset: CGFloat = 3) {
            self.step = step
            self.levels = levels
            self.inset = inset
        }

        func path(in rect: CGRect) -> Path {
            
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
    PixelBackground()
        .padding()
}
