import Foundation

enum AppLanguage {
    case english
    case simplifiedChinese

    static var current: AppLanguage {
        // Follow the language iOS actually resolved for this app first.
        let candidates = Bundle.main.preferredLocalizations
            + Locale.preferredLanguages.prefix(1)
            + [Locale.current.identifier]

        for identifier in candidates {
            if let language = from(identifier: identifier) {
                return language
            }
        }

        return .english
    }

    private static func from(identifier: String) -> AppLanguage? {
        let normalized = identifier.lowercased()

        if normalized.hasPrefix("zh") {
            return .simplifiedChinese
        }

        if normalized.hasPrefix("en") {
            return .english
        }

        return nil
    }

    var localeIdentifier: String {
        switch self {
        case .english:
            "en"
        case .simplifiedChinese:
            "zh-Hans"
        }
    }

    var aiLanguageName: String {
        switch self {
        case .english:
            "English"
        case .simplifiedChinese:
            "简体中文"
        }
    }

    var apiLanguageCode: String {
        switch self {
        case .english:
            "en"
        case .simplifiedChinese:
            "zh-CN"
        }
    }

    var unknownPlantValue: String {
        switch self {
        case .english:
            "unknown"
        case .simplifiedChinese:
            "未知"
        }
    }

    var emptyPromptNoteValue: String {
        switch self {
        case .english:
            "none"
        case .simplifiedChinese:
            "无"
        }
    }
}
