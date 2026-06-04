import SwiftUI

enum PixelTheme {
    enum FontWeight {
        case regular
        case medium
        case semibold
        case bold
        
        fileprivate var postScriptName: String {
            "Fusion-Pixel-10px-Prop-zh_hans-Regular"
        }
    }
    
    static let ink = Color(red: 0.16, green: 0.10, blue: 0.04)
    static let cream = Color(red: 0.98, green: 0.91, blue: 0.76)
    static let paper = Color(red: 1.00, green: 0.95, blue: 0.84)
    static let paperShadow = Color(red: 0.73, green: 0.58, blue: 0.36)
    static let leaf = Color(red: 0.28, green: 0.62, blue: 0.13)
    static let leafDark = Color(red: 0.11, green: 0.31, blue: 0.12)
    static let wood = Color(red: 0.46, green: 0.27, blue: 0.12)
    static let water = Color(red: 0.24, green: 0.56, blue: 0.84)
    static let sun = Color(red: 0.95, green: 0.62, blue: 0.12)
    static let danger = Color(red: 0.78, green: 0.22, blue: 0.16)
    
    static func font(
        size: CGFloat,
        weight: FontWeight = .regular,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> Font {
        .custom(weight.postScriptName, size: size, relativeTo: textStyle)
    }
}
