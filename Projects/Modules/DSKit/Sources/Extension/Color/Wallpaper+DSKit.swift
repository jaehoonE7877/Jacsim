import SwiftUI

public extension LinearGradient {
    static var wallpaperMorning: LinearGradient {
        LinearGradient(
            colors: [.wallpaperMorningTop, .wallpaperMorningBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var wallpaperForest: LinearGradient {
        LinearGradient(
            colors: [.wallpaperForestTop, .wallpaperForestBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var wallpaperDusk: LinearGradient {
        LinearGradient(
            colors: [.wallpaperDuskTop, .wallpaperDuskBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
