import SwiftUI
import Observation

public struct QuizCriteria: Sendable {
    public let vibeName: String?
    public let genreIds: [Int]
    public let minRuntime: Int?
    public let maxRuntime: Int?
    public let minReleaseDate: String?
    public let maxReleaseDate: String?
}

public struct VibeOption: Identifiable, Hashable {
    public var id: String { name }
    public let name: String
    public let icon: String
    public let genreIds: [Int]
}

public struct RuntimeOption: Identifiable, Hashable {
    public var id: String { name }
    public let name: String
    public let description: String
    public let minRuntime: Int?
    public let maxRuntime: Int?
}

public struct EraOption: Identifiable, Hashable {
    public var id: String { name }
    public let name: String
    public let description: String
    public let minReleaseDate: String?
    public let maxReleaseDate: String?
}

@Observable
@MainActor
public final class QuizViewModel {
    public var currentStep: Int = 0
    
    // Choices
    public var selectedVibe: VibeOption?
    public var selectedRuntime: RuntimeOption?
    public var selectedEra: EraOption?
    
    public init() {}
    
    public let vibeOptions = [
        VibeOption(name: "Action-Packed", icon: "bolt.fill", genreIds: [28, 12]),
        VibeOption(name: "Spooky & Chilling", icon: "eyes", genreIds: [27, 53]),
        VibeOption(name: "Laugh Out Loud", icon: "face.smiling.fill", genreIds: [35]),
        VibeOption(name: "Heartwarming & Cozy", icon: "heart.fill", genreIds: [10749, 18, 10751]),
        VibeOption(name: "Mind-Bending / Sci-Fi", icon: "brain.head.profile", genreIds: [878, 9648]),
        VibeOption(name: "Indie / Thought-Provoking", icon: "doc.text.magnifyingglass", genreIds: [18, 99])
    ]
    
    public let runtimeOptions = [
        RuntimeOption(name: "Quickie", description: "Less than 90m", minRuntime: nil, maxRuntime: 90),
        RuntimeOption(name: "Standard", description: "90m to 120m", minRuntime: 90, maxRuntime: 120),
        RuntimeOption(name: "Epic", description: "More than 120m", minRuntime: 120, maxRuntime: nil)
    ]
    
    public let eraOptions = [
        EraOption(name: "Modern", description: "2020 to Present", minReleaseDate: "2020-01-01", maxReleaseDate: nil),
        EraOption(name: "2010s", description: "2010 to 2019", minReleaseDate: "2010-01-01", maxReleaseDate: "2019-12-31"),
        EraOption(name: "Throwback", description: "1990 to 2009", minReleaseDate: "1990-01-01", maxReleaseDate: "2009-12-31"),
        EraOption(name: "Classic", description: "Before 1990", minReleaseDate: nil, maxReleaseDate: "1989-12-31")
    ]
    
    public func selectVibe(_ option: VibeOption) {
        selectedVibe = option
        withAnimation {
            currentStep = 1
        }
    }
    
    public func selectRuntime(_ option: RuntimeOption) {
        selectedRuntime = option
        withAnimation {
            currentStep = 2
        }
    }
    
    public func selectEra(_ option: EraOption) -> QuizCriteria? {
        selectedEra = option
        guard let selectedVibe = selectedVibe,
              let selectedRuntime = selectedRuntime else {
            return nil
        }
        
        return QuizCriteria(
            vibeName: selectedVibe.name,
            genreIds: selectedVibe.genreIds,
            minRuntime: selectedRuntime.minRuntime,
            maxRuntime: selectedRuntime.maxRuntime,
            minReleaseDate: option.minReleaseDate,
            maxReleaseDate: option.maxReleaseDate
        )
    }
    
    public func reset() {
        currentStep = 0
        selectedVibe = nil
        selectedRuntime = nil
        selectedEra = nil
    }
}
