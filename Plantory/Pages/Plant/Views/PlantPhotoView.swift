import SwiftUI

struct PlantPhotoView: View {
    let photoData: Data?

    var body: some View {
        ZStack {
            Color.clear
                .aspectRatio(1, contentMode: .fill)
                .overlay {
                    if let photoData,
                       let image = Image(data: photoData) {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: 20)
                    } else {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(
                                LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                            )
                    }
                }
        }
    }
}
