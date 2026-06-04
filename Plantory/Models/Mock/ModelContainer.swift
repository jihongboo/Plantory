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
        context.insert(PlantInformation.monstera)
        context.insert(PlantInformation.succulent)

        context.insert(Plant.monstera)
        context.insert(Plant.succulent)
    }
}
