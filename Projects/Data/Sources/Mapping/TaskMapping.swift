import Foundation
import Domain

func mapToSwiftDataModel(_ task: Domain.Task, existing: UserJacsimModel? = nil) -> UserJacsimModel {
    let task = task.refreshingStageProgress()
    let records = normalizedDailyRecords(task.records)
    let success = records.filter { $0.check }.count
    let lastStage = task.stages.last
    
    let userJacsim: UserJacsimModel = {
        if let existing {
            return existing
        }
        return UserJacsimModel(
            id: task.id.rawValue,
            title: task.title,
            startDate: task.startDate,
            endDate: task.endDate,
            success: success
        )
    }()
    
    userJacsim.id = task.id.rawValue
    userJacsim.title = task.title
    userJacsim.startDate = task.startDate
    userJacsim.endDate = task.endDate
    userJacsim.alarm = task.alarm
    userJacsim.isNotificationEnabled = task.isNotificationEnabled
    userJacsim.visibilityRaw = task.visibility.rawValue
    userJacsim.success = success
    userJacsim.isDone = task.isTerminallyDone
    userJacsim.isSuccess = task.isTerminallySuccessful
    userJacsim.statusRaw = task.isTerminallyDone
        ? Domain.ChallengeStatus.done.rawValue
        : Domain.ChallengeStatus.inProgress.rawValue
    userJacsim.resultRaw = lastStage.map { stage in
        switch stage.result {
        case .inProgress:
            return Domain.ChallengeResult.none.rawValue
        case .success:
            return Domain.ChallengeResult.success.rawValue
        case .fail:
            return Domain.ChallengeResult.fail.rawValue
        }
    } ?? Domain.ChallengeResult.none.rawValue
    userJacsim.currentStageTypeRaw = lastStage?.stageTypeRaw
    
    let existingStagesByID: [UUID: StageModel] = Dictionary(
        uniqueKeysWithValues: userJacsim.stages.map { ($0.id, $0) }
    )
    userJacsim.stages = task.stages.map { snapshot in
        if let stage = existingStagesByID[snapshot.id] {
            stage.stageTypeRaw = snapshot.stageTypeRaw
            stage.startDate = snapshot.startDate
            stage.endDate = snapshot.endDate
            stage.durationDays = snapshot.durationDays
            stage.successDays = snapshot.successDays
            stage.resultRaw = snapshot.resultRaw
            stage.userJacsim = userJacsim
            return stage
        }
        
        return StageModel(
            id: snapshot.id,
            stageTypeRaw: snapshot.stageTypeRaw,
            startDate: snapshot.startDate,
            endDate: snapshot.endDate,
            durationDays: snapshot.durationDays,
            successDays: snapshot.successDays,
            resultRaw: snapshot.resultRaw,
            userJacsim: userJacsim
        )
    }
    
    let existingCertifiedByID = certifiedModelsByID(userJacsim.memoList)
    let existingCertifiedByDay = certifiedModelsByDay(userJacsim.memoList)
    userJacsim.memoList = records.map { snapshot in
        let day = Calendar.current.startOfDay(for: snapshot.date)
        if let certified = existingCertifiedByID[snapshot.id] ?? existingCertifiedByDay[day] {
            certified.memo = snapshot.memo
            certified.check = snapshot.check
            certified.date = snapshot.date
            certified.imagePath = snapshot.imagePath
            certified.userJacsim = userJacsim
            certified.stage = nil
            return certified
        }
        
        return CertifiedModel(
            id: snapshot.id,
            memo: snapshot.memo,
            check: snapshot.check,
            date: snapshot.date,
            imagePath: snapshot.imagePath,
            userJacsim: userJacsim,
            stage: nil
        )
    }
    
    for stage in userJacsim.stages {
        stage.dailyRecords = []
    }
    
    return userJacsim
}

