import SwiftUI
import SwiftData

public struct LogTabView: View {
    @Query(sort: \MovieLogItem.watchedAt, order: .reverse) private var loggedItems: [MovieLogItem]
    
    // For presenting detail sheet
    @State private var selectedDetailData: MovieDetailData? = nil
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.oledBlack.ignoresSafeArea()
            
            if loggedItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("No movies logged yet")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Movies you choose to watch via 'Let's Watch' will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                List {
                    ForEach(loggedItems) { item in
                        Button {
                            selectedDetailData = MovieDetailData(
                                title: item.title,
                                overview: item.overview,
                                posterPath: item.posterPath,
                                releaseYear: item.releaseYear,
                                keywords: item.keywords,
                                providerLogos: item.providerLogos
                            )
                        } label: {
                            HStack(spacing: 16) {
                                // Mini poster thumbnail
                                if let posterPath = item.posterPath,
                                   let url = URL(string: "\(TMDBConfig.baseImageURL)\(posterPath)") {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.white.opacity(0.1)
                                    }
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(6)
                                    .clipped()
                                } else {
                                    ZStack {
                                        Color.white.opacity(0.05)
                                        Image(systemName: "film")
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(6)
                                }
                                
                                // Text details
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.title)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    HStack {
                                        Text(item.releaseYear)
                                            .font(.caption)
                                            .foregroundColor(.secondaryText)
                                        
                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 3, height: 3)
                                        
                                        Text(formatDate(item.watchedAt))
                                            .font(.caption)
                                            .foregroundColor(.secondaryText)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.white.opacity(0.15))
                    }
                }
                .listStyle(.plain)
                .background(Color.oledBlack)
            }
        }
        .navigationTitle("Watch History")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedDetailData) { data in
            NavigationStack {
                MovieDetailView(data: data)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Close") {
                                selectedDetailData = nil
                            }
                            .foregroundColor(.neonAmber)
                        }
                    }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Enable Identifiable on MovieDetailData so it can be used in .sheet(item:)
extension MovieDetailData: Identifiable {
    public var id: String { title + releaseYear }
}

#Preview {
    NavigationStack {
        LogTabView()
            .modelContainer(for: MovieLogItem.self, inMemory: true)
    }
}
