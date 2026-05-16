import DSKit
import SwiftUI

public struct MainView: View {
    @Bindable var model: MainModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(model: MainModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack(path: $model.path) {
            ZStack {
                Color.backgroundNormal
                    .ignoresSafeArea()

                Group {
                    switch model.selectedTab {
                    case .today:
                        HomeView(model: model.home)
                    case .calendar:
                        CalendarView(model: model.calendar)
                    case .feed:
                        FeedPlaceholderView(model: model.feed)
                    case .me:
                        MePlaceholderView(model: model.me)
                    case .plus:
                        EmptyView()
                    default:
                        HomeView(model: model.home)
                    }
                }
                .id(model.selectedTab)
                .transition(reduceMotion ? .identity : .opacity)
            }
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.18), value: model.selectedTab)
            .safeAreaInset(edge: .bottom) {
                JSGlassFloatingTabBar(
                    selection: $model.selectedTab,
                    onSelect: { tab in
                        model.tabSelected(tab)
                    },
                    onPlusTap: {
                        model.plusButtonTapped()
                    }
                )
                .padding(.top, .jsXS)
                .padding(.bottom, .jsXS)
            }
            .overlay {
                PlusActionSheet(
                    isPresented: $model.isPlusSheetPresented,
                    onCreateTask: {
                        model.createTaskActionTapped()
                    }
                )
            }
            .navigationDestination(for: MainModel.Route.self) { route in
                switch route {
                case .newTask:
                    if let newTask = model.newTask {
                        NewTaskView(model: newTask)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }
}

private struct FeedPlaceholderView: View {
    let model: FeedPlaceholderModel

    var body: some View {
        MainPlaceholderTabView(
            title: "피드",
            subtitle: "친구들의 기록은 곧 채워질 예정이에요",
            icon: "person.2.fill",
            accessibilityLabel: "피드 탭 준비 중"
        )
    }
}

private struct MePlaceholderView: View {
    let model: MePlaceholderModel

    var body: some View {
        MainPlaceholderTabView(
            title: "나",
            subtitle: "내 기록과 설정은 다음 단계에서 정리해요",
            icon: "person.crop.circle.fill",
            accessibilityLabel: "나 탭 준비 중"
        )
    }
}

private struct MainPlaceholderTabView: View {
    let title: String
    let subtitle: String
    let icon: String
    let accessibilityLabel: String

    var body: some View {
        VStack(spacing: .jsLG) {
            Image(systemName: icon)
                .font(.jsDisplayScaledSemiBold(size: 44))
                .foregroundStyle(Color.forestAccent)
                .frame(width: 72.jsScaled(), height: 72.jsScaled())
                .background(
                    Circle()
                        .fill(Color.surfaceSelected.opacity(0.44))
                )

            VStack(spacing: .jsXS) {
                Text(title)
                    .font(.jsSerifDisplay)
                    .foregroundStyle(Color.labelStrong)

                Text(subtitle)
                    .font(.jsBodyMedium)
                    .foregroundStyle(Color.labelAlternative)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, .jsXL)
        .background(LinearGradient.wallpaperMorning.ignoresSafeArea())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}
