//
//  HomeHeaderView.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI
import SwiftData

struct HomeHeaderView: View {
    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image("PixelDoctorTip")
                .pixelArt()
                .resizable()
                .scaledToFit()
                .frame(width: 62, height: 62)
                .background(PixelTheme.cream, in: .rect(cornerRadius: 5))
                .overlay {
                    Rectangle()
                        .stroke(PixelTheme.wood, lineWidth: 2)
                }
            
            VStack(alignment: .leading, spacing: 0) {
                Text("My Plants")
                    .font(PixelTheme.font(size: 34, weight: .bold, relativeTo: .largeTitle))
                    .foregroundStyle(.white)
                    .shadow(color: PixelTheme.ink, radius: 0, x: 2, y: 2)
                
                Text("\(plants.count) plants")
                    .font(PixelTheme.font(size: 15, weight: .bold, relativeTo: .subheadline))
                    .foregroundStyle(PixelTheme.cream)
                    .shadow(color: PixelTheme.ink, radius: 0, x: 1, y: 1)
            }
            
            Spacer(minLength: 8)
            
#if DEBUG
            NavigationLink(value: HomeDestination.debugNotifications) {
                PixelIconButtonLabel(systemImage: "ladybug")
            }
#endif
        }
    }
}

#Preview {
    HomeHeaderView()
}
