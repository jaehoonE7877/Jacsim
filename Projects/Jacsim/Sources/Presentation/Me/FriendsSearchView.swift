import DSKit
import SwiftUI

public struct FriendsSearchView: View {
    @Bindable var model: FriendsSearchModel
    @State private var toastPresented = false

    public init(model: FriendsSearchModel) {
        self.model = model
    }

    public var body: some View {
        ZStack {
            LinearGradient.wallpaperForest
                .ignoresSafeArea()
            Color.backgroundNormal.opacity(0.16)
                .ignoresSafeArea()

            VStack(spacing: .jsMD) {
                JSGlassSearchField(
                    text: $model.query,
                    placeholder: "친구 검색",
                    accessibilityLabel: "친구 검색"
                )
                .padding(.horizontal, .jsMD)
                .onChange(of: model.query) { _, _ in
                    model.queryChanged()
                }

                ScrollView {
                    LazyVStack(spacing: .jsSM) {
                        ForEach(model.rows) { row in
                            friendRow(row)
                        }
                    }
                    .padding(.horizontal, .jsMD)
                }
            }
            .padding(.top, .jsMD)
        }
        .navigationTitle("친구 찾기")
        .navigationBarTitleDisplayMode(.inline)
        .jsGlassNavBar()
        .onAppear {
            model.queryChanged()
        }
        .onChange(of: model.toastMessage) { _, message in
            toastPresented = message != nil
        }
        .jsGlassToast(text: $model.toastMessage, isPresented: $toastPresented)
    }

    private func friendRow(_ row: FriendSearchRow) -> some View {
        JSGlassCard(accessibilityLabel: "\(row.user.displayName) 친구 행") {
            HStack(spacing: .jsMD) {
                NavigationLink {
                    FriendProfileView(userID: row.user.id, dependencies: model.dependencies)
                } label: {
                    HStack(spacing: .jsMD) {
                        Circle()
                            .fill(Color.forestAccent.opacity(0.18))
                            .frame(width: 44.jsScaled(), height: 44.jsScaled())
                            .overlay {
                                Text(String(row.user.displayName.prefix(1)))
                                    .font(.jsSerifTitle)
                                    .foregroundStyle(Color.forestAccent)
                            }

                        VStack(alignment: .leading, spacing: .jsMicro) {
                            Text(row.user.displayName)
                                .font(.jsBodyMedium)
                                .foregroundStyle(Color.labelStrong)
                            Text("@\(row.user.handle)")
                                .font(.jsMonoSmall)
                                .foregroundStyle(Color.labelAlternative)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(row.user.displayName) 프로필 열기")

                Spacer(minLength: .jsXS)

                Button {
                    model.followTapped(row)
                } label: {
                    Text(row.state.title)
                        .font(.jsLabelMedium)
                        .foregroundStyle(row.state == .follow ? Color.backgroundNormal : Color.labelAlternative)
                        .padding(.horizontal, .jsSM)
                        .padding(.vertical, .jsXS)
                        .background(
                            Capsule()
                                .fill(row.state == .follow ? Color.forestAccent : Color.surfaceElevated.opacity(0.36))
                        )
                }
                .buttonStyle(.plain)
                .disabled(row.state != .follow)
                .accessibilityLabel("\(row.user.displayName) \(row.state.title)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        FriendsSearchView(model: FriendsSearchModel(dependencies: .test))
    }
}
