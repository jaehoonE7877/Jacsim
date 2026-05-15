import Foundation
import Testing

@testable import Jacsim

@MainActor
@Test("캘린더 날짜 버튼은 현재 선택 날짜로 바텀시트를 연다")
func calendarDatePickerButtonOpensWithSelectedDate() {
    let selectedDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 2)) ?? Date()
    let model = CalendarModel(dependencies: .test)
    model.selectedDate = selectedDate

    model.datePickerButtonTapped()

    #expect(model.datePickerDate == selectedDate)
    #expect(model.isDatePickerPresented)
}

@MainActor
@Test("캘린더 날짜 선택 확정은 선택 날짜를 갱신하고 바텀시트를 닫는다")
func calendarDatePickerConfirmUpdatesSelectedDate() {
    let selectedDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 2)) ?? Date()
    let nextDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 10)) ?? Date()
    let model = CalendarModel(dependencies: .test)
    model.selectedDate = selectedDate
    model.datePickerDate = nextDate
    model.isDatePickerPresented = true

    model.datePickerConfirmed()

    #expect(model.selectedDate == nextDate)
    #expect(model.isDatePickerPresented == false)
}

@MainActor
@Test("캘린더 날짜 선택 취소는 기존 선택 날짜를 유지한다")
func calendarDatePickerDismissKeepsSelectedDate() {
    let selectedDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 2)) ?? Date()
    let draftDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 10)) ?? Date()
    let model = CalendarModel(dependencies: .test)
    model.selectedDate = selectedDate
    model.datePickerDate = draftDate
    model.isDatePickerPresented = true

    model.datePickerDismissed()

    #expect(model.datePickerDate == selectedDate)
    #expect(model.selectedDate == selectedDate)
    #expect(model.isDatePickerPresented == false)
}
