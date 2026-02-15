import SwiftUI
import DesignSystem

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

struct RedesignToastView: View {
    static let defaultDismissNanoseconds: UInt64 = 3_000_000_000

    let payload: RedesignToastPayload
    let bottomPadding: CGFloat

    init(payload: RedesignToastPayload, bottomPadding: CGFloat = .jsXL) {
        self.payload = payload
        self.bottomPadding = bottomPadding
    }

    init(message: String, style: RedesignToastStyle = .default, bottomPadding: CGFloat = .jsXL) {
        self.payload = .init(message: message, style: style)
        self.bottomPadding = bottomPadding
    }

    var body: some View {
        HStack(spacing: .jsSM) {
            Image(systemName: payload.style.iconName)
                .font(.jsHeadlineSmall)
                .foregroundColor(payload.style.accentColor)
                .frame(width: 28.jsScaled(.touchTarget), height: 28.jsScaled(.touchTarget))
                .background(Color.white.opacity(0.14))
                .clipShape(Circle())

            Text(payload.message)
                .font(.jsBodyMedium)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, .jsMD)
        .padding(.vertical, 10.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusLG)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.surfaceOverlay.opacity(0.88),
                            payload.style.accentColor.opacity(0.62)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: .jsRadiusLG)
                .stroke(Color.white.opacity(0.24), lineWidth: 1)
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
    }
}
