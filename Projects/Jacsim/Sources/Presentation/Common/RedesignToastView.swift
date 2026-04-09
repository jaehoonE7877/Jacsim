import SwiftUI
import DesignSystem
import UIKit

enum RedesignToastStyle: Equatable {
    case `default`
    case success
    case error

    var iconName: String {
        switch self {
        case .default:
            return "info.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .default:
            return .primaryNormal
        case .success:
            return .positive
        case .error:
            return .destructive
        }
    }
}

struct RedesignToastPayload: Equatable {
    let message: String
    let style: RedesignToastStyle

    static func `default`(_ message: String) -> Self {
        .init(message: message, style: .default)
    }

    static func success(_ message: String) -> Self {
        .init(message: message, style: .success)
    }

    static func error(_ message: String) -> Self {
        .init(message: message, style: .error)
    }
}

@MainActor
struct RedesignToastView: View {
    static let defaultDismissNanoseconds: UInt64 = 3_000_000_000

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let payload: RedesignToastPayload
    let bottomPadding: CGFloat
    let dismissAction: (() -> Void)?

    init(payload: RedesignToastPayload, bottomPadding: CGFloat = .jsXL, dismissAction: (() -> Void)? = nil) {
        self.payload = payload
        self.bottomPadding = bottomPadding
        self.dismissAction = dismissAction
    }

    init(message: String, style: RedesignToastStyle = .default, bottomPadding: CGFloat = .jsXL, dismissAction: (() -> Void)? = nil) {
        self.payload = .init(message: message, style: style)
        self.bottomPadding = bottomPadding
        self.dismissAction = dismissAction
    }

    var body: some View {
        HStack(spacing: .jsSM) {
            Image(systemName: payload.style.iconName)
                .font(.jsHeadlineSmall)
                .foregroundColor(payload.style.accentColor)
                .frame(width: 28.jsScaled(.touchTarget), height: 28.jsScaled(.touchTarget))
                .background(payload.style.accentColor.opacity(0.12))
                .clipShape(Circle())

            Text(payload.message)
                .font(.jsBodyMedium)
                .foregroundColor(.labelStrong)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let dismissAction {
                Button(action: dismissAction) {
                    Image(systemName: "xmark")
                        .font(.jsLabelLarge)
                        .foregroundColor(.labelNeutral)
                        .frame(width: 28.jsScaled(.touchTarget), height: 28.jsScaled(.touchTarget))
                        .background(Color.backgroundNormal.opacity(0.9))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("안내 닫기")
            }
        }
        .padding(.horizontal, .jsMD)
        .padding(.vertical, 10.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusLG)
                .fill(Color.backgroundAlternative.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: .jsRadiusLG)
                .stroke(payload.style.accentColor.opacity(0.22), lineWidth: 1)
        )
        .shadow(
            color: payload.style.accentColor.opacity(0.28),
            radius: 16.jsScaled(),
            x: 0,
            y: 8.jsScaled()
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(payload.message)
        .accessibilityHint("잠시 후 자동으로 사라지는 안내 메시지")
        .padding(.bottom, bottomPadding)
        .padding(.horizontal, .jsXL)
        .onAppear {
            UIAccessibility.post(notification: .announcement, argument: payload.message)
        }
    }
}
