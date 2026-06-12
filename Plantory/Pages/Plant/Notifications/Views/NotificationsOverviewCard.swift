import SwiftUI

struct NotificationsOverviewCard: View {
    let enabledCount: Int
    let settingsCount: Int
    
    var body: some View {
        PixelRoundedRectangleCard(fill: .buttonBackground) {
            HStack(alignment: .top, spacing: 14) {
                PixelRectangleCard(fill: .pixelCream) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title.weight(.black))
                        .foregroundStyle(.pixelSun)
                        .frame(width: 54, height: 54)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Care Reminders")
                            .font(.pixel(.largeTitle))
                            .foregroundStyle(.white)
                            .shadow(color: .pixelInk, radius: 0, x: 2, y: 2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.2)
                        
                        PixelRectangleCard(fill: .pixelSun) {
                            Text("\(enabledCount) / \(settingsCount)")
                                .font(.pixel(.headline))
                                .foregroundStyle(.pixelInk)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                        }
                    }
                    
                    Text("Set reminders for watering, fertilizing, pest checks, pruning, and repotting.")
                        .font(.pixel(.subheadline))
                        .foregroundStyle(.pixelCream.opacity(0.86))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    NotificationsOverviewCard(enabledCount: 3, settingsCount: 5)
        .padding()
        .background(.pixelPaper)
}
