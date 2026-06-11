//
//  HomeHeaderView.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI
import SwiftData
import NavigatorUI

struct HomeHeaderView: View {
    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PixelRectangleCard {
                Image("PixelDoctorTip")
                    .pixelate()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 62, height: 62)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text("My Plants")
                    .font(.pixel(.largeTitle))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .foregroundStyle(.white)
                    .shadow(color: Color(.pixelInk), radius: 0, x: 2, y: 2)
                
                Text("\(plants.count) plants")
                    .font(.pixel(.subheadline))
                    .foregroundStyle(Color(.pixelCream))
                    .shadow(color: Color(.pixelInk), radius: 0, x: 1, y: 1)
            }
            
            Spacer(minLength: 8)

            NavigationLink(to: PlantoryDestination.plantInformationLibrary(.normal)) {
                Image(systemName: "book.pages.fill")
                    .font(.body)
            }
            .buttonStyle(.pixelRectangle)
            
#if DEBUG
            NavigationLink(to: PlantoryDestination.debugNotifications) {
                Image(systemName: "ladybug")
                    .font(.body)
            }
            .buttonStyle(.pixelRectangle)
#endif
        }
    }
}

#Preview {
    HomeHeaderView()
        .padding()
        .environment(\.locale, Locale(identifier: "en"))
}
