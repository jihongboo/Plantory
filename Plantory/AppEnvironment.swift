import Foundation

enum AppEnvironment {
    /// Xcode SwiftUI Preview 运行时会注入该环境变量。
    static let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
