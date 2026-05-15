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
                    .fill(Color.primaryNormal)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: .primaryNormal.opacity(0.26), radius: 14.jsScaled(), x: 0, y: 8.jsScaled())
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

            Spacer(minLength: .jsXS)

            Text(todayLabel)
                .font(.jsLabelMedium)
                .foregroundColor(.labelAlternative)
                .padding(.horizontal, .jsSM)
                .padding(.vertical, .jsMicro)
                .background(
                    Capsule()
                        .fill(Color.backgroundAlternative)
                )

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
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: .jsXL) {
            Image(systemName: "square.text.square.fill")
                .font(.jsDisplayScaledBold(size: 64))
                .foregroundColor(Color.labelAssistive)

            VStack(spacing: .jsXS) {
                Text("진행 중인 작심이 없어요")
                    .font(.jsHeadlineMedium)
                    .foregroundColor(.labelStrong)

                Text("새로운 작심을 시작해보세요!")
                    .font(.jsBodySmall)
                    .foregroundColor(.labelAlternative)
            }

            Button(action: onStart) {
                Text("작심 시작하기")
                    .font(.jsButtonMedium)
                    .foregroundColor(.white)
                    .frame(height: 50.jsScaled())
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryNormal)
                    .cornerRadius(.jsRadiusMD)
            }
            .padding(.horizontal, .jsXL)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40.jsScaled())
        .background(
            RoundedRectangle(cornerRadius: 24.jsScaled())
                .fill(Color.backgroundStrong)
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
                .font(.jsHeadlineSmall)
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
