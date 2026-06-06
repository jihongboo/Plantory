import SwiftUI

struct NotificationsOverviewCard: View {
    let enabledCount: Int
    let settingsCount: Int
    
    var body: some View {
        PixelRoundedRectangleCard(fill: .buttonBackground) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "bell.badge.fill")
                    .font(.title.weight(.black))
                    .foregroundStyle(.pixelSun)
                    .frame(width: 54, height: 54)
                    .background(.pixelCream, in: .rect(cornerRadius: 5))
                    .overlay {
                        Rectangle()
                            .stroke(Color.pixelInk.opacity(0.62), lineWidth: 3)
                    }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Care Reminders")
                        .font(.pixel(.largeTitle))
                        .foregroundStyle(.white)
                        .shadow(color: .pixelInk, radius: 0, x: 2, y: 2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Set reminders for watering, fertilizing, pest checks, pruning, and repotting.")
                        .font(.pixel(.subheadline))
                        .foregroundStyle(.pixelCream.opacity(0.86))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("\(enabledCount) / \(settingsCount) enabled")
                        .font(.pixel(.headline))
                        .foregroundStyle(.pixelInk)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.pixelSun, in: .rect(cornerRadius: 4))
                        .overlay {
                            Rectangle()
                                .stroke(Color.pixelInk.opacity(0.55), lineWidth: 2)
                        }
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
