import Foundation
import SwiftUI
import NavigatorUI

nonisolated enum PlantoryDestination: NavigationDestination {
    case plant(PlantRoute)
    case plantInformationLibrary(PlantInformationLibraryRoute)
    case plantInformation(PlantInformationRoute)
    case addPlant(PlantInformationRoute)
    case plantNotifications(PlantRoute)
    case addLog(PlantRoute)
    case editPlantDetails(PlantRoute)
    case debugNotifications

    var body: some View {
        switch self {
        case .plant(let route):
            if let plant = route.plant {
                PlantPage(plant: plant, heroNamespace: route.heroNamespace)
            } else {
                PlantPage(plantID: route.plantID, heroNamespace: route.heroNamespace)
            }

        case .plantInformationLibrary(let route):
            switch route {
            case .normal:
                PlantInformationLibraryPage()
            case .add:
                ManagedNavigationStack {
                    PlantInformationLibraryPage()
                }
            }

        case .plantInformation(let route):
            if let plantInformation = route.plantInformation {
                PlantInformationPage(plantInformation: plantInformation)
            } else {
                PlantInformationPage(id: route.catalogID)
            }

        case .addPlant(let route):
            if let plantInformation = route.plantInformation {
                AddPlantPage(plantInformation: plantInformation)
            } else {
                PlantInformationPage(id: route.catalogID)
            }

        case .plantNotifications(let route):
            if let plant = route.plant {
                PlantNotificationsPage(plant: plant)
            } else {
                PlantPage(plantID: route.plantID)
            }

        case .addLog(let route):
            if let plant = route.plant {
                AddLogPage(plant: plant)
            } else {
                PlantPage(plantID: route.plantID)
            }

        case .editPlantDetails(let route):
            if let plant = route.plant {
                EditPlantDetailsSheet(plant: plant)
            } else {
                PlantPage(plantID: route.plantID)
            }

        case .debugNotifications:
            DebugNotificationsPage()
        }
    }
}

nonisolated enum PlantRoute: Hashable {
    case id(UUID)
    case idWithHero(UUID, Namespace.ID)
    case loaded(id: UUID, plant: Plant)

    init(plant: Plant) {
        self = .loaded(id: plant.id, plant: plant)
    }

    init(plantID: UUID) {
        self = .id(plantID)
    }

    init(plantID: UUID, heroNamespace: Namespace.ID) {
        self = .idWithHero(plantID, heroNamespace)
    }

    var plantID: UUID {
        switch self {
        case .id(let plantID), .idWithHero(let plantID, _), .loaded(let plantID, _):
            plantID
        }
    }

    var plant: Plant? {
        switch self {
        case .id, .idWithHero:
            nil
        case .loaded(_, let plant):
            plant
        }
    }

    var heroNamespace: Namespace.ID? {
        switch self {
        case .id, .loaded:
            nil
        case .idWithHero(_, let heroNamespace):
            heroNamespace
        }
    }

    static func == (lhs: PlantRoute, rhs: PlantRoute) -> Bool {
        lhs.plantID == rhs.plantID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(plantID)
    }
}

nonisolated enum PlantInformationRoute: Hashable {
    case id(String)
    case loaded(id: String, plantInformation: PlantInformation)

    init(plantInformation: PlantInformation) {
        self = .loaded(id: plantInformation.catalogID, plantInformation: plantInformation)
    }

    init(catalogID: String) {
        self = .id(catalogID)
    }

    var catalogID: String {
        switch self {
        case .id(let catalogID), .loaded(let catalogID, _):
            catalogID
        }
    }

    var plantInformation: PlantInformation? {
        switch self {
        case .id:
            nil
        case .loaded(_, let plantInformation):
            plantInformation
        }
    }

    static func == (lhs: PlantInformationRoute, rhs: PlantInformationRoute) -> Bool {
        lhs.catalogID == rhs.catalogID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(catalogID)
    }
}

nonisolated enum PlantInformationLibraryRoute: Hashable {
    case normal
    case add
}
