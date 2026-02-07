import Testing
import ComposableArchitecture

@testable import Jacsim

@Test("리디자인 화면 플래그 기본값은 true")
func screenFlagDefaultEnabled() {
    withDependencies {
        $0.appPreferences = .inMemory()
    } operation: {
        PresentationRedesignFlags.resetAll()
        #expect(PresentationRedesignFlags.isEnabled(.home))
        #expect(PresentationRedesignFlags.isEnabled(.taskDetail))
    }
}

@Test("리디자인 화면 플래그 설정이 반영된다")
func screenFlagToggle() {
    withDependencies {
        $0.appPreferences = .inMemory()
    } operation: {
        PresentationRedesignFlags.resetAll()

        PresentationRedesignFlags.set(false, for: .calendar)
        #expect(PresentationRedesignFlags.isEnabled(.calendar) == false)

        PresentationRedesignFlags.set(true, for: .calendar)
        #expect(PresentationRedesignFlags.isEnabled(.calendar))
    }
}

@Test("리디자인 섹션 플래그 기본값은 true")
func sectionFlagDefaultEnabled() {
    withDependencies {
        $0.appPreferences = .inMemory()
    } operation: {
        PresentationRedesignFlags.resetAll()
        #expect(PresentationRedesignFlags.isSectionEnabled(.homeSummary))
        #expect(PresentationRedesignFlags.isSectionEnabled(.taskDetailRecordList))
    }
}

@Test("리디자인 섹션 플래그 설정과 초기화가 동작한다")
func sectionFlagToggleAndReset() {
    withDependencies {
        $0.appPreferences = .inMemory()
    } operation: {
        PresentationRedesignFlags.resetAll()

        PresentationRedesignFlags.setSection(false, for: .homeMiniCards)
        #expect(PresentationRedesignFlags.isSectionEnabled(.homeMiniCards) == false)

        PresentationRedesignFlags.resetAll()
        #expect(PresentationRedesignFlags.isSectionEnabled(.homeMiniCards))
    }
}
