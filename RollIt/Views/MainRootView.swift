import SwiftUI
import SwiftData

public struct MainRootView: View {
    @Namespace private var launchNamespace
    @State private var isSplashActive = true
    @State private var selectedTab = 0
    
    // Manage App state within the Roll tab
    @State private var appState: AppState = .welcome
    @State private var activeCriteria: QuizCriteria? = nil
    @State private var showSettings = false
    
    // Welcome screen revamped background
    @State private var backgroundPosters: [String] = []
    
    public enum AppState {
        case welcome
        case quiz
        case suggestions
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.oledBlack.ignoresSafeArea()
            
            if isSplashActive {
                // Splash State: Centered Large Logo
                VStack {
                    Spacer()
                    LogoView(size: 180)
                        .matchedGeometryEffect(id: "logo", in: launchNamespace)
                    Spacer()
                }
                .transition(.opacity)
            } else {
                // Active App State: TabBar Shell
                TabView(selection: $selectedTab) {
                    // Roll Tab
                    NavigationStack {
                        ZStack {
                            Color.oledBlack.ignoresSafeArea()
                            
                            switch appState {
                            case .welcome:
                                ZStack {
                                    // 1. Faint Poster Collage Background
                                    if !backgroundPosters.isEmpty {
                                        let columns = [
                                            GridItem(.flexible(), spacing: 12),
                                            GridItem(.flexible(), spacing: 12),
                                            GridItem(.flexible(), spacing: 12)
                                        ]
                                        LazyVGrid(columns: columns, spacing: 12) {
                                            ForEach(backgroundPosters, id: \.self) { path in
                                                if let url = URL(string: "\(TMDBConfig.baseImageURL)\(path)") {
                                                    AsyncImage(url: url) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                    } placeholder: {
                                                        Color.clear
                                                    }
                                                    .frame(height: 150)
                                                    .clipped()
                                                    .opacity(0.2)
                                                }
                                            }
                                        }
                                        .blur(radius: 2)
                                        .ignoresSafeArea()
                                        
                                        // Gradient overlay to fade collage into OLED black
                                        LinearGradient(
                                            gradient: Gradient(colors: [.black, .clear, .black]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .ignoresSafeArea()
                                    }
                                    
                                    // 2. Foreground Content
                                    VStack(spacing: 24) {
                                        Spacer()
                                        
                                        // Ambient glow behind spinning logo
                                        ZStack {
                                            Circle()
                                                .fill(Color.neonAmber.opacity(0.12))
                                                .frame(width: 200, height: 200)
                                                .blur(radius: 35)
                                            
                                            LogoView(size: 140, isRotating: true)
                                                .matchedGeometryEffect(id: "logo", in: launchNamespace)
                                        }
                                        .padding(.bottom, 12)
                                        
                                        Text("Roll It")
                                            .font(.system(size: 44, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text("Stop scrolling. Start watching.")
                                            .font(.subheadline)
                                            .foregroundColor(.secondaryText)
                                            .multilineTextAlignment(.center)
                                        
                                        Spacer()
                                        
                                        // Pulsing CTA button
                                        Button {
                                            withAnimation(.easeInOut) {
                                                appState = .quiz
                                            }
                                        } label: {
                                            Text("Start Quiz")
                                                .font(.headline)
                                                .foregroundColor(.oledBlack)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 16)
                                                .background(
                                                    ZStack {
                                                        PulsingOutline()
                                                        
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color.neonAmber)
                                                    }
                                                )
                                        }
                                        .padding(.horizontal, 24)
                                        .padding(.bottom, 48)
                                    }
                                }
                                .onAppear {
                                    // Fetch background posters
                                    if backgroundPosters.isEmpty {
                                        fetchBackgroundPosters()
                                    }
                                }
                            case .quiz:
                                QuizWizardView(appState: $appState, activeCriteria: $activeCriteria)
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            case .suggestions:
                                MovieSuggestionView(appState: $appState, criteria: activeCriteria)
                                    .transition(.opacity)
                            }
                        }
                        .toolbar {
                            if appState != .quiz {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        showSettings = true
                                    } label: {
                                        Image(systemName: "slider.horizontal.3")
                                            .font(.title3)
                                            .foregroundColor(.neonAmber)
                                    }
                                }
                            }
                        }
                    }
                    .tabItem {
                        Label("Roll", systemImage: "film.fill")
                    }
                    .tag(0)
                    
                    // History Log Tab
                    NavigationStack {
                        LogTabView()
                    }
                    .tabItem {
                        Label("Log", systemImage: "clock.fill")
                    }
                    .tag(1)
                }
                .tint(.neonAmber)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Run the launch sequence trigger
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0)) {
                    isSplashActive = false
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private func fetchBackgroundPosters() {
        Task {
            do {
                let client = TMDBClient()
                let movies = try await client.discoverMovies(
                    genreIds: [],
                    minRuntime: nil,
                    maxRuntime: nil,
                    minReleaseDate: nil,
                    maxReleaseDate: nil
                )
                self.backgroundPosters = Array(movies.prefix(12)).compactMap { $0.posterPath }
            } catch {
                print("Failed loading background posters: \(error)")
            }
        }
    }
}

#Preview {
    MainRootView()
        .modelContainer(for: [MovieLogItem.self, ExcludedMovie.self, ProviderSkip.self], inMemory: true)
}

private struct PulsingOutline: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.neonAmber, lineWidth: 2)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                    scale = 1.15
                    opacity = 0.0
                }
            }
    }
}
