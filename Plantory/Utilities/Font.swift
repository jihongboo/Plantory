//
//  Font.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

extension Font {
    enum Size {
        case largeTitle
        case title
        case title1
        case title2
        case title3
        case headline
        case body
        case callout
        case subheadline
        case footnote
        case caption
        case caption1
        case caption2
        
        var pointSize: CGFloat {
            switch self {
            case .largeTitle:
                34
            case .title, .title1:
                28
            case .title2:
                22
            case .title3:
                20
            case .headline, .body:
                17
            case .callout:
                16
            case .subheadline:
                15
            case .footnote:
                13
            case .caption, .caption1:
                12
            case .caption2:
                11
            }
        }
        
        var textStyle: Font.TextStyle {
            switch self {
            case .largeTitle:
                .largeTitle
            case .title, .title1:
                .title
            case .title2:
                .title2
            case .title3:
                .title3
            case .headline:
                .headline
            case .body:
                .body
            case .callout:
                .callout
            case .subheadline:
                .subheadline
            case .footnote:
                .footnote
            case .caption, .caption1:
                .caption
            case .caption2:
                .caption2
            }
        }
    }
    
    static func pixel(_ size: Size) -> Font {
        .custom("Fusion-Pixel-10px-Prop-zh_hans-Regular", size: size.pointSize, relativeTo: size.textStyle)
    }
}
