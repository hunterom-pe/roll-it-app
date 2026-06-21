import SwiftUI

public struct RuntimeStepView: View {
    let viewModel: QuizViewModel
    
    public init(viewModel: QuizViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("How much time?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Pick a runtime category that fits your schedule.")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(viewModel.runtimeOptions) { option in
                    Button {
                        viewModel.selectRuntime(option)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(option.name)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(viewModel.selectedRuntime == option ? .oledBlack : .white)
                                Text(option.description)
                                    .font(.subheadline)
                                    .foregroundColor(viewModel.selectedRuntime == option ? .oledBlack.opacity(0.7) : .secondaryText)
                            }
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(viewModel.selectedRuntime == option ? .oledBlack : .neonAmber)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.selectedRuntime == option ? Color.neonAmber : Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.neonAmber, lineWidth: viewModel.selectedRuntime == option ? 2 : 0)
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
    RuntimeStepView(viewModel: QuizViewModel())
}
