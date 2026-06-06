import CloudKit
import Foundation

enum PlantInformationCloudServiceError: LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound:
            String(localized: "Plant information was not found.")
        }
    }
}

struct PlantInformationCloudService {
    private let database: CKDatabase

    init(container: CKContainer = .default()) {
        database = container.publicCloudDatabase
    }

    func fetchPlantInformations() async throws -> [PlantInformation] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "PlantInformation", predicate: predicate)

        return try await fetchRecords(matching: query)
            .map(PlantInformation.init(record:))
            .sorted { $0.displayCommonName < $1.displayCommonName }
    }

    func fetchPlantInformation(catalogID: String) async throws -> PlantInformation {
        let predicate = NSPredicate(format: "catalogID == %@", catalogID)
        let query = CKQuery(recordType: "PlantInformation", predicate: predicate)
        let records = try await fetchRecords(matching: query, resultsLimit: 1)

        if let record = records.first {
            return PlantInformation(record: record)
        }

        guard let info = try await fetchPlantInformations().first(where: { $0.catalogID == catalogID }) else {
            throw PlantInformationCloudServiceError.notFound
        }

        return info
    }
}

private extension PlantInformationCloudService {
    func fetchRecords(
        matching query: CKQuery,
        resultsLimit: Int = CKQueryOperation.maximumResults
    ) async throws -> [CKRecord] {
        var records: [CKRecord] = []
        let firstPage = try await database.records(
            matching: query,
            resultsLimit: resultsLimit
        )
        records.append(contentsOf: try decodedRecords(from: firstPage.matchResults))

        var cursor = firstPage.queryCursor
        while let currentCursor = cursor {
            let page = try await database.records(continuingMatchFrom: currentCursor)
            records.append(contentsOf: try decodedRecords(from: page.matchResults))
            cursor = page.queryCursor
        }

        return records
    }

    func decodedRecords(
        from matchResults: [(CKRecord.ID, Result<CKRecord, Error>)]
    ) throws -> [CKRecord] {
        try matchResults.map { _, result in
            try result.get()
        }
    }
}
