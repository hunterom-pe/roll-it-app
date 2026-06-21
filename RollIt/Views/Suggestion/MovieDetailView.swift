import SwiftUI

public struct MovieDetailData: Sendable {
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let releaseYear: String
    public let runtime: Int?
    public let keywords: [String]
    public let providerLogos: [String]
    public let userScore: Double?
    public let popularity: Double?
    
    public init(title: String, overview: String, posterPath: String?, releaseYear: String, runtime: Int?, keywords: [String], providerLogos: [String], userScore: Double? = nil, popularity: Double? = nil) {
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseYear = releaseYear
        self.runtime = runtime
        self.keywords = keywords
        self.providerLogos = providerLogos
        self.userScore = userScore
        self.popularity = popularity
    }
}

public struct MovieDetailView: View {
    let data: MovieDetailData
    
    public init(data: MovieDetailData) {
        self.data = data
    }
    
    private func formatRuntime(_ minutes: Int?) -> String {
        guard let minutes = minutes, minutes > 0 else { return "" }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    private func formatUserScore(_ score: Double?) -> String {
        guard let score = score, score > 0 else { return "" }
        return String(format: "⭐ %.1f", score)
    }
    
    private func formatPopularity(_ pop: Double?) -> String {
        guard let pop = pop, pop > 0 else { return "" }
        return String(format: "🔥 %.0f", pop)
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Movie Poster (OLED Card Style)
                if let posterPath = data.posterPath,
                   let url = URL(string: "\(TMDBConfig.baseImageURL)\(posterPath)") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.white.opacity(0.05)
                                ProgressView()
                                    .tint(.neonAmber)
                            }
                            .frame(height: 400)
                            .cornerRadius(16)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .frame(height: 400)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        case .failure:
                            ZStack {
                                Color.white.opacity(0.05)
                                Image(systemName: "film")
                                    .font(.largeTitle)
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .frame(height: 400)
                            .cornerRadius(16)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    ZStack {
                        Color.white.opacity(0.05)
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .frame(height: 400)
                    .cornerRadius(16)
                }
                
                // Title and Metadata
                VStack(alignment: .leading, spacing: 8) {
                    Text(data.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    let metadataText: String = {
                        let runtimeStr = formatRuntime(data.runtime)
                        let scoreStr = formatUserScore(data.userScore)
                        let popularityStr = formatPopularity(data.popularity)
                        var parts: [String] = [data.releaseYear]
                        if !runtimeStr.isEmpty {
                            parts.append(runtimeStr)
                        }
                        if !scoreStr.isEmpty {
                            parts.append(scoreStr)
                        }
                        if !popularityStr.isEmpty {
                            parts.append(popularityStr)
                        }
                        return parts.joined(separator: "  •  ")
                    }()
                    
                    Text(metadataText)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                
                // Provider Badges (if any)
                if !data.providerLogos.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Streaming Providers")
                            .font(.headline)
                            .foregroundColor(.neonAmber)
                        
                        HStack(spacing: 10) {
                            ForEach(0..<data.providerLogos.count, id: \.self) { idx in
                                let path = data.providerLogos[idx]
                                if let url = URL(string: "\(TMDBConfig.baseImageURL)\(path)") {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.white.opacity(0.1)
                                    }
                                    .frame(width: 44, height: 44)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                }
                
                // Keywords
                if !data.keywords.isEmpty {
                    Text(data.keywords.map { $0.lowercased() }.joined(separator: "  •  "))
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .lineSpacing(4)
                }
                
                // Overview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.headline)
                        .foregroundColor(.neonAmber)
                    
                    Text(data.overview)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineSpacing(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color.oledBlack.ignoresSafeArea())
    }
}

#Preview {
    MovieDetailView(data: MovieDetailData(
        title: "Inception",
        overview: "Cobb, a skilled thief who commits corporate espionage by infiltrating the subconscious of his targets, is offered a chance to regain his old life as payment for a task considered to be impossible: \"inception\", the implantation of another person's idea into a target's subconscious.",
        posterPath: nil,
        releaseYear: "2010",
        runtime: 148,
        keywords: ["dream", "subconscious", "heist"],
        providerLogos: []
    ))
}
