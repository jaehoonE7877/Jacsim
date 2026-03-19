import Combine
import UIKit

@MainActor
final class KeyboardObserver: ObservableObject {
    struct Context: Equatable {
        var isVisible: Bool = false
        var height: CGFloat = 0
        var animationDuration: Double = 0.25
    }

    @Published private(set) var context = Context()

    private var cancellables = Set<AnyCancellable>()

    init(notificationCenter: NotificationCenter = .default) {
        notificationCenter.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardFrameChange(notification)
            }
            .store(in: &cancellables)

        notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardHide(notification)
            }
            .store(in: &cancellables)
    }

    private func handleKeyboardFrameChange(_ notification: Notification) {
        guard let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let screenHeight = UIScreen.main.bounds.height
        let overlapHeight = max(0, screenHeight - endFrame.minY)
        let duration = keyboardAnimationDuration(from: notification)

        context = Context(
            isVisible: overlapHeight > 0,
            height: overlapHeight,
            animationDuration: duration
        )
    }

    private func handleKeyboardHide(_ notification: Notification) {
        context = Context(
            isVisible: false,
            height: 0,
            animationDuration: keyboardAnimationDuration(from: notification)
        )
    }

    private func keyboardAnimationDuration(from notification: Notification) -> Double {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            return duration
        }
        return 0.25
    }
}
