//
//  PreviewData.swift
//  Plantory
//
//  Shared mock data for SwiftUI #Preview blocks.
//

import SwiftData
import Foundation

// MARK: - Preview Container

extension ModelContainer {
    /// 用于 #Preview 的内存 ModelContainer，已预填充示例数据。
    static let preview: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Plant.self, PlantRecord.self, PlantInformation.self,
            configurations: config
        )
        PreviewData.populate(into: container.mainContext)
        return container
    }()
    
    static let empty: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Plant.self, PlantRecord.self, PlantInformation.self,
            configurations: config
        )
        return container
    }()
}

// MARK: - Mock Instances

/// 单个 Plant 快速访问，适合单卡片 / 详情页的 Preview。
enum PreviewData {

    static let healthyPlant: Plant = {
        let info = PlantInformation(
            species: "Monstera deliciosa",
            commonName: "Monstera",
            light: "Bright indirect light",
            water: "Every 7–10 days",
            temperature: "18–30°C",
            fertilizer: "Monthly in growing season",
            tips: "Yellowing leaves = overwatering"
        )
        return Plant(nickname: "My Monstera", information: info)
    }()

    static let warningPlant: Plant = {
        let info = PlantInformation(
            species: "Cactus",
            commonName: "Cactus",
            light: "Full sun",
            water: "Every 2–4 weeks",
            temperature: "15–40°C",
            fertilizer: "Monthly diluted cactus fertilizer",
            tips: "Overwatering is the most common mistake"
        )
        let plant = Plant(nickname: "Desert Star", information: info)
        plant.activeIssues = [PlantIssue(type: .underwatered, severity: .mild)]
        return plant
    }()

    static let criticalPlant: Plant = {
        let plant = Plant(nickname: "Sick Fern")
        plant.activeIssues = [PlantIssue(type: .rootRot, severity: .severe)]
        return plant
    }()

    // MARK: - Populate container

    static func populate(into context: ModelContext) {
        let monstera = PlantInformation(
            species: "Monstera deliciosa",
            commonName: "Monstera",
            light: "Bright indirect light",
            water: "Every 7–10 days",
            temperature: "18–30°C",
            fertilizer: "Monthly in growing season",
            tips: "Yellowing leaves = overwatering"
        )
        let pothos = PlantInformation(
            species: "Epipremnum aureum",
            commonName: "Golden Pothos",
            light: "Tolerates low light",
            water: "Every 5–7 days",
            temperature: "15–30°C",
            fertilizer: "Every 2 weeks in spring/summer",
            tips: "Great for beginners"
        )
        let cactus = PlantInformation(
            species: "Cactus",
            commonName: "Cactus",
            light: "Full sun",
            water: "Every 2–4 weeks",
            temperature: "15–40°C",
            fertilizer: "Monthly diluted cactus fertilizer",
            tips: "Overwatering is the most common mistake"
        )
        context.insert(monstera)
        context.insert(pothos)
        context.insert(cactus)

        let p1 = Plant(nickname: "My Monstera", information: monstera)
        let p2 = Plant(nickname: "Happy Pothos", information: pothos)
        let p3 = Plant(nickname: "Desert Star", information: cactus)
        p3.activeIssues = [PlantIssue(type: .underwatered, severity: .mild)]
        let p4 = Plant(nickname: "Sick Fern")
        p4.activeIssues = [PlantIssue(type: .rootRot, severity: .severe)]

        context.insert(p1)
        context.insert(p2)
        context.insert(p3)
        context.insert(p4)
    }
}
