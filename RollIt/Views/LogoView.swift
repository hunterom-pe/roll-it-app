import SwiftUI

public struct LogoView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            // Outer Circle Ring
            Circle()
                .stroke(Color.neonAmber, lineWidth: 6)
            
            // Inner Core/Hub
            Circle()
                .stroke(Color.neonAmber, lineWidth: 3)
                .frame(width: 32, height: 32)
            
            Circle()
                .fill(Color.neonAmber)
                .frame(width: 12, height: 12)
            
            // Angled Cutouts
            ForEach(0..<6) { index in
                let angle = Double(index) * 60.0
                Capsule()
                    .stroke(Color.neonAmber, lineWidth: 3)
                    .frame(width: 12, height: 22)
                    .offset(y: -36)
                    // The cutout is tilted 15 degrees relative to its radial spoke line
                    .rotationEffect(.degrees(15))
                    .rotationEffect(.degrees(angle))
            }
        }
        .frame(width: 110, height: 110)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        LogoView()
    }
}
