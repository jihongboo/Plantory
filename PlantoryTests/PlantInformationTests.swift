import CloudKit
import Testing
@testable import Plantory

@MainActor
struct PlantInformationTests {

    @Test func cloudKitRecordDecodesImageURL() {
        let record = CKRecord(
            recordType: "PlantInformation",
            recordID: CKRecord.ID(recordName: "monstera-deliciosa")
        )
        record["catalogID"] = "monstera-deliciosa"
        record["species"] = "Monstera deliciosa"
        record["commonName"] = "Monstera"
        record["overview"] = "A tropical climbing plant."
        record["imageURL"] = "https://gfdywyqwbajcetpywino.supabase.co/storage/v1/object/public/Plantory/monstera-deliciosa.png"
        record["temperature"] = "18-30°C"
        record["localizedContentsJSON"] = "{}"

        let information = PlantInformation(record: record)

        #expect(information.imageURL == URL(string: "https://gfdywyqwbajcetpywino.supabase.co/storage/v1/object/public/Plantory/monstera-deliciosa.png"))
    }

    @Test func invalidImageURLDecodesAsNil() {
        let record = CKRecord(
            recordType: "PlantInformation",
            recordID: CKRecord.ID(recordName: "monstera-deliciosa")
        )
        record["species"] = "Monstera deliciosa"
        record["commonName"] = "Monstera"
        record["imageURL"] = "not a url"
        record["temperature"] = "18-30°C"

        let information = PlantInformation(record: record)

        #expect(information.imageURL == nil)
    }

    @Test func invalidLocalizedContentsFallsBackToBaseFields() {
        let information = PlantInformation(
            species: "Monstera deliciosa",
            commonName: "Monstera",
            overview: "A tropical climbing plant.",
            temperature: "18-30°C"
        )
        information.localizedContentsJSON = "not json"

        #expect(information.displayCommonName == "Monstera")
        #expect(information.displayOverview == "A tropical climbing plant.")
        #expect(information.displayTips == "")
    }
}
