import SwiftUI
import DesignSystem

struct HomeSummaryDashboardCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let presentation: HomeSummaryCardPresentation

    private var metricGap: CGFloat { 10.jsScaled() }
    private var innerPadding: CGFloat { 14.jsScaled() }
    private var innerRadius: CGFloat { 18.jsScaled() }
    private var primaryMetricHeight: CGFloat { 148.jsScaled() }
    private var secondaryMetricHeight: CGFloat {
        (primaryMetricHeight - metricGap) / 2
    }

    var body: some View {
        JSCard(style: .elevated, padding: .jsMD) {
            VStack(alignment: .leading, spacing: .jsSM) {
                header

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: metricGap) {
                        primaryMetric
                        progressMetric
                        completionMetric
                    }
                } else {
                    HStack(alignment: .top, spacing: metricGap) {
                        primaryMetric

                        VStack(spacing: metricGap) {
                            progressMetric
                            completionMetric
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: .jsSM) {
                headerTitle
                Spacer(minLength: .jsSM)
                headerMeta(multilineAlignment: .trailing)
            }

            VStack(alignment: .leading, spacing: .jsMicro) {
                headerTitle
                headerMeta(multilineAlignment: .leading)
            }
        }
    }

    private var headerTitle: some View {
        Text("오늘 포커스")
            .font(.jsHeadlineSmall)
            .foregroundColor(.labelStrong)
    }

    private func headerMeta(multilineAlignment: TextAlignment) -> some View {
        Text(presentation.headerMeta)
            .font(.jsLabelMedium)
            .foregroundColor(.labelNeutral)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
            .multilineTextAlignment(multilineAlignment)
    }

    private var primaryMetric: some View {
        VStack(alignment: .leading, spacing: 8.jsScaled()) {
            Text(presentation.primaryTitle)
                .font(.jsLabelSmall)
                .foregroundColor(.labelNeutral)

            Text(presentation.primaryValue)
                .font(.jsDisplaySmall)
                .foregroundColor(presentation.primaryTone.color)
                .monospacedDigit()

            Spacer(minLength: .jsXS)

            Text(presentation.primarySupport)
                .font(.jsLabelMedium)
                .foregroundColor(.labelNeutral)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .multilineTextAlignment(.leading)
        }
        .padding(innerPadding)
        .frame(
            maxWidth: .infinity,
            minHeight: dynamicTypeSize.isAccessibilitySize ? nil : primaryMetricHeight,
            alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: innerRadius)
                .fill(Color.primaryNormal.opacity(0.08))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(presentation.primaryTitle)
        .accessibilityValue("\(presentation.primaryValue). \(presentation.primarySupport)")
    }

    private var progressMetric: some View {
        secondaryMetric(
            title: presentation.progressTitle,
            value: presentation.progressValue,
            tint: .labelStrong
        )
    }

    private var completionMetric: some View {
        secondaryMetric(
            title: presentation.completionTitle,
            value: presentation.completionValue,
            tint: .positive
        )
    }

    private func secondaryMetric(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: .jsMicro) {
            Text(title)
                .font(.jsLabelSmall)
                .foregroundColor(.labelNeutral)

            Spacer(minLength: .jsXS)

            Text(value)
                .font(.jsHeadlineSmall)
                .foregroundColor(tint)
                .monospacedDigit()
        }
        .padding(innerPadding)
        .frame(
            maxWidth: .infinity,
            minHeight: dynamicTypeSize.isAccessibilitySize ? nil : secondaryMetricHeight,
            alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: innerRadius)
                .fill(Color.backgroundAlternative)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}

struct HomeSummaryDashboardSkeleton: View {
    private var metricGap: CGFloat { 10.jsScaled() }
    private var innerPadding: CGFloat { 14.jsScaled() }
    private var innerRadius: CGFloat { 18.jsScaled() }
    private var primaryMetricHeight: CGFloat { 148.jsScaled() }
    private var secondaryMetricHeight: CGFloat {
        (primaryMetricHeight - metricGap) / 2
    }

    var body: some View {
        JSCard(style: .elevated, padding: .jsMD) {
            VStack(alignment: .leading, spacing: .jsSM) {
                HStack(alignment: .firstTextBaseline, spacing: .jsSM) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 72.jsScaled(), height: 20.jsScaled())
                        .skeleton(shape: RoundedRectangle(cornerRadius: 8))

                    Spacer(minLength: .jsSM)

                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 144.jsScaled(), height: 14.jsScaled())
                        .skeleton(shape: RoundedRectangle(cornerRadius: 6))
                }

