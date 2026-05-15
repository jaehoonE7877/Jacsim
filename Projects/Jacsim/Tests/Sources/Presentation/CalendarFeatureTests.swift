import Foundation
import Testing
import ComposableArchitecture

@testable import Jacsim

@MainActor
@Test("캘린더 날짜 버튼은 현재 선택 날짜로 바텀시트를 연다")
func calendarDatePickerButtonOpensWithSelectedDate() async {
    let selectedDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 2)) ?? Date()

    var initialState = CalendarFeature.State()
    initialState.selectedDate = selectedDate

    let store = TestStore(initialState: initialState) {
        CalendarFeature()
    }

    await store.send(.datePickerButtonTapped) {
        $0.datePickerDate = selectedDate
        $0.isDatePickerPresented = true
    }
}

@MainActor
@Test("캘린더 날짜 선택 확정은 선택 날짜를 갱신하고 바텀시트를 닫는다")
func calendarDatePickerConfirmUpdatesSelectedDate() async {
    let selectedDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 2)) ?? Date()
    let nextDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 10)) ?? Date()

    var initialState = CalendarFeature.State()
    initialState.selectedDate = selectedDate
    initialState.datePickerDate = nextDate
    initialState.isDatePickerPresented = true

    let store = TestStore(initialState: initialState) {
        CalendarFeature()
    }

    await store.send(.datePickerConfirmed) {
        $0.selectedDate = nextDate
        $0.isDatePickerPresented = false
    }
}

@MainActor
@Test("캘린더 날짜 선택 취소는 기존 선택 날짜를 유지한다")
func calendarDatePickerDismissKeepsSelectedDate() async {
    let selectedDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 2)) ?? Date()
    let draftDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 10)) ?? Date()

    var initialState = CalendarFeature.State()
    initialState.selectedDate = selectedDate
    initialState.datePickerDate = draftDate
    initialState.isDatePickerPresented = true

    let store = TestStore(initialState: initialState) {
        CalendarFeature()
    }

    await store.send(.datePickerDismissed) {
        $0.datePickerDate = selectedDate
        $0.isDatePickerPresented = false
    }
}
