import SwiftUI
import SwiftData

public struct MovieSuggestionView: View {
    @Binding var appState: MainRootView.AppState
    let criteria: QuizCriteria?
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SuggestionViewModel? = nil
    
    // Watch celebration overlay
    @State private var showCelebration = false
    @State private var celebratedMovieTitle = ""
    
    public init(appState: Binding<MainRootView.AppState>, criteria: QuizCriteria?) {
        self._appState = appState
        self.criteria = criteria
    }
    
    public var body: some View {
        ZStack {
            Color.oledBlack.ignoresSafeArea()
            
            if let vm = viewModel {
                if vm.isLoading {
                    // Loading State
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.neonAmber)
                        Text("Finding the perfect film...")
                            .foregroundColor(.secondaryText)
                            .font(.subheadline)
                    }
                } else if let movie = vm.currentMovieDetails {
                    // Suggestion Card State
                    VStack(spacing: 0) {
                        // Movie Card Content
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // Poster Card
                                if let posterPath = movie.posterPath,
                                   let url = URL(string: "\(TMDBConfig.baseImageURL)\(posterPath)") {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ZStack {
                                                Color.white.opacity(0.05)
                                                ProgressView().tint(.neonAmber)
                                            }
                                            .frame(height: 380)
                                            .cornerRadius(16)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 380)
                                                .cornerRadius(16)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.neonAmber, lineWidth: 2) // Spec: Accent for active progress/borders
                                                )
                                        case .failure:
                                            ZStack {
                                                Color.white.opacity(0.05)
                                                Image(systemName: "film").font(.largeTitle).foregroundColor(.secondaryText)
                                            }
                                            .frame(height: 380)
                                            .cornerRadius(16)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    ZStack {
                                        Color.white.opacity(0.05)
                                        Image(systemName: "film").font(.largeTitle).foregroundColor(.secondaryText)
                                    }
                                    .frame(height: 380)
                                    .cornerRadius(16)
                                }
                                
                                // Details
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                                        Text(movie.title)
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        let runtimeStr = formatRuntime(movie.runtime)
                                        Text("\(movie.releaseYear)\(runtimeStr.isEmpty ? "" : "  •  \(runtimeStr)")")
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondaryText)
                                    }
                                }
                                
                                // Providers
                                let providers = movie.sortedProviders
                                if !providers.isEmpty {
                                    HStack(spacing: 8) {
                                        ForEach(providers.prefix(5)) { provider in
                                            if let path = provider.logoPath,
                                               let url = URL(string: "\(TMDBConfig.baseImageURL)\(path)") {
                                                AsyncImage(url: url) { image in
                                                    image.resizable()
                                                } placeholder: {
                                                    Color.white.opacity(0.1)
                                                }
                                                .frame(width: 32, height: 32)
                                                .cornerRadius(6)
                                            }
                                        }
                                    }
                                }
                                
                                // Keywords (Formatted)
                                if let keywords = movie.keywordsWrapper?.keywords, !keywords.isEmpty {
                                    Text(keywords.map { $0.name.lowercased() }.joined(separator: "  •  "))
                                        .font(.caption)
                                        .foregroundColor(.secondaryText)
                                        .lineLimit(2)
                                }
                                
                                // Overview
                                Text(movie.overview)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .lineSpacing(4)
                                    .lineLimit(4)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        }
                        
                        // Action Buttons Bar
                        VStack(spacing: 12) {
                            // Primary Watch Button
                            Button {
                                celebratedMovieTitle = movie.title
                                Task {
                                    await vm.selectLetsWatch()
                                    withAnimation {
                                        showCelebration = true
                                    }
                                }
                            } label: {
                                Text("Let's Watch")
                                    .font(.headline)
                                    .foregroundColor(.oledBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.neonAmber) // Primary CTA uses Neon Amber
                                    )
                            }
                            .padding(.horizontal, 16)
                            
                            // Skips stack (stacked vertically due to long labels)
                            VStack(spacing: 10) {
                                Button {
                                    Task {
                                        await vm.skipNoService()
                                    }
                                } label: {
                                    Text("I don't have this streaming service")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                
                                Button {
                                    Task {
                                        await vm.skipNotInMood()
                                    }
                                } label: {
                                    Text("Not in the mood")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                
                                Button {
                                    withAnimation {
                                        appState = .quiz
                                    }
                                } label: {
                                    Text("Restart Quiz")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.neonAmber)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 16)
                        .background(Color.oledBlack)
                    }
                } else {
                    // Empty Suggestions State
                    VStack(spacing: 24) {
                        Image(systemName: "film.stack")
                            .font(.system(size: 64))
                            .foregroundColor(.neonAmber)
                        
                        Text("End of suggestions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("We searched popularity trends but found no more matches. Modify your quiz filters to try again!")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button {
                            withAnimation {
                                appState = .quiz
                            }
                        } label: {
                            Text("Restart Quiz")
                                .font(.headline)
                                .foregroundColor(.oledBlack)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.neonAmber)
                                )
                        }
                    }
                }
            } else {
                Color.oledBlack.ignoresSafeArea()
            }
            
            // Celebration overlay
            if showCelebration {
                ZStack {
                    Color.black.opacity(0.85).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "popcorn.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.neonAmber)
                        
                        Text("Enjoy the show!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Logged '\(celebratedMovieTitle)' to your watched history.")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Button("Roll Again") {
                            withAnimation {
                                showCelebration = false
                            }
                        }
                        .foregroundColor(.neonAmber)
                        .font(.headline)
                        .padding(.top, 10)
                    }
                    .padding(32)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.neonAmber, lineWidth: 1)
                    )
                    .padding(24)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            if viewModel == nil, let criteria = criteria {
                viewModel = SuggestionViewModel(modelContext: modelContext, criteria: criteria)
                Task {
                    await viewModel?.loadInitialSuggestions()
                }
            }
        }
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
}
