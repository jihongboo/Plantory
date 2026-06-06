//
//  PixelBottomActionBarModifier.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/6.
//

import SwiftUI

struct PixelNavigationTitleModifier<Trailing: View>: ViewModifier {
    let title: String
    let subtitle: String?
    let trailing: Trailing
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 8) {
            PixelNavigationBar(title: title, subtitle: subtitle) {
                trailing
            }
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

extension PixelNavigationTitleModifier where Trailing == EmptyView {
    init(title: String,
         subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = EmptyView()
    }
}


extension View {
    func pixelNavigationTitle<Trailing: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        modifier(
            PixelNavigationTitleModifier(
                title: title,
                subtitle: subtitle,
                trailing: trailing
            )
        )
    }
    
    func pixelNavigationTitle(
        title: String,
        subtitle: String? = nil,
    ) -> some View {
        modifier(
            PixelNavigationTitleModifier(
                title: title,
                subtitle: subtitle,
            )
        )
    }
}
