import SwiftUI

public struct EraStepView: View {
    let viewModel: QuizViewModel
    let onComplete: (QuizCriteria) -> Void
    
    public init(viewModel: QuizViewModel, onComplete: @escaping (QuizCriteria) -> Void) {
        self.viewModel = viewModel
        self.onComplete = onComplete
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Select an era")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("When should the movie have been made?")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(viewModel.eraOptions) { option in
                    Button {
                        if let criteria = viewModel.selectEra(option) {
                            onComplete(criteria)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(option.name)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(viewModel.selectedEra == option ? .oledBlack : .white)
                                Text(option.description)
                                    .font(.subheadline)
                                    .foregroundColor(viewModel.selectedEra == option ? .oledBlack.opacity(0.7) : .secondaryText)
                            }
                            Spacer()
                            
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundColor(viewModel.selectedEra == option ? .oledBlack : .neonAmber)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.selectedEra == option ? Color.neonAmber : Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.neonAmber, lineWidth: viewModel.selectedEra == option ? 2 : 0)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .background(Color.oledBlack)
    }
}

#Preview {
    EraStepView(viewModel: QuizViewModel()) { _ in }
}
