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
            overview: "Monstera is a tropical foliage plant known for dramatic split leaves and fast indoor growth.",
            light: "Bright indirect light",
            water: "Every 7–10 days",
            temperature: "18–30°C",
            fertilizer: "Monthly in growing season",
            tips: "Yellowing leaves = overwatering"
        )
        let plant = Plant(
            nickname: "My Monstera",
            imageData: PlatformImageData.named("Monstera deliciosa"),
            note: "Placed near the living room window. New leaf unfurled this week.",
            information: info
        )
        plant.records = [
            PlantRecord(
                actionType: .watering,
                createdAt: .now.addingTimeInterval(-86_400),
                plant: plant
            ),
            PlantRecord(
                createdAt: .now.addingTimeInterval(-3 * 86_400),
                note: "Checked a few yellow edges on older leaves.",
                photoData: PlatformImageData.named("Monstera deliciosa"),
                diagnosis: DiagnosisMetadata(
                    result: DiagnosisResult(
                        species: "Monstera deliciosa",
                        problem: "Mild overwatering stress",
                        causes: ["Soil stayed damp for too long"],
                        suggestions: ["Wait for the top soil to dry before watering again"],
                        rawResponse: ""
                    )
                ),
                plant: plant
            )
        ]
        return plant
    }()

    static let warningPlant: Plant = {
        let info = PlantInformation(
            species: "Cactus",
            commonName: "Cactus",
            overview: "Cactus stores water in its stems and prefers a bright, dry environment with long gaps between watering.",
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
            overview: "Monstera is a tropical climbing plant that thrives in bright filtered light and appreciates a stable indoor routine.",
            light: "Bright indirect light",
            water: "Every 7–10 days",
            temperature: "18–30°C",
            fertilizer: "Monthly in growing season",
            tips: "Yellowing leaves = overwatering"
        )
        let pothos = PlantInformation(
            species: "Epipremnum aureum",
            commonName: "Golden Pothos",
            overview: "Golden Pothos is an adaptable trailing houseplant that stays forgiving for first-time plant owners.",
            light: "Tolerates low light",
            water: "Every 5–7 days",
            temperature: "15–30°C",
            fertilizer: "Every 2 weeks in spring/summer",
            tips: "Great for beginners"
        )
        let cactus = PlantInformation(
            species: "Cactus",
            commonName: "Cactus",
            overview: "Cactus prefers strong sun, gritty soil, and long dry periods between drinks.",
            light: "Full sun",
            water: "Every 2–4 weeks",
            temperature: "15–40°C",
            fertilizer: "Monthly diluted cactus fertilizer",
            tips: "Overwatering is the most common mistake"
        )
        context.insert(monstera)
        context.insert(pothos)
        context.insert(cactus)

        let p1 = Plant(
            nickname: "My Monstera",
            imageData: PlatformImageData.named("Monstera deliciosa"),
            note: "Placed near the living room window. Rotated the pot last weekend.",
            information: monstera
        )
        let p2 = Plant(nickname: "Happy Pothos", information: pothos)
        let p3 = Plant(nickname: "Desert Star", information: cactus)
        p3.activeIssues = [PlantIssue(type: .underwatered, severity: .mild)]
        let p4 = Plant(nickname: "Sick Fern")
        p4.activeIssues = [PlantIssue(type: .rootRot, severity: .severe)]

        p1.records = [
            PlantRecord(
                actionType: .watering,
                createdAt: .now.addingTimeInterval(-86_400),
                plant: p1
            ),
            PlantRecord(
                createdAt: .now.addingTimeInterval(-5 * 86_400),
                note: "Captured new split leaf growth.",
                photoData: PlatformImageData.named("Monstera deliciosa"),
                plant: p1
            )
        ]

        p3.records = [
            PlantRecord(
                actionType: .watering,
                createdAt: .now.addingTimeInterval(-10 * 86_400),
                plant: p3
            )
        ]

        context.insert(p1)
        context.insert(p2)
        context.insert(p3)
        context.insert(p4)
    }
}
