import Foundation

enum AppLanguage {
    case english
    case simplifiedChinese

    static var current: AppLanguage {
        let candidates = Locale.preferredLanguages + [Locale.current.identifier]
        for identifier in candidates {
            if identifier.lowercased().hasPrefix("zh") {
                return .simplifiedChinese
            }
        }
        return .english
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