                HStack(alignment: .top, spacing: metricGap) {
                    VStack(alignment: .leading, spacing: 8.jsScaled()) {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 52.jsScaled(), height: 12.jsScaled())
                            .skeleton(shape: RoundedRectangle(cornerRadius: 4))

                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 64.jsScaled(), height: 28.jsScaled())
                            .skeleton(shape: RoundedRectangle(cornerRadius: 8))

                        Spacer(minLength: .jsXS)

                        RoundedRectangle(cornerRadius: 4)
                            .frame(maxWidth: .infinity)
                            .frame(height: 12.jsScaled())
                            .skeleton(shape: RoundedRectangle(cornerRadius: 4))

                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 120.jsScaled(), height: 12.jsScaled())
                            .skeleton(shape: RoundedRectangle(cornerRadius: 4))
                    }
                    .padding(innerPadding)
                    .frame(maxWidth: .infinity, minHeight: primaryMetricHeight, alignment: .topLeading)
                    .background(
                        RoundedRectangle(cornerRadius: innerRadius)
                            .fill(Color.skeletonBase.opacity(0.52))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: innerRadius)
                            .stroke(Color.skeletonHighlight.opacity(0.2), lineWidth: 1)
                    )

                    VStack(spacing: metricGap) {
                        secondarySkeleton
                        secondarySkeleton
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var secondarySkeleton: some View {
        VStack(alignment: .leading, spacing: .jsMicro) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 44.jsScaled(), height: 12.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 4))

            Spacer(minLength: .jsXS)

            RoundedRectangle(cornerRadius: 6)
                .frame(width: 56.jsScaled(), height: 20.jsScaled())
                .skeleton(shape: RoundedRectangle(cornerRadius: 6))
        }
        .padding(innerPadding)
        .frame(maxWidth: .infinity, minHeight: secondaryMetricHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: innerRadius)
                .fill(Color.skeletonBase.opacity(0.52))
        )
        .overlay(
            RoundedRectangle(cornerRadius: innerRadius)
                .stroke(Color.skeletonHighlight.opacity(0.2), lineWidth: 1)
        )
    }
}

struct HomeSummaryCardPresentation: Equatable {
    enum PrimaryTone: Equatable {
        case neutral
        case brand
        case positive

        var color: Color {
            switch self {
            case .neutral:
                return .labelNeutral
            case .brand:
                return .primaryStrong
            case .positive:
                return .positive
            }
        }
    }

    let headerMeta: String
    let primaryTitle: String
    let primaryValue: String
    let primarySupport: String
    let primaryTone: PrimaryTone
    let progressTitle: String
    let progressValue: String
    let completionTitle: String
    let completionValue: String

    init(
        todayFocusState: HomeFeature.State.TodayFocusState,
        pendingCount: Int,
        completedCount: Int,
        overallProgressText: String,
        isStale: Bool
    ) {
        self.primaryTitle = "남은 작심"
        self.primaryValue = "\(pendingCount)개"
        self.progressTitle = "진행률"
        self.progressValue = overallProgressText
        self.completionTitle = "오늘 인증"
        self.completionValue = "\(completedCount)개"

        let headerMeta: String
        let primarySupport: String
        let primaryTone: PrimaryTone

        switch todayFocusState {
        case .empty:
            headerMeta = "오늘 이어갈 작심이 아직 없어요"
            primarySupport = "새 작심을 만들면 오늘 포커스가 바로 채워집니다"
            primaryTone = .neutral
        case .pending:
            if pendingCount == 1 {
                headerMeta = "오늘 마지막 작심 1개"
                primarySupport = "오늘 마지막으로 확인할 작심이 하나 남아 있어요"
            } else {
                headerMeta = "남은 작심 \(pendingCount)개"
                primarySupport = "오늘 인증 전인 작심이 \(pendingCount)개 남아 있어요"
            }
            primaryTone = .brand
        case .completedStageReady:
            headerMeta = "다음 단계 확인"
            primarySupport = "오늘 단계는 마쳤고 다음 단계를 이어갈 수 있어요"
            primaryTone = .brand
        case .allDoneToday:
            headerMeta = "오늘 인증 완료"
            primarySupport = "오늘 할 일은 모두 끝났어요"
            primaryTone = .positive
        }

        self.headerMeta = isStale ? "연결이 안정되면 최신 상태로 다시 바뀝니다" : headerMeta
        self.primarySupport = isStale ? "현재 보이는 수치는 마지막으로 불러온 기록 기준입니다" : primarySupport
        self.primaryTone = primaryTone
    }
}
