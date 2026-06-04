//
//  PixelButton.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

enum PixelButtonWidth {
    case automatic
    case expanded
}

enum PixelButtonSize {
    case large
    case small
    
    var font: Font.Size {
        switch self {
        case .large:
            .title2
        case .small:
            .headline
        }
    }
    
    var padding: CGFloat {
        switch self {
        case .large:
            12
        case .small:
            12
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .large:
            20
        case .small:
            8
        }
    }
}
