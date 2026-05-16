import SwiftUI
import Domain
import DSKit

struct HomeHeaderSection: View {
    let todayLabel: String
    let displayName: String
    let onSettingsTap: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: .jsXS) {
                Text("안녕하세요, \(displayName)")
                    .font(.jsSerifDisplay)
                    .foregroundColor(.labelStrong)
                    .lineLimit(2)

                Text(todayLabel)
                    .font(.jsMonoSmall)
                    .foregroundColor(.labelAlternative)
                    .padding(.horizontal, .jsSM)
                    .padding(.vertical, .jsMicro)
                    .background(
                        Capsule()
                            .fill(Color.surfaceElevated.opacity(0.34))
                    )
            }

            Spacer()

            Button(action: onSettingsTap) {
                Image(systemName: "gearshape.fill")
                    .font(.jsHeadlineLarge)
                    .foregroundColor(.labelAlternative)
                    .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
            }
            .buttonStyle(.plain)
            .zIndex(10)
        }
        .padding(.horizontal, .jsXL)
        .padding(.top, .jsXS)
    }
}

struct HomeSummaryCardSection: View {
    let activeTaskCount: Int
    let overallProgress: Double
    let todayCompletedCount: Int

    var body: some View {
        RedesignSectionCard(
            title: "오늘 할 일",
            subtitle: "인증 가능한 작심 \(activeTaskCount)개"
        ) {
            HStack(spacing: .jsSM) {
                HomeSummaryMetricView(
                    title: "전체 진행",
                    value: "\(Int(overallProgress * 100))%",
                    color: .primaryNormal
                )
                HomeSummaryMetricView(
                    title: "오늘 완료",
                    value: "\(todayCompletedCount)개",
                    color: .positive
                )
                HomeSummaryMetricView(
                    title: "남은 항목",
                    value: "\(max(0, activeTaskCount - todayCompletedCount))개",
                    color: .cautionary
                )
            }
        }
        .padding(.horizontal, .jsXL)
    }
}

struct HomeHeroTaskSection: View {
    let task: Domain.Task
    let onTap: () -> Void
    let onPrimaryTap: () -> Void

    private var dateRange: String {
        "\(task.startDate.formatted(.dateTime.month().day())) ~ \(task.endDate.formatted(.dateTime.month().day()))"
    }

    var body: some View {
        JSGlassCard(accessibilityLabel: "오늘의 작심 \(task.title)") {
            VStack(alignment: .leading, spacing: .jsLG) {
                HStack(alignment: .center, spacing: .jsLG) {
                    JSStageRing(
                        currentDays: task.completedDays,
                        targetDays: max(task.dayArray.count, 1),
                        stageType: jsStageType(for: task),
                        accessibilityLabel: "\(task.completedDays)일 완료, 전체 \(task.dayArray.count)일"
                    )
                    .frame(width: 132.jsScaled(), height: 132.jsScaled())

                    VStack(alignment: .leading, spacing: .jsSM) {
                        Text("오늘의 작심")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)

                        Text(task.title)
                            .font(.jsSerifTitle)
                            .foregroundColor(.labelStrong)
                            .lineLimit(2)

                        Text(dateRange)
                            .font(.jsMonoSmall)
                            .foregroundColor(.labelNeutral)

                        Button(action: onPrimaryTap) {
                            Text(task.isCompleted(on: Date()) ? "오늘 기록 보기 →" : "오늘 인증하기 →")
                                .font(.jsButtonMedium)
                                .foregroundColor(.backgroundNormal)
                                .padding(.horizontal, .jsMD)
                                .padding(.vertical, .jsXS)
                                .background(
                                    Capsule()
                                        .fill(Color.forestAccent)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(task.isCompleted(on: Date()) ? "오늘 기록 보기" : "오늘 인증하기")
                    }
                }
            }
        }
        .onTapGesture(perform: onTap)
        .frame(maxWidth: .infinity)
    }

    private func jsStageType(for task: Domain.Task) -> JSStageRing.StageType {
        let days = task.currentStage?.durationDays ?? task.stages.last?.durationDays ?? task.dayArray.count
        return JSStageRing.StageType(rawValue: days) ?? .seven
    }
}

struct HomeStreakHeatmapSection: View {
    let task: Domain.Task

    var body: some View {
        JSGlassCard(accessibilityLabel: "최근 84일 작심 히트맵") {
            VStack(alignment: .leading, spacing: .jsMD) {
                HStack {
                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text("이어온 기록")
                            .font(.jsSerifTitle)
                            .foregroundColor(.labelStrong)

                        Text("최근 84일 인증 흐름")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                    }

                    Spacer()

                    Text("\(task.completedDays)")
                        .font(.jsMonoMedium)
                        .foregroundColor(.forestAccent)
                }

                JSStreakHeatmap(states: heatmapStates)
            }
        }
    }

    private var heatmapStates: [Date: StreakState] {
        let calendar = Calendar.current
        return Dictionary(uniqueKeysWithValues: task.records.map { record in
            let state: StreakState = record.check ? .completed : .empty
            return (calendar.startOfDay(for: record.date), state)
        })
    }
}

