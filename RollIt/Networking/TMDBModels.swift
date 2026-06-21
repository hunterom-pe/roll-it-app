import Foundation

public struct MovieDiscoverResponse: Codable, Sendable {
    public let results: [DiscoverMovie]
}

public struct DiscoverMovie: Codable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let releaseDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}

public struct Genre: Codable, Identifiable, Sendable {
    public let id: Int
    public let name: String
}

public struct Keyword: Codable, Identifiable, Sendable {
    public let id: Int
    public let name: String
}

public struct KeywordsWrapper: Codable, Sendable {
    public let keywords: [Keyword]
}

public struct WatchProvider: Codable, Identifiable, Sendable {
    public var id: Int { providerId }
    public let providerId: Int
    public let providerName: String
    public let logoPath: String?
    
    enum CodingKeys: String, CodingKey {
        case providerId = "provider_id"
        case providerName = "provider_name"
        case logoPath = "logo_path"
    }
}

public struct CountryProviders: Codable, Sendable {
    public let link: String?
    public let flatrate: [WatchProvider]?
    public let rent: [WatchProvider]?
    public let buy: [WatchProvider]?
}

public struct WatchProvidersResults: Codable, Sendable {
    public let results: [String: CountryProviders]
}

public struct MovieDetails: Codable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let releaseDate: String?
    public let runtime: Int?
    public let genres: [Genre]?
    public let keywordsWrapper: KeywordsWrapper?
    public let watchProvidersWrapper: WatchProvidersResults?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case runtime
        case genres
        case keywordsWrapper = "keywords"
        case watchProvidersWrapper = "watch/providers"
    }
    
    public var releaseYear: String {
        guard let releaseDate = releaseDate, releaseDate.count >= 4 else { return "N/A" }
        return String(releaseDate.prefix(4))
    }
    
    public var sortedProviders: [WatchProvider] {
        var providers: [WatchProvider] = []
        if let usProviders = watchProvidersWrapper?.results["US"] {
            if let flatrate = usProviders.flatrate {
                providers.append(contentsOf: flatrate)
            }
            if let rent = usProviders.rent {
                providers.append(contentsOf: rent)
            }
        }
        // Deduplicate by provider id
        var seen = Set<Int>()
        return providers.filter { seen.insert($0.providerId).inserted }
    }
}