func mapToDomainModel(_ userJacsim: UserJacsimModel) -> Domain.Task {
    let stages: [Domain.StageSnapshot] = userJacsim.stages.map {
        Domain.StageSnapshot(
            id: $0.id,
            stageTypeRaw: $0.stageTypeRaw,
            startDate: $0.startDate,
            endDate: $0.endDate,
            durationDays: $0.durationDays,
            successDays: $0.successDays,
            resultRaw: $0.resultRaw
        )
    }
    
    var uniqueCertifiedByID: [UUID: CertifiedModel] = [:]
    var certifiedModels: [CertifiedModel] = []
    for certified in userJacsim.memoList + userJacsim.stages.flatMap(\.dailyRecords) {
        if uniqueCertifiedByID[certified.id] == nil {
            uniqueCertifiedByID[certified.id] = certified
            certifiedModels.append(certified)
        }
    }
    
    let records = normalizedDailyRecords(
        certifiedModels.map {
            Domain.DailyRecordSnapshot(
                id: $0.id,
                memo: $0.memo,
                check: $0.check,
                date: $0.date,
                imagePath: $0.imagePath
            )
        }
    )

    let createdAt = userJacsim.startDate
    let updatedAt = ([userJacsim.endDate] + records.map(\.date)).max() ?? userJacsim.endDate
    
    return Domain.Task(
        id: Domain.TaskID(userJacsim.id),
        title: userJacsim.title,
        startDate: userJacsim.startDate,
        endDate: userJacsim.endDate,
        alarm: userJacsim.alarm,
        isNotificationEnabled: userJacsim.isNotificationEnabled,
        stages: stages,
        records: records,
        visibility: Domain.TaskVisibility(rawValue: userJacsim.visibilityRaw) ?? .private,
        isDeleted: false,
        createdAt: createdAt,
        updatedAt: updatedAt
    )
}

private func certifiedModelsByID(_ certifiedModels: [CertifiedModel]) -> [UUID: CertifiedModel] {
    var result: [UUID: CertifiedModel] = [:]
    for certifiedModel in certifiedModels where result[certifiedModel.id] == nil {
        result[certifiedModel.id] = certifiedModel
    }
    return result
}

private func certifiedModelsByDay(_ certifiedModels: [CertifiedModel]) -> [Date: CertifiedModel] {
    var result: [Date: CertifiedModel] = [:]
    for certifiedModel in certifiedModels {
        let day = Calendar.current.startOfDay(for: certifiedModel.date)
        if result[day] == nil {
            result[day] = certifiedModel
        }
    }
    return result
}

private func normalizedDailyRecords(
    _ records: [Domain.DailyRecordSnapshot],
    calendar: Calendar = .current
) -> [Domain.DailyRecordSnapshot] {
    var recordsByDay: [Date: Domain.DailyRecordSnapshot] = [:]
    var orderedDays: [Date] = []

    for record in records {
        let day = calendar.startOfDay(for: record.date)
        let normalizedRecord = Domain.DailyRecordSnapshot(
            id: record.id,
            memo: record.memo,
            check: record.check,
            date: day,
            imagePath: record.imagePath
        )

        if let existingRecord = recordsByDay[day] {
            recordsByDay[day] = mergedDailyRecord(existingRecord, normalizedRecord)
        } else {
            orderedDays.append(day)
            recordsByDay[day] = normalizedRecord
        }
    }

    return orderedDays
        .compactMap { recordsByDay[$0] }
        .sorted { $0.date < $1.date }
}

private func mergedDailyRecord(
    _ existingRecord: Domain.DailyRecordSnapshot,
    _ newRecord: Domain.DailyRecordSnapshot
) -> Domain.DailyRecordSnapshot {
    Domain.DailyRecordSnapshot(
        id: existingRecord.id,
        memo: newRecord.memo.isEmpty ? existingRecord.memo : newRecord.memo,
        check: existingRecord.check || newRecord.check,
        date: existingRecord.date,
        imagePath: newRecord.imagePath ?? existingRecord.imagePath
    )
}
