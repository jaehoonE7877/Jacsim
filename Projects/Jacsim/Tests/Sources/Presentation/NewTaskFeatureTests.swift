import Testing
import ComposableArchitecture
import UIKit

@testable import Jacsim

@MainActor
@Test("기본 정보 단계에서 제목이 비어 있으면 다음 단계로 이동하지 않는다")
func newTaskStepValidationBlocksEmptyTitle() async {
    let store = TestStore(initialState: NewTaskFeature.State()) {
        NewTaskFeature()
    }

    await store.send(.nextStepTapped) {
        $0.stepValidationError = .emptyTitle
    }
}

@MainActor
@Test("제목이 입력되면 기본 정보 단계에서 사진 단계로 이동한다")
func newTaskStepMovesToPhotoWhenTitleIsValid() async {
    var initialState = NewTaskFeature.State()
    initialState.title = "매일 10분 독서"
    initialState.lastAcceptedTitle = "매일 10분 독서"

    let store = TestStore(initialState: initialState) {
        NewTaskFeature()
    }

    await store.send(.nextStepTapped) {
        $0.currentStep = .photo
    }
}

@MainActor
@Test("사진이 선택되면 사진 단계에서 알림 확인 단계로 이동한다")
func newTaskStepMovesToAlarmConfirmWhenPhotoExists() async {
    var initialState = NewTaskFeature.State()
    initialState.title = "매일 물 마시기"
    initialState.lastAcceptedTitle = "매일 물 마시기"
    initialState.currentStep = .photo
    initialState.image = UIImage(systemName: "photo")

    let store = TestStore(initialState: initialState) {
        NewTaskFeature()
    }

    await store.send(.nextStepTapped) {
        $0.currentStep = .alarmConfirm
    }
}

@MainActor
@Test("초안이 비어 있으면 취소 시 바로 닫는다")
func newTaskCancelWithoutDraftDismissesImmediately() async {
    let store = TestStore(initialState: NewTaskFeature.State()) {
        NewTaskFeature()
    }

    await store.send(.cancelButtonTapped)
    await store.receive(\.delegate.cancelled)
}

@MainActor
@Test("초안 작성 중 취소하면 확인 alert를 먼저 보여준다")
func newTaskCancelWithDraftShowsConfirmationAlert() async {
    var initialState = NewTaskFeature.State()
    initialState.title = "매일 산책"
    initialState.lastAcceptedTitle = "매일 산책"

    let store = TestStore(initialState: initialState) {
        NewTaskFeature()
    }

    await store.send(.cancelButtonTapped) {
        $0.alert = .discardDraft()
    }
}

@MainActor
@Test("초안 취소 alert에서 그만두기를 누르면 닫는다")
func newTaskDiscardDraftConfirmationDismisses() async {
    var initialState = NewTaskFeature.State()
    initialState.title = "매일 산책"
    initialState.lastAcceptedTitle = "매일 산책"
    initialState.alert = .discardDraft()

    let store = TestStore(initialState: initialState) {
        NewTaskFeature()
    }

    await store.send(.alert(.presented(.confirmDiscard))) {
        $0.alert = nil
        $0.isDiscardingDraft = true
    }
    await store.receive(\.delegate.cancelled)
}

@MainActor
@Test("초안 취소 확정 중 취소 액션이 다시 들어와도 alert를 다시 열지 않는다")
func newTaskDiscardConfirmationIgnoresReentrantCancel() async {
    var initialState = NewTaskFeature.State()
    initialState.title = "매일 산책"
    initialState.lastAcceptedTitle = "매일 산책"
    initialState.alert = .discardDraft()

    let store = TestStore(initialState: initialState) {
        NewTaskFeature()
    }

    await store.send(.alert(.presented(.confirmDiscard))) {
        $0.alert = nil
        $0.isDiscardingDraft = true
    }
    await store.receive(\.delegate.cancelled)
    await store.send(.cancelButtonTapped)
}
