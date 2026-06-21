import Foundation

public enum TMDBError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL generated was invalid."
        case .invalidResponse: return "Received an invalid response from the server."
        case .apiError(let msg): return msg
        }
    }
}

public actor TMDBClient {
    private let session = URLSession.shared
    
    public init() {}
    
    /// Fetches a list of movies from the discover endpoint based on criteria.
    public func discoverMovies(
        genreIds: [Int],
        minRuntime: Int?,
        maxRuntime: Int?,
        minReleaseDate: String?,
        maxReleaseDate: String?
    ) async throws -> [DiscoverMovie] {
        var components = URLComponents(string: "\(TMDBConfig.baseApiURL)/discover/movie")
        
        var queryItems = [
            URLQueryItem(name: "api_key", value: TMDBConfig.apiKey),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "watch_region", value: TMDBConfig.region)
        ]
        
        if !genreIds.isEmpty {
            let genresString = genreIds.map { String($0) }.joined(separator: "|")
            queryItems.append(URLQueryItem(name: "with_genres", value: genresString))
        }
        
        if let minRuntime = minRuntime {
            queryItems.append(URLQueryItem(name: "with_runtime.gte", value: String(minRuntime)))
        }
        if let maxRuntime = maxRuntime {
            queryItems.append(URLQueryItem(name: "with_runtime.lte", value: String(maxRuntime)))
        }
        
        if let minReleaseDate = minReleaseDate {
            queryItems.append(URLQueryItem(name: "primary_release_date.gte", value: minReleaseDate))
        }
        if let maxReleaseDate = maxReleaseDate {
            queryItems.append(URLQueryItem(name: "primary_release_date.lte", value: maxReleaseDate))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let discoverResponse = try decoder.decode(MovieDiscoverResponse.self, from: data)
        return discoverResponse.results
    }
    
    /// Fetches full details for a specific movie, including keywords and watch providers.
    public func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        var components = URLComponents(string: "\(TMDBConfig.baseApiURL)/movie/\(id)")
        
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: TMDBConfig.apiKey),
            URLQueryItem(name: "append_to_response", value: "keywords,watch/providers")
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let details = try decoder.decode(MovieDetails.self, from: data)
        return details
    }
}
