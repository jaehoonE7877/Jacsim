import DSKit
import SwiftUI
import WidgetKit

struct StreakEntry: TimelineEntry {
    let date: Date
    let states: [Date: StreakState]
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), states: WidgetPreviewData.streakStates)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: Date(), states: WidgetDataProvider.fetchStreakStates()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = StreakEntry(date: Date(), states: WidgetDataProvider.fetchStreakStates())
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct StreakWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: StreakEntry

    var body: some View {
        JSWidgetSurface(size: family == .systemLarge ? .large : .medium, accessibilityLabel: "작심 연속 기록 위젯") {
            VStack(alignment: .leading, spacing: .jsMD) {
                VStack(alignment: .leading, spacing: .jsMicro) {
                    Text("84일 기록")
                        .font(.jsSerifTitle)
                        .foregroundStyle(Color.labelStrong)
                    Text("작게 이어온 날들")
                        .font(.jsLabelMedium)
                        .foregroundStyle(Color.labelNeutral)
                }

                JSStreakHeatmap(
                    states: entry.states,
                    endDate: entry.date,
                    accessibilityLabel: "최근 84일 작심 히트맵"
                )

                if family == .systemLarge {
                    Text("진한 칸일수록 인증이 쌓인 날이에요")
                        .font(.jsLabelMedium)
                        .foregroundStyle(Color.labelAlternative)
                }
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient.wallpaperForest
        }
        .widgetURL(URL(string: "jacsim://home")!)
    }
}

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("작심 연속 기록")
        .description("최근 84일 인증 흐름을 히트맵으로 보여줍니다.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
