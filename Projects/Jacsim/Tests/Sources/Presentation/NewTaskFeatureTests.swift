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
@Test("저장 시 제목이 비어 있으면 기본 정보 단계로 되돌리고 오류를 노출한다")
func newTaskSaveRoutesBackToBasicInfoWhenTitleIsMissing() async {
    var initialState = NewTaskFeature.State()
    initialState.currentStep = .alarmConfirm
    initialState.image = UIImage(systemName: "photo")

    let store = TestStore(initialState: initialState) {
        NewTaskFeature()
    }

    await store.send(.saveButtonTapped) {
        $0.currentStep = .basicInfo
        $0.stepValidationError = .emptyTitle
    }
}

@MainActor
@Test("저장 시 대표 사진이 없으면 사진 단계로 되돌리고 오류를 노출한다")
func newTaskSaveRoutesBackToPhotoWhenImageIsMissing() async {
    var initialState = NewTaskFeature.State()
    initialState.title = "작심"
    initialState.lastAcceptedTitle = "작심"
    initialState.currentStep = .alarmConfirm

    let store = TestStore(initialState: initialState) {
        NewTaskFeature()
    }

    await store.send(.saveButtonTapped) {
        $0.currentStep = .photo
        $0.stepValidationError = .missingPhoto
    }
}

@MainActor
@Test("사진 선택은 사진 단계의 검증 오류를 해제한다")
func newTaskImageSelectionClearsPhotoValidationError() async {
    let image = UIImage(systemName: "photo")!
    var initialState = NewTaskFeature.State()
    initialState.currentStep = .photo
    initialState.stepValidationError = .missingPhoto

    let store = TestStore(initialState: initialState) {
        NewTaskFeature()
    }

    await store.send(.imageSelected(image)) {
        $0.image = image
        $0.saveFailed = false
        $0.stepValidationError = nil
    }
}
