import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
public final class SuggestionViewModel {
    private let modelContext: ModelContext
    private let client = TMDBClient()
    private let criteria: QuizCriteria
    
    public var discoverMovies: [DiscoverMovie] = []
    public var currentIndex: Int = 0
    public var currentMovieDetails: MovieDetails? = nil
    
    public var isLoading: Bool = false
    public var isFirstLoad: Bool = true
    public var errorMessage: String? = nil
    
    public init(modelContext: ModelContext, criteria: QuizCriteria) {
        self.modelContext = modelContext
        self.criteria = criteria
    }
    
    public func loadInitialSuggestions() async {
        isLoading = true
        isFirstLoad = true
        errorMessage = nil
        
        do {
            discoverMovies = try await client.discoverMovies(
                genreIds: criteria.genreIds,
                minRuntime: criteria.minRuntime,
                maxRuntime: criteria.maxRuntime,
                minReleaseDate: criteria.minReleaseDate,
                maxReleaseDate: criteria.maxReleaseDate
            )
            
            currentIndex = 0
            isFirstLoad = false
            await fetchNextSuggestion()
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            isFirstLoad = false
        }
    }
    
    public func fetchNextSuggestion() async {
        isLoading = true
        currentMovieDetails = nil
        
        while currentIndex < discoverMovies.count {
            let candidate = discoverMovies[currentIndex]
            let id = candidate.id
            
            // Check if excluded or already watched
            if isExcluded(id: id) {
                currentIndex += 1
                continue
            }
            
            // Fetch details to inspect providers & keywords
            do {
                let details = try await client.fetchMovieDetails(id: id)
                
                // Check provider exclusions
                if isProviderExcluded(details: details) {
                    // Implicitly exclude this movie and write to database so we don't check again
                    excludeMovie(id: id, reason: "no_service")
                    currentIndex += 1
                    continue
                }
                
                // Found a valid movie suggestion!
                currentMovieDetails = details
                currentIndex += 1 // Advance pointer for next time
                isLoading = false
                return
            } catch {
                // If detail fetch fails, log it and try next movie
                print("Error loading details for movie ID \(id): \(error)")
                currentIndex += 1
            }
        }
        
        // Exhausted the list
        currentMovieDetails = nil
        isLoading = false
    }
    
    // Actions
    public func selectLetsWatch() async {
        guard let movie = currentMovieDetails else { return }
        
        // Log the movie
        let logItem = MovieLogItem(
            id: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterPath: movie.posterPath,
            releaseYear: movie.releaseYear,
            runtime: movie.runtime,
            keywords: movie.keywordsWrapper?.keywords.map { $0.name } ?? [],
            providerLogos: movie.sortedProviders.compactMap { $0.logoPath },
            userScore: movie.voteAverage,
            popularity: movie.popularity
        )
        
        modelContext.insert(logItem)
        try? modelContext.save()
        
        await fetchNextSuggestion()
    }
    
    public func skipNotInMood() async {
        guard let movie = currentMovieDetails else { return }
        
        excludeMovie(id: movie.id, reason: "not_in_mood")
        await fetchNextSuggestion()
    }
    
    public func skipNoService() async {
        guard let movie = currentMovieDetails else { return }
        
        // Exclude the movie
        excludeMovie(id: movie.id, reason: "no_service")
        
        // Increment skip count for all watch providers on this movie
        let providers = movie.sortedProviders
        for provider in providers {
            incrementProviderSkip(providerId: provider.providerId, providerName: provider.providerName)
        }
        
        try? modelContext.save()
        await fetchNextSuggestion()
    }
    
    // Helpers
    private func isExcluded(id: Int) -> Bool {
        // Query ExcludedMovie
        let excludedDescriptor = FetchDescriptor<ExcludedMovie>(predicate: #Predicate<ExcludedMovie> { $0.id == id })
        if let excludedCount = try? modelContext.fetchCount(excludedDescriptor), excludedCount > 0 {
            return true
        }
        
        // Query MovieLogItem (already watched)
        let loggedDescriptor = FetchDescriptor<MovieLogItem>(predicate: #Predicate<MovieLogItem> { $0.id == id })
        if let loggedCount = try? modelContext.fetchCount(loggedDescriptor), loggedCount > 0 {
            return true
        }
        
        return false
    }
    
    private func isProviderExcluded(details: MovieDetails) -> Bool {
        let providers = details.sortedProviders
        guard !providers.isEmpty else { return false }
        
        var allBlocked = true
        for provider in providers {
            let pid = provider.providerId
            let descriptor = FetchDescriptor<ProviderSkip>(predicate: #Predicate<ProviderSkip> { $0.providerId == pid })
            if let result = try? modelContext.fetch(descriptor).first {
                if result.skipCount < 3 {
                    allBlocked = false
                    break
                }
            } else {
                allBlocked = false
                break
            }
        }
        
        return allBlocked
    }
    
    private func excludeMovie(id: Int, reason: String) {
        let exclusion = ExcludedMovie(id: id, reason: reason)
        modelContext.insert(exclusion)
        try? modelContext.save()
    }
    
    private func incrementProviderSkip(providerId: Int, providerName: String) {
        let descriptor = FetchDescriptor<ProviderSkip>(predicate: #Predicate<ProviderSkip> { $0.providerId == providerId })
        if let result = try? modelContext.fetch(descriptor).first {
            result.skipCount += 1
        } else {
            let newSkip = ProviderSkip(providerId: providerId, providerName: providerName, skipCount: 1)
            modelContext.insert(newSkip)
        }
    }
}
