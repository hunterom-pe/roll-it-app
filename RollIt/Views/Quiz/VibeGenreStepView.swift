import SwiftUI

public struct VibeGenreStepView: View {
    let viewModel: QuizViewModel
    
    public init(viewModel: QuizViewModel) {
        self.viewModel = viewModel
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Select your vibe")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("What type of movie fits your mood right now?")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.vibeOptions) { option in
                        Button {
                            viewModel.selectVibe(option)
                        } label: {
                            VStack(spacing: 16) {
                                Image(systemName: option.icon)
                                    .font(.system(size: 32))
                                    .foregroundColor(viewModel.selectedVibe == option ? .oledBlack : .neonAmber)
                                
                                Text(option.name)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(viewModel.selectedVibe == option ? .oledBlack : .white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(viewModel.selectedVibe == option ? Color.neonAmber : Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.neonAmber, lineWidth: viewModel.selectedVibe == option ? 2 : 0)
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color.oledBlack)
    }
}

#Preview {
    VibeGenreStepView(viewModel: QuizViewModel())
}
