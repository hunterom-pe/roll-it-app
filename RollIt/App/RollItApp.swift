import SwiftUI
import SwiftData

@main
public struct RollItApp: App {
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainRootView()
        }
        .modelContainer(for: [MovieLogItem.self, ExcludedMovie.self, ProviderSkip.self])
    }
}
