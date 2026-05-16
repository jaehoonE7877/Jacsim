import DSKit
import SwiftUI
import WidgetKit

struct TodayJacsimEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
}

struct TodayJacsimProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayJacsimEntry {
        TodayJacsimEntry(date: Date(), tasks: WidgetPreviewData.tasks)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayJacsimEntry) -> Void) {
        completion(TodayJacsimEntry(date: Date(), tasks: WidgetDataProvider.fetchActiveTasks()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayJacsimEntry>) -> Void) {
        let entry = TodayJacsimEntry(date: Date(), tasks: WidgetDataProvider.fetchActiveTasks())
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct TodayJacsimWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TodayJacsimEntry

    var body: some View {
        JSWidgetSurface(size: family == .systemSmall ? .small : .medium, accessibilityLabel: "오늘의 작심 위젯") {
            VStack(alignment: .leading, spacing: .jsSM) {
                Text("오늘의 작심")
                    .font(.jsSerifTitle)
                    .foregroundStyle(Color.labelStrong)

                if entry.tasks.isEmpty {
                    emptyState
                } else {
                    ForEach(entry.tasks.prefix(family == .systemSmall ? 1 : 3)) { task in
                        Link(destination: task.url) {
                            taskRow(task)
                        }
                        .accessibilityLabel("\(task.title), \(task.dDay)일 남음")
                        .accessibilityHint("앱에서 작심 상세를 엽니다")
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient.wallpaperMorning
        }
        .widgetURL(entry.tasks.first?.url ?? URL(string: "jacsim://home")!)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: .jsXS) {
            Text("비어 있어요")
                .font(.jsBodyMedium)
                .foregroundStyle(Color.labelStrong)
            Text("오늘 이어갈 작심을 만들어보세요")
                .font(.jsLabelMedium)
                .foregroundStyle(Color.labelNeutral)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func taskRow(_ task: WidgetTask) -> some View {
        HStack(spacing: .jsSM) {
            JSStageRing(
                currentDays: task.currentDays,
                targetDays: task.targetDays,
                stageType: task.stageType,
                accessibilityLabel: "\(task.currentDays)일 완료"
            )
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.jsBodyMedium)
                    .foregroundStyle(Color.labelStrong)
                    .lineLimit(1)
                Text("D-\(task.dDay)")
                    .font(.jsMonoSmall)
                    .foregroundStyle(Color.forestAccent)
            }

            Spacer(minLength: 0)
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}

struct TodayJacsimWidget: Widget {
    let kind = "TodayJacsimWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayJacsimProvider()) { entry in
            TodayJacsimWidgetView(entry: entry)
        }
        .configurationDisplayName("오늘의 작심")
        .description("오늘 이어갈 작심과 남은 D-day를 보여줍니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
