import Foundation
import SwiftData

@Model
public final class MovieLogItem {
    @Attribute(.unique) public var id: Int
    public var title: String
    public var overview: String
    public var posterPath: String?
    public var releaseYear: String
    public var keywords: [String]
    public var providerLogos: [String]
    public var watchedAt: Date
    
    public init(id: Int, title: String, overview: String, posterPath: String?, releaseYear: String, keywords: [String], providerLogos: [String], watchedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseYear = releaseYear
        self.keywords = keywords
        self.providerLogos = providerLogos
        self.watchedAt = watchedAt
    }
}
