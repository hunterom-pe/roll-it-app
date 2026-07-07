import SwiftUI
import SwiftData

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var watchLog: [MovieLogItem]
    @Query private var exclusions: [ExcludedMovie]
    @Query private var providerSkips: [ProviderSkip]
    
    public init() {}
    
    private var blockedProviders: [ProviderSkip] {
        providerSkips.filter { $0.skipCount >= 3 }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.oledBlack.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Stats Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("App Statistics")
                                    .font(.headline)
                                    .foregroundColor(.neonAmber)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Movies Logged (Watched)")
                                        Spacer()
                                        Text("\(watchLog.count)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(8)
                                    
                                    HStack {
                                        Text("Movies Skipped / Excluded")
                                        Spacer()
                                        Text("\(exclusions.count)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Blocked Providers Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Blocked Streaming Services")
                                    .font(.headline)
                                    .foregroundColor(.neonAmber)
                                    .padding(.horizontal)
                                
                                if blockedProviders.isEmpty {
                                    Text("No services blocked yet. Skipping a provider 3 times for not having it blocks it.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                } else {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(blockedProviders) { provider in
                                            HStack {
                                                Image(systemName: "xmark.shield.fill")
                                                    .foregroundColor(.red)
                                                Text(provider.providerName)
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text("\(provider.skipCount) skips")
                                                    .foregroundColor(.secondaryText)
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.05))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Reset Options
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Data Actions")
                                    .font(.headline)
                                    .foregroundColor(.neonAmber)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    Button(role: .destructive) {
                                        resetWatchHistory()
                                    } label: {
                                        HStack {
                                            Image(systemName: "trash")
                                            Text("Reset Watch History")
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.red.opacity(0.15))
                                        .cornerRadius(8)
                                    }
                                    
                                    Button(role: .destructive) {
                                        resetExclusions()
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.counterclockwise")
                                            Text("Clear Skipped Movies")
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.red.opacity(0.15))
                                        .cornerRadius(8)
                                    }
                                    
                                    Button(role: .destructive) {
                                        resetProviderSkips()
                                    } label: {
                                        HStack {
                                            Image(systemName: "globe")
                                            Text("Reset Provider Skip Limits")
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.red.opacity(0.15))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // About & Legal Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("About & Legal")
                                    .font(.headline)
                                    .foregroundColor(.neonAmber)
                                    .padding(.horizontal)
                                
                                VStack(alignment: .leading, spacing: 14) {
                                    // TMDB Attribution
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Data Provider")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                                            .font(.caption)
                                            .foregroundColor(.secondaryText)
                                            .lineSpacing(4)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(8)
                                    
                                    // Legal & Support Links
                                    VStack(spacing: 0) {
                                        Link(destination: URL(string: "https://github.com/hunterom-pe/roll-it-app/blob/main/PRIVACY.md")!) {
                                            HStack {
                                                Image(systemName: "hand.raised.fill")
                                                    .foregroundColor(.neonAmber)
                                                Text("Privacy Policy")
                                                Spacer()
                                                Image(systemName: "arrow.up.forward.app")
                                                    .font(.caption)
                                            }
                                            .padding()
                                            .foregroundColor(.white)
                                        }
                                        
                                        Divider()
                                            .background(Color.white.opacity(0.1))
                                        
                                        Link(destination: URL(string: "https://github.com/hunterom-pe/roll-it-app/issues")!) {
                                            HStack {
                                                Image(systemName: "questionmark.circle.fill")
                                                    .foregroundColor(.neonAmber)
                                                Text("Support & Feedback")
                                                Spacer()
                                                Image(systemName: "arrow.up.forward.app")
                                                    .font(.caption)
                                            }
                                            .padding()
                                            .foregroundColor(.white)
                                        }
                                    }
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Settings & Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.neonAmber)
                }
            }
        }
    }
    
    private func resetWatchHistory() {
        try? modelContext.delete(model: MovieLogItem.self)
    }
    
    private func resetExclusions() {
        try? modelContext.delete(model: ExcludedMovie.self)
    }
    
    private func resetProviderSkips() {
        try? modelContext.delete(model: ProviderSkip.self)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [MovieLogItem.self, ExcludedMovie.self, ProviderSkip.self], inMemory: true)
}
