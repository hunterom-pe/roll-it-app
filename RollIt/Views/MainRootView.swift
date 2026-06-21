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
                                VStack(spacing: 24) {
                                    Spacer()
                                    
                                    // Logo is brought into the main welcome area to fill empty black space
                                    LogoView(size: 140)
                                        .matchedGeometryEffect(id: "logo", in: launchNamespace)
                                    
                                    Text("Roll It")
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("Stop scrolling. Start watching.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                        .multilineTextAlignment(.center)
                                    
                                    Spacer()
                                    
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
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.neonAmber)
                                            )
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 48)
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
}

#Preview {
    MainRootView()
        .modelContainer(for: [MovieLogItem.self, ExcludedMovie.self, ProviderSkip.self], inMemory: true)
}
