import Foundation

enum StartupDisplayPolicy {
    static let splashMinimumDuration: TimeInterval = 0.55
    static let splashMaximumDuration: TimeInterval = 1.6

    // Keep the skeleton visible long enough after splash for startup liveliness.
    static let postSplashSkeletonVisibleDuration: TimeInterval = 1.2
    static var initialHomeSkeletonMinimumDuration: TimeInterval {
        splashMinimumDuration + postSplashSkeletonVisibleDuration
    }
}
