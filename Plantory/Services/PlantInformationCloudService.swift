import CloudKit
import Foundation
import SwiftData

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

    @MainActor
    func localPlantInformations(in modelContext: ModelContext) throws -> [PlantInformation] {
        let descriptor = FetchDescriptor<PlantInformation>()
        return try modelContext.fetch(descriptor)
            .sorted { $0.displayCommonName < $1.displayCommonName }
    }

    @MainActor
    func localPlantInformation(
        catalogID: String,
        in modelContext: ModelContext
    ) throws -> PlantInformation? {
        var descriptor = FetchDescriptor<PlantInformation>(
            predicate: #Predicate { information in
                information.catalogID == catalogID
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    @MainActor
    func fetchPlantInformations(in modelContext: ModelContext) async throws -> [PlantInformation] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "PlantInformation", predicate: predicate)
        let records = try await fetchRecords(matching: query)

        for record in records {
            _ = try upsert(record: record, in: modelContext)
        }
        try modelContext.save()

        return try localPlantInformations(in: modelContext)
    }

    @MainActor
    func fetchPlantInformation(
        catalogID: String,
        in modelContext: ModelContext
    ) async throws -> PlantInformation {
        let predicate = NSPredicate(format: "catalogID == %@", catalogID)
        let query = CKQuery(recordType: "PlantInformation", predicate: predicate)
        let records = try await fetchRecords(matching: query, resultsLimit: 1)

        if let record = records.first {
            let information = try upsert(record: record, in: modelContext)
            try modelContext.save()
            return information
        }

        let recordsByFetchAll = try await fetchRecords(
            matching: CKQuery(recordType: "PlantInformation", predicate: NSPredicate(value: true))
        )

        guard let record = recordsByFetchAll.first(where: { PlantInformation.catalogID(from: $0) == catalogID }) else {
            throw PlantInformationCloudServiceError.notFound
        }

        let information = try upsert(record: record, in: modelContext)
        try modelContext.save()
        return information
    }
}

private extension PlantInformationCloudService {
    @MainActor
    func upsert(record: CKRecord, in modelContext: ModelContext) throws -> PlantInformation {
        let catalogID = PlantInformation.catalogID(from: record)

        if let existing = try localPlantInformation(catalogID: catalogID, in: modelContext) {
            existing.update(from: record)
            return existing
        }

        let information = PlantInformation(record: record)
        modelContext.insert(information)
        return information
    }

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
