import Testing
import UIKit

@testable import Jacsim

@MainActor
@Test("기본 정보 단계에서 제목이 비어 있으면 다음 단계로 이동하지 않는다")
func newTaskStepValidationBlocksEmptyTitle() {
    let model = NewTaskModel(dependencies: .test)

    model.nextStepTapped()

    #expect(model.stepValidationError == .emptyTitle)
}

@MainActor
@Test("제목이 입력되면 기본 정보 단계에서 사진 단계로 이동한다")
func newTaskStepMovesToPhotoWhenTitleIsValid() {
    let model = NewTaskModel(dependencies: .test)
    model.title = "매일 10분 독서"

    model.nextStepTapped()

    #expect(model.currentStep == .photo)
}

@MainActor
@Test("사진이 선택되면 사진 단계에서 알림 확인 단계로 이동한다")
func newTaskStepMovesToAlarmConfirmWhenPhotoExists() {
    let model = NewTaskModel(dependencies: .test)
    model.title = "매일 물 마시기"
    model.currentStep = .photo
    model.image = UIImage(systemName: "photo")

    model.nextStepTapped()

    #expect(model.currentStep == .alarmConfirm)
}

@MainActor
@Test("초안이 비어 있으면 취소 시 바로 닫는다")
func newTaskCancelWithoutDraftDismissesImmediately() {
    var didCancel = false
    let model = NewTaskModel(
        dependencies: .test,
        onCancelled: { didCancel = true }
    )

    model.cancelButtonTapped()

    #expect(didCancel)
}

@MainActor
@Test("초안 작성 중 취소하면 확인 alert를 먼저 보여준다")
func newTaskCancelWithDraftShowsConfirmationAlert() {
    let model = NewTaskModel(dependencies: .test)
    model.title = "매일 산책"

    model.cancelButtonTapped()

    #expect(model.isDiscardAlertPresented)
}

@MainActor
@Test("초안 취소 alert에서 그만두기를 누르면 닫는다")
func newTaskDiscardDraftConfirmationDismisses() {
    var didCancel = false
    let model = NewTaskModel(
        dependencies: .test,
        onCancelled: { didCancel = true }
    )
    model.title = "매일 산책"
    model.isDiscardAlertPresented = true

    model.confirmDiscardDraft()

    #expect(model.isDiscardAlertPresented == false)
    #expect(model.isDiscardingDraft)
    #expect(didCancel)
}

@MainActor
@Test("초안 취소 확정 중 취소 액션이 다시 들어와도 alert를 다시 열지 않는다")
func newTaskDiscardConfirmationIgnoresReentrantCancel() {
    var cancelCount = 0
    let model = NewTaskModel(
        dependencies: .test,
        onCancelled: { cancelCount += 1 }
    )
    model.title = "매일 산책"
    model.isDiscardAlertPresented = true

    model.confirmDiscardDraft()
    model.cancelButtonTapped()

    #expect(cancelCount == 1)
    #expect(model.isDiscardAlertPresented == false)
}
