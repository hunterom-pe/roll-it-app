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
                        }
                        .padding(.top, 16)
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
