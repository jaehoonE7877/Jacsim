import DSKit
import SwiftUI

public struct MainView: View {
    @Bindable var model: MainModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(model: MainModel) {
        self.model = model
    }

    public var body: some View {
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
                    FeedView(model: model.feed)
                case .me:
                    MeView(model: model.me)
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
            if model.isRootTabBarVisible {
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
        }
        .overlay {
            if model.isRootTabBarVisible {
                PlusActionSheet(
                    isPresented: $model.isPlusSheetPresented,
                    onCreateTask: {
                        model.createTaskActionTapped()
                    },
                    onCreateBrag: {
                        model.createBragActionTapped()
                    },
                    onComingSoon: {
                        model.comingSoonActionTapped()
                    }
                )
            }
        }
        .overlay(alignment: .top) {
            if let toastText = model.plusToastText {
                JSGlassToast(text: toastText)
                    .padding(.top, .jsXL)
                    .padding(.horizontal, .jsXL)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .accessibilityLabel(toastText)
            }
        }
        .animation(JSAnimation.spring, value: model.plusToastText)
        .sensoryFeedback(.impact(weight: .light), trigger: model.plusToastText)
        .task(id: model.plusToastText) {
            guard model.plusToastText != nil else { return }
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            model.plusToastDismissed()
        }
    }
}
