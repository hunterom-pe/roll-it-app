import SwiftUI

extension Color {
    public static let oledBlack = Color(red: 0, green: 0, blue: 0)
    public static let goldenReel = Color(red: 1.0, green: 0.843, blue: 0.0) // #FFD700 Gold
    
    // Alias to keep references in views compiling and automatically redirect to Gold
    public static let neonAmber = goldenReel
    
    public static let primaryText = Color.white
    public static let secondaryText = Color.white.opacity(0.6)
}
