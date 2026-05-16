import SwiftUI
import Domain
import DSKit

struct HomeFloatingAddButton: View {
    let isExpanded: Bool
    let isHidden: Bool
    let reduceMotion: Bool
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: .jsXS) {
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)

                if isExpanded {
                    Text("새 작심")
                        .font(.jsButtonMedium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .frame(height: height)
            .padding(.horizontal, isExpanded ? .jsLG : .jsMD)
            .background(
                Capsule()
                    .fill(Color.v2BrandBlue)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: .v2BrandBlue.opacity(0.26), radius: 14.jsScaled(), x: 0, y: 8.jsScaled())
            .contentShape(Capsule())
        }
        .pressEffect()
        .opacity(isHidden ? 0 : 1)
        .scaleEffect(isHidden ? 0.92 : 1)
        .offset(y: isHidden ? 24.jsScaled() : 0)
        .allowsHitTesting(!isHidden)
        .accessibilityHidden(isHidden)
        .animation(
            reduceMotion ? .none : .spring(response: 0.28, dampingFraction: 0.88),
            value: isHidden
        )
        .animation(
            reduceMotion ? .none : .spring(response: 0.28, dampingFraction: 0.88),
            value: isExpanded
        )
        .accessibilityLabel("새 작심 만들기")
        .accessibilityHint("새 작심 추가 화면을 엽니다")
    }
}

struct HomeHeaderSection: View {
    let todayLabel: String
    let onSettingsTap: () -> Void

    var body: some View {
        HStack {
            Text("작심")
                .font(.jsDisplayMedium)
                .foregroundColor(.labelStrong)
                .lineLimit(1)
                .minimumScaleFactor(0.86)

            Spacer()

            Text(todayLabel)
                .font(.jsLabelMedium)
                .foregroundColor(.v2BrandBlue)
                .lineLimit(1)
                .padding(.horizontal, .jsSM)
                .padding(.vertical, .jsMicro)
                .background(
                    Capsule()
                        .fill(Color.v2BrandBlueSoft)
                )
                .accessibilityLabel("오늘 \(todayLabel)")

            Button(action: onSettingsTap) {
                Image(systemName: "gearshape.fill")
                    .font(.jsHeadlineLarge)
                    .foregroundColor(.labelAlternative)
                    .frame(width: 44.jsScaled(.touchTarget), height: 44.jsScaled(.touchTarget))
            }
            .buttonStyle(.plain)
            .zIndex(10)
            .accessibilityLabel("설정")
            .accessibilityHint("설정 화면으로 이동합니다")
        }
        .padding(.horizontal, .jsXL)
        .padding(.top, .jsXS)
    }
}

struct HomeSummaryCardSection: View {
    let activeTaskCount: Int
    let overallProgress: Double
    let todayCompletedCount: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            JSV2SectionHeader("오늘 흐름")
            metrics
        }
        .padding(.horizontal, .jsXL)
    }

    @ViewBuilder
    private var metrics: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: .jsSM) {
                JSV2MetricPill(
                    title: "전체 진행",
                    value: "\(Int(overallProgress * 100))%",
                    systemImage: "chart.line.uptrend.xyaxis",
                    style: .accent
                )
                JSV2MetricPill(
                    title: "오늘 완료",
                    value: "\(todayCompletedCount)개",
                    systemImage: "checkmark.circle.fill",
                    style: .success
                )
                JSV2MetricPill(
                    title: "남은 인증",
                    value: "\(max(0, activeTaskCount - todayCompletedCount))개",
                    systemImage: "camera.fill",
                    style: .warning
                )
            }
        } else {
            HStack(spacing: .jsSM) {
                JSV2MetricPill(
                    title: "전체 진행",
                    value: "\(Int(overallProgress * 100))%",
                    systemImage: "chart.line.uptrend.xyaxis",
                    style: .accent
                )
                JSV2MetricPill(
                    title: "오늘 완료",
                    value: "\(todayCompletedCount)개",
                    systemImage: "checkmark.circle.fill",
                    style: .success
                )
                JSV2MetricPill(
                    title: "남은 인증",
                    value: "\(max(0, activeTaskCount - todayCompletedCount))개",
                    systemImage: "camera.fill",
                    style: .warning
                )
            }
        }
    }
}

struct HomeHeroTaskSection: View {
    let task: Domain.Task
    let imageData: Data?
    let onTap: () -> Void

    private var heroImage: Image? {
        imageData.flatMap { UIImage(data: $0) }.map { Image(uiImage: $0) }
    }

    private var subtitle: String {
        "\(task.startDate.formatted(.dateTime.month().day())) ~ \(task.endDate.formatted(.dateTime.month().day()))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            JSUnifiedHeroCard(
                title: task.title,
                subtitle: subtitle,
                progress: task.progress,
                totalDays: task.dayArray.count,
                completedDays: task.completedDays,
                image: heroImage,
                isTodayCertified: task.isCompleted(on: Date()),
                onTap: onTap
            )
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
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
            return "인증하기"
        case .completedStageReady:
            return "다음 단계"
        case .allDoneToday:
            return "기록 보기"
        case .failed:
            return "재도전"
        }
    }

    var secondaryTitle: String {
        switch self {
        case .completedStageReady:
            return "기록"
        default:
            return "상세"
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
                systemImage: primarySystemImage,
                style: .primary,
                size: .medium,
                action: onPrimaryTap
            )
            .layoutPriority(1)

            JSButton(
                title: state.secondaryTitle,
                systemImage: "chevron.right",
                style: .ghost,
                size: .medium,
                action: onSecondaryTap
            )
            .frame(width: 104.jsScaled(.touchTarget))
        }
    }

    private var primarySystemImage: String {
        switch state {
        case .pending:
            return "camera.fill"
        case .completedStageReady:
            return "arrow.forward.circle.fill"
        case .allDoneToday:
            return "list.bullet.rectangle"
        case .failed:
            return "arrow.counterclockwise.circle.fill"
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
                Text("진행 중")
                    .font(.jsHeadlineMedium)
                    .foregroundColor(.labelStrong)

                Spacer()

                Button(action: onAllTasksTap) {
                    Text("전체")
                        .font(.jsButtonSmall)
                        .foregroundColor(.labelAlternative)
                }
                .frame(minWidth: .jsTouchTarget, minHeight: .jsTouchTarget)
                .contentShape(Rectangle())
                .accessibilityLabel("전체 작심 보기")
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
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: .jsXL) {
            Image(systemName: "flag.checkered")
                .font(.jsDisplayScaledBold(size: 64))
                .foregroundColor(Color.labelAssistive)
                .accessibilityHidden(true)

            VStack(spacing: .jsXS) {
                Text("첫 작심을 시작해요")
                    .font(.jsHeadlineMedium)
                    .foregroundColor(.labelStrong)
                    .multilineTextAlignment(.center)

                Text("작게 정하고 바로 인증하세요")
                    .font(.jsBodySmall)
                    .foregroundColor(.labelAlternative)
                    .multilineTextAlignment(.center)
            }

            JSButton(
                title: "시작하기",
                systemImage: "plus",
                style: .primary,
                size: .medium,
                action: onStart
            )
            .padding(.horizontal, .jsXL)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: 24.jsScaled())
                .fill(Color.v2Surface)
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
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(.jsHeadlineSmall)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, minHeight: 72.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD)
                .fill(color.opacity(0.08))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) \(value)")
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
