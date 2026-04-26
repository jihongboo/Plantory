import SwiftUI

struct PlantPhotoView: View {
    let photoData: Data?

    var body: some View {
        Group {
            if let photoData,
               let image = Image(data: photoData) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(.defaultPlant)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
