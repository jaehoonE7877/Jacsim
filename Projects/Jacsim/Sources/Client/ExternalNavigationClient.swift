import Foundation
import ComposableArchitecture
import StoreKit
import UIKit

public struct ExternalNavigationClient: Sendable {
    public var openInquiryMail: @Sendable () async -> Bool
    public var requestReview: @Sendable () async -> Bool

    public init(
        openInquiryMail: @escaping @Sendable () async -> Bool,
        requestReview: @escaping @Sendable () async -> Bool
    ) {
        self.openInquiryMail = openInquiryMail
        self.requestReview = requestReview
    }
}

private enum ExternalNavigationLive {
    static let inquiryMailAddress = "support@jacsim.app"

    @MainActor
    static func openInquiryMail() async -> Bool {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = inquiryMailAddress
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Jacsim 문의")
        ]

        guard let url = components.url else {
            return false
        }
        guard UIApplication.shared.canOpenURL(url) else {
            return false
        }

        return await withCheckedContinuation { continuation in
            UIApplication.shared.open(url, options: [:]) { didOpen in
                continuation.resume(returning: didOpen)
            }
        }
    }

    @MainActor
    static func requestReview() async -> Bool {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) ?? UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            return false
        }

        if #available(iOS 18.0, *) {
            AppStore.requestReview(in: windowScene)
        } else {
            SKStoreReviewController.requestReview(in: windowScene)
        }
        return true
    }
}

private enum ExternalNavigationClientKey: DependencyKey {
    static let liveValue = ExternalNavigationClient(
        openInquiryMail: {
            await ExternalNavigationLive.openInquiryMail()
        },
        requestReview: {
            await ExternalNavigationLive.requestReview()
        }
    )

    static let testValue = ExternalNavigationClient(
        openInquiryMail: { false },
        requestReview: { false }
    )
}

extension DependencyValues {
    var externalNavigationClient: ExternalNavigationClient {
        get { self[ExternalNavigationClientKey.self] }
        set { self[ExternalNavigationClientKey.self] = newValue }
    }
}
