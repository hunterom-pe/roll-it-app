import SwiftUI

public struct QuizWizardView: View {
    @Binding var appState: MainRootView.AppState
    @Binding var activeCriteria: QuizCriteria?
    
    @State private var viewModel = QuizViewModel()
    
    public init(appState: Binding<MainRootView.AppState>, activeCriteria: Binding<QuizCriteria?>) {
        self._appState = appState
        self._activeCriteria = activeCriteria
    }
    
    public var body: some View {
        ZStack {
            Color.oledBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header & Progress Indicator
                HStack(spacing: 8) {
                    // Back button
                    Button {
                        handleBackPress()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.neonAmber)
                        .font(.body)
                    }
                    
                    Spacer()
                    
                    // Segmented Progress Indicators
                    HStack(spacing: 6) {
                        ForEach(0..<3) { step in
                            Capsule()
                                .fill(viewModel.currentStep == step ? Color.neonAmber : Color.white.opacity(0.2))
                                .frame(width: viewModel.currentStep == step ? 24 : 8, height: 6)
                                .animation(.spring(), value: viewModel.currentStep)
                        }
                    }
                    
                    Spacer()
                    
                    // Dummy spacer to balance Back button width
                    Text("Back")
                        .font(.body)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Paging Wizard Content
                TabView(selection: $viewModel.currentStep) {
                    // Step 1: Vibe & Genre
                    VibeGenreStepView(viewModel: viewModel)
                        .tag(0)
                    
                    // Step 2: Runtime
                    RuntimeStepView(viewModel: viewModel)
                        .tag(1)
                    
                    // Step 3: Era
                    EraStepView(viewModel: viewModel) { criteria in
                        self.activeCriteria = criteria
                        withAnimation {
                            self.appState = .suggestions
                        }
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // Disable manual swipe gestures
                .gesture(DragGesture())
            }
        }
    }
    
    private func handleBackPress() {
        if viewModel.currentStep > 0 {
            withAnimation {
                viewModel.currentStep -= 1
            }
        } else {
            withAnimation {
                appState = .welcome
            }
        }
    }
}
