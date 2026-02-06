import SwiftUI

public enum JSListItemStyle {
    case defaultStyle
    case destructive
    case highlighted
}

public enum JSListItemAccessory {
    case none
    case disclosure
    case checkmark(isSelected: Bool)
    case detail(String)
    case toggle(isOn: Binding<Bool>)
}

public struct JSListItem: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color
    let style: JSListItemStyle
    let accessory: JSListItemAccessory
    let action: (() -> Void)?

    public init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color = .blue,
        style: JSListItemStyle = .defaultStyle,
        accessory: JSListItemAccessory = .disclosure,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.style = style
        self.accessory = accessory
        self.action = action
    }

    public var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                iconView

                textContent

                Spacer()

                accessoryView
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(backgroundColor)
        .frame(minHeight: 44)
    }

    @ViewBuilder
    private var iconView: some View {
        if let icon = icon {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconForegroundColor)
                .frame(width: 32, height: 32)
                .background(iconBackgroundColor)
                .cornerRadius(4)
        }
    }

    @ViewBuilder
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(titleColor)
                .lineLimit(1)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            EmptyView()

        case .disclosure:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)

        case .checkmark(let isSelected):
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22))
                .foregroundColor(isSelected ? .blue : .gray)

        case .detail(let text):
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)

        case .toggle(let isOn):
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .defaultStyle, .destructive:
            return .clear
        case .highlighted:
            return .blue.opacity(0.08)
        }
    }

    private var titleColor: Color {
        switch style {
        case .defaultStyle, .highlighted:
            return .primary
        case .destructive:
            return .red
        }
    }

    private var iconForegroundColor: Color {
        switch style {
        case .defaultStyle, .highlighted:
            return iconColor
        case .destructive:
            return .red
        }
    }

    private var iconBackgroundColor: Color {
        switch style {
        case .defaultStyle, .highlighted:
            return iconColor.opacity(0.12)
        case .destructive:
            return .red.opacity(0.12)
        }
    }
}

struct JSListItem_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var toggleOn = true

        var body: some View {
            List {
                Section {
                    JSListItem(
                        title: "Tasks",
                        subtitle: "12 items",
                        icon: "checkmark.circle",
                        action: {}
                    )

                    JSListItem(
                        title: "Settings",
                        icon: "gear",
                        accessory: .disclosure,
                        action: {}
                    )
                }

                Section {
                    JSListItem(
                        title: "Selected Option",
                        icon: "star.fill",
                        accessory: .checkmark(isSelected: true),
                        action: {}
                    )

                    JSListItem(
                        title: "Unselected Option",
                        icon: "star",
                        accessory: .checkmark(isSelected: false),
                        action: {}
                    )
                }

                Section {
                    JSListItem(
                        title: "Storage Used",
                        icon: "externaldrive",
                        accessory: .detail("2.4 GB"),
                        action: {}
                    )

                    JSListItem(
                        title: "Notifications",
                        icon: "bell.badge",
                        accessory: .toggle(isOn: $toggleOn),
                        action: {}
                    )
                }

                Section {
                    JSListItem(
                        title: "Delete Account",
                        icon: "trash",
                        style: .destructive,
                        accessory: .none,
                        action: {}
                    )

                    JSListItem(
                        title: "Highlighted Item",
                        icon: "exclamationmark.triangle",
                        style: .highlighted,
                        accessory: .disclosure,
                        action: {}
                    )
                }

                Section {
                    JSListItem(
                        title: "Simple Item",
                        accessory: .none,
                        action: {}
                    )
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }

    static var previews: some View {
        PreviewContainer()
    }
}
