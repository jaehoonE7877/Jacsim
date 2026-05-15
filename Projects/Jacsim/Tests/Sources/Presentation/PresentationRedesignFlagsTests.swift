import Testing

@testable import Jacsim

@MainActor
@Test("리디자인 화면 플래그 기본값은 true")
func screenFlagDefaultEnabled() {
    PresentationRedesignFlags.appPreferences = .inMemory()

    PresentationRedesignFlags.resetAll()

    #expect(PresentationRedesignFlags.isEnabled(.home))
    #expect(PresentationRedesignFlags.isEnabled(.taskDetail))
}

@MainActor
@Test("리디자인 화면 플래그 설정이 반영된다")
func screenFlagToggle() {
    PresentationRedesignFlags.appPreferences = .inMemory()

    PresentationRedesignFlags.resetAll()
    PresentationRedesignFlags.set(false, for: .calendar)

    #expect(PresentationRedesignFlags.isEnabled(.calendar) == false)

    PresentationRedesignFlags.set(true, for: .calendar)
    #expect(PresentationRedesignFlags.isEnabled(.calendar))
}

@MainActor
@Test("리디자인 섹션 플래그 기본값은 true")
func sectionFlagDefaultEnabled() {
    PresentationRedesignFlags.appPreferences = .inMemory()

    PresentationRedesignFlags.resetAll()

    #expect(PresentationRedesignFlags.isSectionEnabled(.homeSummary))
    #expect(PresentationRedesignFlags.isSectionEnabled(.taskDetailRecordList))
}

@MainActor
@Test("리디자인 섹션 플래그 설정과 초기화가 동작한다")
func sectionFlagToggleAndReset() {
    PresentationRedesignFlags.appPreferences = .inMemory()

    PresentationRedesignFlags.resetAll()
    PresentationRedesignFlags.setSection(false, for: .homeMiniCards)

    #expect(PresentationRedesignFlags.isSectionEnabled(.homeMiniCards) == false)

    PresentationRedesignFlags.resetAll()
    #expect(PresentationRedesignFlags.isSectionEnabled(.homeMiniCards))
}
