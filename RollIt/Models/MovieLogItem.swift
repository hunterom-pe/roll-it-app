import Foundation
import SwiftData

@Model
public final class MovieLogItem {
    @Attribute(.unique) public var id: Int
    public var title: String
    public var overview: String
    public var posterPath: String?
    public var releaseYear: String
    public var runtime: Int?
    public var keywords: [String]
    public var providerLogos: [String]
    public var watchedAt: Date
    public var userScore: Double?
    public var popularity: Double?
    
    public init(id: Int, title: String, overview: String, posterPath: String?, releaseYear: String, runtime: Int?, keywords: [String], providerLogos: [String], watchedAt: Date = Date(), userScore: Double? = nil, popularity: Double? = nil) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseYear = releaseYear
        self.runtime = runtime
        self.keywords = keywords
        self.providerLogos = providerLogos
        self.watchedAt = watchedAt
        self.userScore = userScore
        self.popularity = popularity
    }
}
