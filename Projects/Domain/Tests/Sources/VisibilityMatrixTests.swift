import Domain
import Testing

@Test("profile owner")
func visibilityProfileOwner() {
    expectAlways(.profile, .owner, true)
}

@Test("profile mutual")
func visibilityProfileMutual() {
    expectAlways(.profile, .mutual, true)
}

@Test("profile oneWay")
func visibilityProfileOneWay() {
    expectAlways(.profile, .oneWay, true)
}

@Test("profile stranger")
func visibilityProfileStranger() {
    expectAlways(.profile, .stranger, true)
}

@Test("profile blocked")
func visibilityProfileBlocked() {
    expectAlways(.profile, .blocked, false)
}

@Test("taskList owner")
func visibilityTaskListOwner() {
    expectTaskScoped(.taskList, .owner, private: true, followers: true, public: true, nilVisibility: true)
}

@Test("taskList mutual")
func visibilityTaskListMutual() {
    expectTaskScoped(.taskList, .mutual, private: false, followers: true, public: true)
}

@Test("taskList oneWay")
func visibilityTaskListOneWay() {
    expectTaskScoped(.taskList, .oneWay, private: false, followers: true, public: true)
}

@Test("taskList stranger")
func visibilityTaskListStranger() {
    expectTaskScoped(.taskList, .stranger, private: false, followers: false, public: true)
}

@Test("taskList blocked")
func visibilityTaskListBlocked() {
    expectTaskScoped(.taskList, .blocked, private: false, followers: false, public: false)
}

@Test("taskDetail owner")
func visibilityTaskDetailOwner() {
    expectTaskScoped(.taskDetail, .owner, private: true, followers: true, public: true, nilVisibility: true)
}

@Test("taskDetail mutual")
func visibilityTaskDetailMutual() {
    expectTaskScoped(.taskDetail, .mutual, private: false, followers: true, public: true)
}

@Test("taskDetail oneWay")
func visibilityTaskDetailOneWay() {
    expectTaskScoped(.taskDetail, .oneWay, private: false, followers: true, public: true)
}

@Test("taskDetail stranger")
func visibilityTaskDetailStranger() {
    expectTaskScoped(.taskDetail, .stranger, private: false, followers: false, public: true)
}

@Test("taskDetail blocked")
func visibilityTaskDetailBlocked() {
    expectTaskScoped(.taskDetail, .blocked, private: false, followers: false, public: false)
}

@Test("streak owner")
func visibilityStreakOwner() {
    expectTaskScoped(.streak, .owner, private: true, followers: true, public: true, nilVisibility: true)
}

@Test("streak mutual")
func visibilityStreakMutual() {
    expectTaskScoped(.streak, .mutual, private: false, followers: true, public: true)
}

@Test("streak oneWay")
func visibilityStreakOneWay() {
    expectTaskScoped(.streak, .oneWay, private: false, followers: true, public: true)
}

@Test("streak stranger")
func visibilityStreakStranger() {
    expectTaskScoped(.streak, .stranger, private: false, followers: false, public: true)
}

@Test("streak blocked")
func visibilityStreakBlocked() {
    expectTaskScoped(.streak, .blocked, private: false, followers: false, public: false)
}

@Test("record owner")
func visibilityRecordOwner() {
    expectTaskScoped(.record, .owner, private: true, followers: true, public: true, nilVisibility: true)
}

@Test("record mutual")
func visibilityRecordMutual() {
    expectTaskScoped(.record, .mutual, private: false, followers: true, public: true)
}

@Test("record oneWay")
func visibilityRecordOneWay() {
    expectTaskScoped(.record, .oneWay, private: false, followers: false, public: true)
}

@Test("record stranger")
func visibilityRecordStranger() {
    expectTaskScoped(.record, .stranger, private: false, followers: false, public: true)
}

@Test("record blocked")
func visibilityRecordBlocked() {
    expectTaskScoped(.record, .blocked, private: false, followers: false, public: false)
}

@Test("bragPost owner")
func visibilityBragPostOwner() {
    expectTaskScoped(.bragPost, .owner, private: true, followers: true, public: true, nilVisibility: true)
}

@Test("bragPost mutual")
func visibilityBragPostMutual() {
    expectTaskScoped(.bragPost, .mutual, private: false, followers: true, public: true)
}

@Test("bragPost oneWay")
func visibilityBragPostOneWay() {
    expectTaskScoped(.bragPost, .oneWay, private: false, followers: true, public: true)
}

@Test("bragPost stranger")
func visibilityBragPostStranger() {
    expectTaskScoped(.bragPost, .stranger, private: false, followers: false, public: true)
}

@Test("bragPost blocked")
func visibilityBragPostBlocked() {
    expectTaskScoped(.bragPost, .blocked, private: false, followers: false, public: false)
}

@Test("cheerCount owner")
func visibilityCheerCountOwner() {
    expectTaskScoped(.cheerCount, .owner, private: true, followers: true, public: true, nilVisibility: true)
}

@Test("cheerCount mutual")
func visibilityCheerCountMutual() {
    expectTaskScoped(.cheerCount, .mutual, private: false, followers: true, public: true)
}

@Test("cheerCount oneWay")
func visibilityCheerCountOneWay() {
    expectTaskScoped(.cheerCount, .oneWay, private: false, followers: true, public: true)
}

@Test("cheerCount stranger")
func visibilityCheerCountStranger() {
    expectTaskScoped(.cheerCount, .stranger, private: false, followers: false, public: true)
}

@Test("cheerCount blocked")
func visibilityCheerCountBlocked() {
    expectTaskScoped(.cheerCount, .blocked, private: false, followers: false, public: false)
}

@Test("commentList owner")
func visibilityCommentListOwner() {
    expectTaskScoped(.commentList, .owner, private: true, followers: true, public: true, nilVisibility: true)
}

@Test("commentList mutual")
func visibilityCommentListMutual() {
    expectTaskScoped(.commentList, .mutual, private: false, followers: true, public: true)
}

@Test("commentList oneWay")
func visibilityCommentListOneWay() {
    expectTaskScoped(.commentList, .oneWay, private: false, followers: true, public: true)
}

@Test("commentList stranger")
func visibilityCommentListStranger() {
    expectTaskScoped(.commentList, .stranger, private: false, followers: false, public: true)
}

@Test("commentList blocked")
func visibilityCommentListBlocked() {
    expectTaskScoped(.commentList, .blocked, private: false, followers: false, public: false)
}

private func expectAlways(
    _ resource: SocialResource,
    _ relation: ViewerRelation,
    _ expected: Bool
) {
    #expect(canView(resource, relation: relation, taskVisibility: nil) == expected)
    #expect(canView(resource, relation: relation, taskVisibility: .private) == expected)
    #expect(canView(resource, relation: relation, taskVisibility: .followers) == expected)
    #expect(canView(resource, relation: relation, taskVisibility: .public) == expected)
}

private func expectTaskScoped(
    _ resource: SocialResource,
    _ relation: ViewerRelation,
    private privateExpected: Bool,
    followers followersExpected: Bool,
    public publicExpected: Bool,
    nilVisibility: Bool = false
) {
    #expect(canView(resource, relation: relation, taskVisibility: nil) == nilVisibility)
    #expect(canView(resource, relation: relation, taskVisibility: .private) == privateExpected)
    #expect(canView(resource, relation: relation, taskVisibility: .followers) == followersExpected)
    #expect(canView(resource, relation: relation, taskVisibility: .public) == publicExpected)
}
