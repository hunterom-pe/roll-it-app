import Foundation
import SwiftData

@Model
public final class ExcludedMovie {
    @Attribute(.unique) public var id: Int
    public var excludedAt: Date
    public var reason: String // "not_in_mood" or "no_service"
    
    public init(id: Int, reason: String, excludedAt: Date = Date()) {
        self.id = id
        self.reason = reason
        self.excludedAt = excludedAt
    }
}
