public enum SocialResource: Sendable, CaseIterable {
    case profile
    case taskList
    case taskDetail
    case streak
    case record
    case bragPost
    case cheerCount
    case commentList
}

public enum ViewerRelation: Sendable, CaseIterable {
    case owner
    case mutual
    case oneWay
    case stranger
    case blocked
}

public func canView(
    _ resource: SocialResource,
    relation: ViewerRelation,
    taskVisibility: TaskVisibility?
) -> Bool {
    if relation == .owner {
        return true
    }
    if relation == .blocked {
        return false
    }

    switch resource {
    case .profile, .bragPost, .cheerCount, .commentList:
        return true
    case .taskList, .taskDetail, .streak:
        return canViewTaskScopedResource(relation: relation, taskVisibility: taskVisibility)
    case .record:
        return canViewRecord(relation: relation, taskVisibility: taskVisibility)
    }
}

private func canViewTaskScopedResource(
    relation: ViewerRelation,
    taskVisibility: TaskVisibility?
) -> Bool {
    switch taskVisibility {
    case .private, nil:
        return false
    case .followers:
        return relation == .mutual || relation == .oneWay
    case .public:
        return true
    }
}

private func canViewRecord(
    relation: ViewerRelation,
    taskVisibility: TaskVisibility?
) -> Bool {
    switch taskVisibility {
    case .private, nil:
        return false
    case .followers:
        return relation == .mutual
    case .public:
        return true
    }
}
