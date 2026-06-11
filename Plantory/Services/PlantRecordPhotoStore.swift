import CloudKit
import Foundation

enum PlantRecordPhotoStoreError: LocalizedError {
    case missingLocalPhoto

    var errorDescription: String? {
        switch self {
        case .missingLocalPhoto:
            String(localized: "The local record photo is missing.")
        }
    }
}

struct PlantRecordPhotoStore {
    static let shared = PlantRecordPhotoStore()

    private let container: CKContainer
    private let database: CKDatabase
    private let fileManager: FileManager

    init(
        container: CKContainer = .default(),
        fileManager: FileManager = .default
    ) {
        self.container = container
        database = container.privateCloudDatabase
        self.fileManager = fileManager
    }

    func savePhotoData(_ photoData: Data, for photoID: UUID) throws {
        let fileName = fileName(for: photoID)
        let fileURL = try localPhotoURL(fileName: fileName)
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try photoData.write(to: fileURL, options: .atomic)
    }

    func localPhotoData(photoID: UUID) throws -> Data? {
        let fileURL = try localPhotoURL(fileName: fileName(for: photoID))
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        return try Data(contentsOf: fileURL)
    }
    
    func deletePhoto(photoID: UUID) async {
        try? deleteLocalPhoto(photoID: photoID)
        guard (try? await container.accountStatus()) == .available else {
            return
        }
        
        do {
            try await database.deleteRecord(withID: CKRecord.ID(recordName: photoID.uuidString))
        } catch let error as CKError where error.code == .unknownItem {
            return
        } catch {
            return
        }
    }

    @MainActor
    func photoData(for record: PlantRecord) async throws -> Data? {
        guard let photoID = record.photoID else {
            return nil
        }

        if let data = try localPhotoData(photoID: photoID) {
            return data
        }

        return try await restorePhotoFromCloud(for: record)
    }

    @MainActor
    func uploadPhoto(for record: PlantRecord) async throws {
        guard try await container.accountStatus() == .available else {
            return
        }

        guard let photoID = record.photoID else {
            throw PlantRecordPhotoStoreError.missingLocalPhoto
        }

        let fileName = fileName(for: photoID)
        let fileURL = try localPhotoURL(fileName: fileName)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw PlantRecordPhotoStoreError.missingLocalPhoto
        }

        let recordName = photoID.uuidString
        let cloudRecord = try await cloudRecord(recordName: recordName)
        cloudRecord["plantRecordID"] = record.id.uuidString
        cloudRecord["createdAt"] = record.createdAt
        cloudRecord["photo"] = CKAsset(fileURL: fileURL)

        if let plantID = record.plant?.id.uuidString {
            cloudRecord["plantID"] = plantID
        }

        let savedRecord = try await database.save(cloudRecord)
        record.photoID = UUID(uuidString: savedRecord.recordID.recordName) ?? photoID
    }
}

private extension PlantRecordPhotoStore {
    func fileName(for photoID: UUID) -> String {
        "\(photoID.uuidString).jpg"
    }

    var localPhotoDirectoryURL: URL {
        get throws {
            let applicationSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            return applicationSupportURL.appendingPathComponent("PlantRecordPhotos", isDirectory: true)
        }
    }

    func localPhotoURL(fileName: String) throws -> URL {
        let safeFileName = URL(fileURLWithPath: fileName).lastPathComponent
        return try localPhotoDirectoryURL.appendingPathComponent(safeFileName)
    }
    
    func deleteLocalPhoto(photoID: UUID) throws {
        let fileURL = try localPhotoURL(fileName: fileName(for: photoID))
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return
        }
        try fileManager.removeItem(at: fileURL)
    }

    func cloudRecord(recordName: String) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: recordName)

        do {
            return try await database.record(for: recordID)
        } catch let error as CKError where error.code == .unknownItem {
            return CKRecord(recordType: "PlantRecordPhoto", recordID: recordID)
        }
    }

    @MainActor
    func restorePhotoFromCloud(for record: PlantRecord) async throws -> Data? {
        guard let photoID = record.photoID else {
            return nil
        }

        let cloudRecord = try await database.record(for: CKRecord.ID(recordName: photoID.uuidString))
        guard let asset = cloudRecord["photo"] as? CKAsset,
              let fileURL = asset.fileURL else {
            return nil
        }

        let photoData = try Data(contentsOf: fileURL)
        try savePhotoData(photoData, for: photoID)
        return photoData
    }
}
