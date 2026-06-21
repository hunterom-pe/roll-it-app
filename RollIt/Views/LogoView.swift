import SwiftUI

public struct LogoView: View {
    let size: CGFloat
    
    public init(size: CGFloat = 110) {
        self.size = size
    }
    
    public var body: some View {
        let scale = size / 110.0
        
        ZStack {
            // Outer Circle Ring
            Circle()
                .stroke(Color.neonAmber, lineWidth: 6 * scale)
            
            // Inner Core/Hub
            Circle()
                .stroke(Color.neonAmber, lineWidth: 3 * scale)
                .frame(width: 32 * scale, height: 32 * scale)
            
            Circle()
                .fill(Color.neonAmber)
                .frame(width: 12 * scale, height: 12 * scale)
            
            // Angled Cutouts
            ForEach(0..<6) { index in
                let angle = Double(index) * 60.0
                Capsule()
                    .stroke(Color.neonAmber, lineWidth: 3 * scale)
                    .frame(width: 12 * scale, height: 22 * scale)
                    .offset(y: -36 * scale)
                    // The cutout is tilted 15 degrees relative to its radial spoke line
                    .rotationEffect(.degrees(15))
                    .rotationEffect(.degrees(angle))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 20) {
            LogoView(size: 180)
            LogoView(size: 110)
            LogoView(size: 40)
        }
    }
}
