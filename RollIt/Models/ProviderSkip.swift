import Foundation
import SwiftData

@Model
public final class ProviderSkip {
    @Attribute(.unique) public var providerId: Int
    public var providerName: String
    public var skipCount: Int
    
    public init(providerId: Int, providerName: String, skipCount: Int = 1) {
        self.providerId = providerId
        self.providerName = providerName
        self.skipCount = skipCount
    }
}