enum HomeFocusActionState {
    case pending
    case completedStageReady
    case allDoneToday
    case failed

    var primaryTitle: String {
        switch self {
        case .pending:
            return "오늘 인증하기"
        case .completedStageReady:
            return "다음 단계 보기"
        case .allDoneToday:
            return "오늘 기록 보기"
        case .failed:
            return "재도전 보기"
        }
    }

    var secondaryTitle: String {
        switch self {
        case .completedStageReady:
            return "기록 보기"
        default:
            return "상세 보기"
        }
    }
}

struct HomeFocusActionRow: View {
    let state: HomeFocusActionState
    let onPrimaryTap: () -> Void
    let onSecondaryTap: () -> Void

    var body: some View {
        HStack(spacing: .jsSM) {
            JSButton(
                title: state.primaryTitle,
                style: .primary,
                size: .medium,
                action: onPrimaryTap
            )

            JSButton(
                title: state.secondaryTitle,
                style: .secondary,
                size: .medium,
                action: onSecondaryTap
            )
        }
    }
}

struct HomeMiniCardsSection: View {
    let cards: [JSMiniHeroCardData]
    let onAllTasksTap: () -> Void
    let onCardTap: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            HStack {
                Text("진행 중인 작심들")
                    .font(.jsHeadlineMedium)
                    .foregroundColor(.labelStrong)

                Spacer()

                Button(action: onAllTasksTap) {
                    Text("전체보기")
                        .font(.jsButtonSmall)
                        .foregroundColor(.labelAlternative)
                }
            }
            .padding(.horizontal, .jsXL)

            JSMiniHeroCardCarousel(
                cards: cards,
                onCardTap: onCardTap
            )
            .padding(.horizontal, 0)
        }
    }
}

struct HomeEmptyStateSection: View {
    var body: some View {
        VStack(spacing: .jsXL) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.jsDisplayScaledBold(size: 56))
                .foregroundColor(Color.forestAccent)

            VStack(spacing: .jsXS) {
                Text("첫 작심을 만들어보세요")
                    .font(.jsSerifTitle)
                    .foregroundColor(.labelStrong)

                Text("아래 가운데 + 버튼에서 작게 시작할 수 있어요")
                    .font(.jsBodySmall)
                    .foregroundColor(.labelAlternative)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: 24.jsScaled())
                .fill(Color.surfaceElevated.opacity(0.3))
                .shadow(color: Color.labelStrong.opacity(0.05), radius: 10.jsScaled(), x: 0, y: 4.jsScaled())
        )
    }
}

struct HomeSkeletonSection: View {
    let showsSummary: Bool
    let showsMiniCards: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24.jsScaled()) {
            if showsSummary {
                HomeSummarySkeletonSection()
            }

            JSHeroCardSkeleton()
                .padding(.horizontal, 24.jsScaled())

            if showsMiniCards {
                VStack(alignment: .leading, spacing: 16.jsScaled()) {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 140.jsScaled(), height: 20.jsScaled())
                            .skeleton(shape: RoundedRectangle(cornerRadius: 8))

                        Spacer()

                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 60.jsScaled(), height: 16.jsScaled())
                            .skeleton(shape: RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.horizontal, 24.jsScaled())

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12.jsScaled()) {
                            JSMiniCardSkeleton()
                            JSMiniCardSkeleton()
                            JSMiniCardSkeleton()
                        }
                        .padding(.horizontal, 20.jsScaled())
                        .padding(.vertical, 4.jsScaled())
                    }
                    .frame(height: 200.jsScaled())
                    .padding(.horizontal, 0)
                }
            }
        }
    }
}

private struct HomeSummaryMetricView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: .jsMicro) {
            Text(title)
                .font(.jsLabelSmall)
                .foregroundColor(.labelAlternative)
            Text(value)
                .font(.jsMonoSmall)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, minHeight: 72.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(color.opacity(0.08))
        )
    }
}

private struct HomeSummarySkeletonSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 72.jsScaled(), height: 20.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 8))

            RoundedRectangle(cornerRadius: 6)
                .frame(width: 160.jsScaled(), height: 14.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 6))

            HStack(spacing: .jsSM) {
                HomeSummaryMetricSkeletonView()
                HomeSummaryMetricSkeletonView()
                HomeSummaryMetricSkeletonView()
            }
            .padding(.top, .jsXS)
        }
        .padding(.jsMD)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.backgroundStrong)
        )
        .padding(.horizontal, .jsXL)
    }
}

private struct HomeSummaryMetricSkeletonView: View {
    var body: some View {
        VStack(spacing: .jsMicro) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 44.jsScaled(), height: 12.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 4))

            RoundedRectangle(cornerRadius: 6)
                .frame(width: 52.jsScaled(), height: 20.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 6))
        }
        .frame(maxWidth: .infinity, minHeight: 72.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(Color.backgroundAlternative)
        )
    }
}
