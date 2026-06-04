//
//  ModelContainer.swift
//  Plantory
//
//  Shared preview container for SwiftUI #Preview blocks.
//

import SwiftData
import Foundation

// MARK: - Preview Container

extension ModelContainer {
    /// 用于 #Preview 的内存 ModelContainer，已预填充示例数据。
    static let preview: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Plant.self, PlantRecord.self, PlantInformation.self, PlantNotificationSetting.self,
            configurations: config
        )
        PreviewData.populate(into: container.mainContext)
        return container
    }()
    
    static let empty: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Plant.self, PlantRecord.self, PlantInformation.self, PlantNotificationSetting.self,
            configurations: config
        )
        return container
    }()
}

enum PreviewData {
    static func populate(into context: ModelContext) {
        let monstera = PlantInformation.monstera
        let pothos = PlantInformation.goldenPothos
        let cactus = PlantInformation.cactus
        context.insert(monstera)
        context.insert(pothos)
        context.insert(cactus)

        let p1 = Plant.healthy(information: monstera)
        let p2 = Plant.pothos(information: pothos)
        let p3 = Plant.warning(information: cactus)
        let p4 = Plant.critical

        p1.records = PlantRecord.monsteraRecords(for: p1)
        p3.records = [PlantRecord.cactusWatering(for: p3)]

        context.insert(p1)
        context.insert(p2)
        context.insert(p3)
        context.insert(p4)
    }
}
