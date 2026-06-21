# Roll It
> **Stop scrolling. Start watching.**

**Roll It** is a premium, native iOS movie recommender app designed to eliminate decision fatigue. It takes users through a rapid 3-step quiz to discover trending films, check their streaming availability, and log their watched history—all with a pure pitch-black OLED aesthetic and a golden theme.

---

## 📸 Key Features

1. **Launch Sequence & Matched Geometry**:
   - Programmatic vector Kinetic Film Reel logo centered on launch.
   - Glides smoothly using a native `.spring()` animation to the top-middle of the welcome page while the tagline and **Start Quiz** CTA fade in.
2. **Paging Quiz Engine**:
   - Programmatically driven horizontal wizard (`TabView` page style) with swipe gestures disabled to guide choices.
   - **Step 1: Vibe & Genre**: Grid cards (Action-Packed, Spooky, etc.) mapping to TMDB genres.
   - **Step 2: Runtime**: Pick Quickie (<90m), Standard (90-120m), or Epic (>120m).
   - **Step 3: Era**: Filter by Modern (2020+), 2010s, Throwback (1990-2009), or Classic (<1990).
3. **TMDB Discover suggestions**:
   - Queries `GET /discover/movie` sorted by popularity.
   - Enforces a **high-quality filter** of `vote_average.gte=6.0` and `vote_count.gte=100` to screen out obscure or poorly rated movies.
   - Fetches keywords and watch providers in parallel.
4. **Skip & Persistence Logic (SwiftData)**:
   - **Let's Watch**: Logs movie and timestamp to history.
   - **Skip (Not in Mood)**: Excludes the movie ID permanently.
   - **Skip (No Service)**: Excludes the movie and increments a local counter for its streaming providers. If a provider reaches $\geq 3$ skips, movies exclusive to that service are filtered out.
5. **Watch History List**:
   - Chronological watched log with poster thumbnails and formatted date/times.
   - Tapping any log item pops up a detailed sheet using the same reusable movie details view.

---

## 🛠️ Technology Stack & Requirements

- **Platform**: iOS 17.0+ (iPhone only)
- **Language**: Swift 6.0 (Strict Concurrency Sendable compliant)
- **UI Framework**: SwiftUI
- **Database/Persistence**: SwiftData
- **Networking**: Pure URLSession with async/await (Zero external libraries like Alamofire or Kingfisher)
- **Project Builder**: XcodeGen

---

## 📂 Project Directory Structure

```
roll-it-app/
├── project.yml                   # XcodeGen build specifications
├── README.md                     # Documentation
├── .gitignore                    # Git file exclusions
├── .agents/
│   └── AGENTS.md                 # Workspace automation rules
├── RollIt/                       # Source files
│   ├── App/
│   │   ├── RollItApp.swift       # Application Entry Point & Container config
│   │   ├── Colors.swift          # OLED Black and Golden Reel Gold color tokens
│   │   └── Assets.xcassets/      # App icons & root images
│   ├── Models/
│   │   ├── MovieLogItem.swift    # SwiftData watched log schema
│   │   ├── ExcludedMovie.swift   # SwiftData skipped movies schema
│   │   └── ProviderSkip.swift    # SwiftData streaming service skip statistics
│   ├── Networking/
│   │   ├── TMDBConfig.swift      # API configuration keys & constants
│   │   ├── TMDBModels.swift      # JSON Decodables conforming to Sendable
│   │   └── TMDBClient.swift      # Actor-isolated URLSession async client
│   ├── ViewModels/
│   │   ├── QuizViewModel.swift   # Tracks wizard choices & steps
│   │   └── SuggestionViewModel.swift # Filters movies, increments skips, maps history
│   └── Views/
│       ├── MainRootView.swift    # matchedGeometry launch controller & TabBar
│       ├── LogoView.swift        # Scalable vector film reel drawing
│       ├── SettingsView.swift    # Stats monitor & data purger
│       ├── Quiz/
│       │   ├── QuizWizardView.swift   # Page view container
│       │   ├── VibeGenreStepView.swift
│       │   ├── RuntimeStepView.swift
│       │   └── EraStepView.swift
│       ├── Suggestion/
│       │   ├── MovieSuggestionView.swift # Suggestion cards & skips stack
│       │   └── MovieDetailView.swift     # Reusable movie overview & provider sheet
│       └── Log/
│           └── LogTabView.swift          # Watched log list controller
```

---

## 🚀 Setup & Execution

### 1. Build Xcode Project using XcodeGen
This repository defines the targets, sources, and bundle values in a `project.yml` file. Generate the `.xcodeproj` file by running:
```bash
# Make sure xcodegen is installed (brew install xcodegen)
xcodegen generate
```

### 2. Configure TMDB Credentials
The app uses **The Movie Database (TMDB) API v3**. The API read key is pre-configured in `TMDBConfig.swift`:
```swift
public struct TMDBConfig {
    public static let apiKey = "980ac7f736a29668deff3a9ed997ecfe"
    public static let region = "US"
    ...
}
```

### 3. Open in Xcode & Run
1. Open the generated project folder:
   ```bash
   open RollIt.xcodeproj
   ```
2. In Xcode, select an **iPhone Simulator** target (e.g. iPhone 15/16).
3. Press **⌘ + R** (Command + R) to compile, build, and run the app.
