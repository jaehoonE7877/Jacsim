import WidgetKit
import SwiftUI

@main
struct JacsimWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayJacsimWidget()
        StreakWidget()
    }
}
