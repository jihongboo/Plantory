//
//  PixelBottomActionBarModifier.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/6.
//

import SwiftUI

struct PixelNavigationTitleModifier<Trailing: View>: ViewModifier {
    let title: Text
    let subtitle: Text?
    let trailing: Trailing
    
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
        subtitle: Text?,
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
    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil
    ) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
        self.trailing = EmptyView()
    }
    
    init(
        title: Text,
        subtitle: Text? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = EmptyView()
    }
}

extension View {
    func pixelNavigationTitle<Trailing: View>(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
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
    
    func pixelNavigationTitle<Trailing: View>(
        title: LocalizedStringKey,
        subtitle: Text?,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        modifier(
            PixelNavigationTitleModifier(
                title: Text(title),
                subtitle: subtitle,
                trailing: trailing
            )
        )
    }
    
    func pixelNavigationTitle<Trailing: View>(
        title: Text,
        subtitle: Text? = nil,
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
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil
    ) -> some View {
        modifier(
            PixelNavigationTitleModifier(
                title: title,
                subtitle: subtitle
            )
        )
    }
    
    func pixelNavigationTitle(
        title: LocalizedStringKey,
        subtitle: Text?
    ) -> some View {
        modifier(
            PixelNavigationTitleModifier(
                title: Text(title),
                subtitle: subtitle
            )
        )
    }
    
    func pixelNavigationTitle(
        title: Text,
        subtitle: Text? = nil
    ) -> some View {
        modifier(
            PixelNavigationTitleModifier(
                title: title,
                subtitle: subtitle
            )
        )
    }
}
