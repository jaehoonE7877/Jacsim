import Foundation
import Domain

func mapToSwiftDataModel(_ task: Domain.Task, existing: UserJacsimModel? = nil) -> UserJacsimModel {
    let success = task.records.filter { $0.check }.count
    
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
    userJacsim.success = success
    
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
    
    let existingCertifiedByID: [UUID: CertifiedModel] = Dictionary(
        uniqueKeysWithValues: userJacsim.memoList.map { ($0.id, $0) }
    )
    userJacsim.memoList = task.records.map { snapshot in
        if let certified = existingCertifiedByID[snapshot.id] {
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
    for certified in userJacsim.memoList + userJacsim.stages.flatMap(\.dailyRecords) {
        if uniqueCertifiedByID[certified.id] == nil {
            uniqueCertifiedByID[certified.id] = certified
        }
    }
    
    let records: [Domain.DailyRecordSnapshot] = uniqueCertifiedByID.values
        .sorted { $0.date < $1.date }
        .map {
            Domain.DailyRecordSnapshot(
                id: $0.id,
                memo: $0.memo,
                check: $0.check,
                date: $0.date,
                imagePath: $0.imagePath
            )
        }
    
    let createdAt = userJacsim.startDate
    let updatedAt = ([userJacsim.endDate] + records.map(\.date)).max() ?? userJacsim.endDate
    
    return Domain.Task(
        id: Domain.TaskID(userJacsim.id),
        title: userJacsim.title,
        startDate: userJacsim.startDate,
        endDate: userJacsim.endDate,
        stages: stages,
        records: records,
        isDeleted: false,
        createdAt: createdAt,
        updatedAt: updatedAt
    )
}
