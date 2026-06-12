import CloudKit
import SwiftUI

struct CKAssetImage<Content: View, Placeholder: View>: View {
    let id: String
    let recordType: CKRecord.RecordType
    let lookupField: CKRecord.FieldKey
    let lookupValue: String
    let assetField: CKRecord.FieldKey
    let cachedData: Data?
    let cacheData: (Data) throws -> Void
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var loadedData: Data?

    init(
        id: String,
        recordType: CKRecord.RecordType,
        lookupField: CKRecord.FieldKey,
        lookupValue: String,
        assetField: CKRecord.FieldKey,
        cachedData: Data?,
        cacheData: @escaping (Data) throws -> Void,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.id = id
        self.recordType = recordType
        self.lookupField = lookupField
        self.lookupValue = lookupValue
        self.assetField = assetField
        self.cachedData = cachedData
        self.cacheData = cacheData
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image {
                content(image)
            } else {
                placeholder()
                    .task(id: id) {
                        await load()
                    }
            }
        }
    }
}

#Preview {
    CKAssetImage(
        id: "preview",
        recordType: "PlantInformation",
        lookupField: "catalogID",
        lookupValue: "preview",
        assetField: "image",
        cachedData: nil,
        cacheData: { _ in }
    ) { image in
        image
            .pixelate()
            .resizable()
            .scaledToFit()
    } placeholder: {
        Image("PixelMonsteraHealthy")
            .pixelate()
            .resizable()
            .scaledToFit()
    }
    .frame(width: 160, height: 128)
    .padding()
}

private extension CKAssetImage {
    var image: Image? {
        guard let data = cachedData ?? loadedData else { return nil }
        return Image(data: data)
    }

    func load() async {
        guard cachedData == nil, loadedData == nil else { return }
        guard let data = try? await Self.fetchAssetData(
            recordType: recordType,
            lookupField: lookupField,
            lookupValue: lookupValue,
            assetField: assetField
        ) else { return }

        loadedData = data
        try? cacheData(data)
    }

    nonisolated static func fetchAssetData(
        recordType: CKRecord.RecordType,
        lookupField: CKRecord.FieldKey,
        lookupValue: String,
        assetField: CKRecord.FieldKey
    ) async throws -> Data? {
        let predicate = NSPredicate(format: "%K == %@", lookupField, lookupValue)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let database = CKContainer.default().publicCloudDatabase
        let result = try await database.records(
            matching: query,
            desiredKeys: [assetField],
            resultsLimit: 1
        )

        let record = try result.matchResults.first?.1.get()
        let asset = record?[assetField] as? CKAsset
        return asset?.fileURL.flatMap { try? Data(contentsOf: $0) }
    }
}
