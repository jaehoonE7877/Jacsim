import Testing
import Foundation
import SwiftData
import UIKit
import Domain
@testable import Data

@Test("UserDefaultsAppPreferencesAdapter는 온보딩/테마 값을 읽고 쓴다")
func userDefaultsAdapterStoresOnboardingAndTheme() {
    let suiteName = "DataTests.AppPreferences.\(UUID().uuidString)"
    let userDefaults = UserDefaults(suiteName: suiteName)!
    defer {
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    let adapter = UserDefaultsAppPreferencesAdapter(userDefaults: userDefaults)
    let port = adapter.makePort()

    #expect(port.isOnboardingCompleted() == false)
    port.setOnboardingCompleted(true)
    #expect(port.isOnboardingCompleted() == true)

    #expect(port.getThemeModeRaw() == nil)
    port.setThemeModeRaw("dark")
    #expect(port.getThemeModeRaw() == "dark")
}

@Test("UserDefaultsAppPreferencesAdapter는 리디자인 플래그 override를 저장하고 제거한다")
func userDefaultsAdapterStoresAndRemovesRedesignOverrides() {
    let suiteName = "DataTests.Redesign.\(UUID().uuidString)"
    let userDefaults = UserDefaults(suiteName: suiteName)!
    defer {
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    let adapter = UserDefaultsAppPreferencesAdapter(userDefaults: userDefaults)
    let port = adapter.makePort()

    #expect(port.getRedesignScreenEnabled("calendar") == nil)
    port.setRedesignScreenEnabled("calendar", false)
    #expect(port.getRedesignScreenEnabled("calendar") == false)
    port.removeRedesignScreenOverride("calendar")
    #expect(port.getRedesignScreenEnabled("calendar") == nil)

    #expect(port.getRedesignSectionEnabled("taskFormAlarm") == nil)
    port.setRedesignSectionEnabled("taskFormAlarm", true)
    #expect(port.getRedesignSectionEnabled("taskFormAlarm") == true)
    port.removeRedesignSectionOverride("taskFormAlarm")
    #expect(port.getRedesignSectionEnabled("taskFormAlarm") == nil)
}

@Test("UserJacsimModel은 legacy store에서 currentStageTypeRaw가 없어도 도메인 모델로 복원된다")
func userJacsimModelRestoresWhenCurrentStageTypeRawIsMissing() {
    let startDate = Calendar.current.startOfDay(for: Date())
    let endDate = Calendar.current.date(byAdding: .day, value: 2, to: startDate) ?? startDate
    let stage = StageModel(
        stageTypeRaw: StageType.three.rawValue,
        startDate: startDate,
        endDate: endDate,
        durationDays: StageType.three.rawValue,
        resultRaw: StageResult.inProgress.rawValue
    )
    let model = UserJacsimModel(
        title: "마이그레이션 호환 작심",
        startDate: startDate,
        endDate: endDate,
        success: 0,
        currentStageTypeRaw: nil,
        stages: [stage]
    )

    let task = mapToDomainModel(model)

    #expect(task.currentStage?.stageType == .three)
}

@Suite(.serialized)
struct SwiftDataMigrationTests {
    @Test("SwiftData V1→current 마이그레이션은 기존 작심 visibility를 private으로 채운다")
    func swiftDataMigrationSetsExistingTaskVisibilityPrivate() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SwiftDataMigrationTests")
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let storeURL = directory.appendingPathComponent("Jacsim.store")
        let taskID = UUID()
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 2, to: startDate) ?? startDate

        try createV1Store(
            storeURL: storeURL,
            taskID: taskID,
            startDate: startDate,
            endDate: endDate
        )

        let schema = Schema(versionedSchema: CurrentSwiftDataSchema.self)
        let config = ModelConfiguration(schema: schema, url: storeURL)
        let container = try ModelContainer(
            for: schema,
            migrationPlan: JacsimMigrationPlan.self,
            configurations: [config]
        )
        let context = ModelContext(container)
        let tasks = try context.fetch(FetchDescriptor<UserJacsimModel>())
        let migrated = try #require(tasks.first)

        #expect(tasks.count == 1)
        #expect(migrated.id == taskID)
        #expect(migrated.visibilityRaw == TaskVisibility.private.rawValue)
        #expect(mapToDomainModel(migrated).visibility == .private)
    }

    private func createV1Store(
        storeURL: URL,
        taskID: UUID,
        startDate: Date,
        endDate: Date
    ) throws {
        let schema = Schema(versionedSchema: JacsimSchemaV1.self)
        let config = ModelConfiguration(schema: schema, url: storeURL)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)
        let model = JacsimSchemaV1.UserJacsimModel(
            id: taskID,
            title: "V1 저장소 작심",
            startDate: startDate,
            endDate: endDate,
            success: 0
        )
        context.insert(model)
        try context.save()
    }
}

@Test("DocumentImageStoreAdapter는 이미지를 리사이즈/재압축해서 안전하게 저장하고 로드한다")
func documentImageStoreCompressesAndLoadsImages() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("DocumentImageStoreAdapterTests")
        .appendingPathComponent(UUID().uuidString)
    defer {
        try? FileManager.default.removeItem(at: directory)
    }

    let adapter = DocumentImageStoreAdapter(
        imageDirectory: directory,
        maxPixelDimension: 320,
        compressionQuality: 0.65
    )
    let sourceImage = makeTestImage(size: CGSize(width: 1_200, height: 800))
    let sourceData = try #require(sourceImage.jpegData(compressionQuality: 1.0))

    _ = try await adapter.saveImage(key: "safe-image.jpg", data: sourceData)

    let storedData = try #require(await adapter.loadImage(key: "safe-image.jpg"))
    let storedImage = try #require(UIImage(data: storedData))
    #expect(storedData.count < sourceData.count)
    #expect(max(storedImage.size.width, storedImage.size.height) <= 320)
    #expect(await adapter.imageExists(key: "safe-image.jpg"))

    await adapter.deleteImage(key: "safe-image.jpg")
    #expect(await adapter.imageExists(key: "safe-image.jpg") == false)
}

@Test("DocumentImageStoreAdapter는 경로 이동이 가능한 이미지 키를 거부한다")
func documentImageStoreRejectsPathTraversalKeys() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("DocumentImageStoreAdapterTests")
        .appendingPathComponent(UUID().uuidString)
    defer {
        try? FileManager.default.removeItem(at: directory)
    }

    let adapter = DocumentImageStoreAdapter(imageDirectory: directory)

    do {
        _ = try await adapter.saveImage(key: "../unsafe.jpg", data: Data("unsafe".utf8))
        Issue.record("Path traversal image key should be rejected")
    } catch ImageStoreError.invalidKey {
        #expect(await adapter.loadImage(key: "../unsafe.jpg") == nil)
    }
}

@Test("DocumentImageStoreAdapter는 이미지가 아닌 데이터를 저장하지 않는다")
func documentImageStoreRejectsNonImageData() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("DocumentImageStoreAdapterTests")
        .appendingPathComponent(UUID().uuidString)
    defer {
        try? FileManager.default.removeItem(at: directory)
    }

    let adapter = DocumentImageStoreAdapter(imageDirectory: directory)

    do {
        _ = try await adapter.saveImage(key: "not-image.jpg", data: Data("not an image".utf8))
        Issue.record("Non-image data should not be stored as an image")
    } catch ImageStoreError.invalidImage {
        #expect(await adapter.loadImage(key: "not-image.jpg") == nil)
        #expect(await adapter.imageExists(key: "not-image.jpg") == false)
    }
}

@Test("SwiftDataTaskRepositoryAdapter는 같은 날짜 인증 기록을 하나로 읽어온다")
func swiftDataTaskRepositoryNormalizesDuplicateDailyRecordsOnFetch() async throws {
    let container = try makeInMemoryContainer()
    let taskID = TaskID(UUID())
    let day = Calendar.current.startOfDay(for: Date())
    let model = UserJacsimModel(
        id: taskID.rawValue,
        title: "중복 기록 작심",
        startDate: day,
        endDate: day,
        success: 0
    )
    model.memoList = [
        CertifiedModel(
            id: UUID(),
            memo: "",
            check: false,
            date: day,
            imagePath: nil,
            userJacsim: model
        ),
        CertifiedModel(
            id: UUID(),
            memo: "인증 완료",
            check: true,
            date: day.addingTimeInterval(60),
            imagePath: "record.jpg",
            userJacsim: model
        )
    ]

    let context = ModelContext(container)
    context.insert(model)
    try context.save()

    let adapter = SwiftDataTaskRepositoryAdapter(container: container)
    let fetchedTask = try #require(await adapter.fetchTask(id: taskID))

    #expect(fetchedTask.records.count == 1)
    #expect(fetchedTask.records[0].check == true)
    #expect(fetchedTask.records[0].memo == "인증 완료")
    #expect(fetchedTask.records[0].imagePath == "record.jpg")
    #expect(Calendar.current.isDate(fetchedTask.records[0].date, inSameDayAs: day))
}

@Test("SwiftDataTaskRepositoryAdapter는 저장 시 같은 날짜 인증 기록을 하나로 정리한다")
func swiftDataTaskRepositoryNormalizesDuplicateDailyRecordsOnSave() async throws {
    let container = try makeInMemoryContainer()
    let taskID = TaskID(UUID())
    let day = Calendar.current.startOfDay(for: Date())
    let task = Domain.Task(
        id: taskID,
        title: "저장 정규화 작심",
        startDate: day,
        endDate: day,
        records: [
            DailyRecordSnapshot(
                id: UUID(),
                memo: "",
                check: false,
                date: day,
                imagePath: nil
            ),
            DailyRecordSnapshot(
                id: UUID(),
                memo: "두 번째 인증",
                check: true,
                date: day.addingTimeInterval(120),
                imagePath: "second.jpg"
            )
        ]
    )

    let adapter = SwiftDataTaskRepositoryAdapter(container: container)
    try await adapter.addTask(task)

    let fetchedTask = try #require(await adapter.fetchTask(id: taskID))
    #expect(fetchedTask.records.count == 1)
    #expect(fetchedTask.records[0].check == true)
    #expect(fetchedTask.records[0].memo == "두 번째 인증")
    #expect(fetchedTask.records[0].imagePath == "second.jpg")
}

@Test("SwiftDataTaskRepositoryAdapter는 조회 시 완료 스테이지 상태를 파생해 archive status를 갱신한다")
func swiftDataTaskRepositoryDerivesCompletedStageStatusOnFetch() async throws {
    let container = try makeInMemoryContainer()
    let context = ModelContext(container)
    let calendar = Calendar.current
    let endDate = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: Date()))!
    let startDate = calendar.date(byAdding: .day, value: -179, to: endDate)!
    let model = makeStageStatusModel(
        title: "완료된 작심",
        stageType: .oneEighty,
        startDate: startDate,
        checkedOffsets: Set(0..<90)
    )

    context.insert(model)
    try context.save()

    let adapter = SwiftDataTaskRepositoryAdapter(container: container)
    let doneTasks = await adapter.fetchTasksByStatus(.done)
    let activeTasks = await adapter.fetchActiveTasks()

    #expect(doneTasks.count == 1)
    #expect(doneTasks.first?.stages.last?.result == .success)
    #expect(doneTasks.first?.isTerminallySuccessful == true)
    #expect(activeTasks.isEmpty)
}

@Test("SwiftDataTaskRepositoryAdapter는 실패 스테이지를 재도전 가능한 active task로 반환한다")
func swiftDataTaskRepositoryKeepsFailedStageVisibleForRetry() async throws {
    let container = try makeInMemoryContainer()
    let context = ModelContext(container)
    let calendar = Calendar.current
    let endDate = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: Date()))!
    let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
    let model = makeStageStatusModel(
        title: "재도전 작심",
        stageType: .seven,
        startDate: startDate,
        checkedOffsets: [0]
    )

    context.insert(model)
    try context.save()

    let adapter = SwiftDataTaskRepositoryAdapter(container: container)
    let activeTasks = await adapter.fetchActiveTasks()

    #expect(activeTasks.count == 1)
    #expect(activeTasks.first?.title == "재도전 작심")
    #expect(activeTasks.first?.stages.last?.result == .fail)
}

@Test("UserSettingsRepositoryAdapter는 active focus 작심 1건만 예약 대상으로 표시한다")
func userSettingsRepositoryMarksOnlyFocusReminderSchedulable() async throws {
    let container = try makeInMemoryContainer()
    let context = ModelContext(container)
    let today = Calendar.current.startOfDay(for: Date())
    let alarm = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    let focusModel = makeReminderModel(
        title: "곧 끝나는 작심",
        startDate: today,
        durationDays: 3,
        alarm: alarm
    )
    let secondaryModel = makeReminderModel(
        title: "나중에 끝나는 작심",
        startDate: today,
        durationDays: 7,
        alarm: alarm
    )

    context.insert(focusModel)
    context.insert(secondaryModel)
    try context.save()

    let adapter = UserSettingsRepositoryAdapter(context: context)
    let reminders = await adapter.getAllReminders()
    let schedulableReminders = reminders.filter(\.shouldSchedule)

    #expect(reminders.count == 2)
    #expect(schedulableReminders.count == 1)
    #expect(schedulableReminders.first?.title == "곧 끝나는 작심")
    #expect(reminders.first { $0.title == "나중에 끝나는 작심" }?.shouldSchedule == false)
}

private func makeTestImage(size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        UIColor.systemBlue.setFill()
        context.fill(CGRect(origin: .zero, size: size))

        UIColor.systemRed.setFill()
        for index in stride(from: 0, to: Int(size.width), by: 24) {
            let rect = CGRect(
                x: CGFloat(index),
                y: CGFloat(index % Int(size.height)),
                width: 18,
                height: size.height / 3
            )
            context.fill(rect)
        }
    }
}

private func makeInMemoryContainer() throws -> ModelContainer {
    try SwiftDataStack.makeContainer(isStoredInMemoryOnly: true)
}

private func makeReminderModel(
    title: String,
    startDate: Date,
    durationDays: Int,
    alarm: Date
) -> UserJacsimModel {
    let endDate = Calendar.current.date(
        byAdding: .day,
        value: durationDays - 1,
        to: startDate
    ) ?? startDate
    let stage = StageModel(
        stageTypeRaw: durationDays,
        startDate: startDate,
        endDate: endDate,
        durationDays: durationDays,
        resultRaw: StageResult.inProgress.rawValue
    )
    let records = (0..<durationDays).map { offset in
        CertifiedModel(
            id: UUID(),
            memo: "",
            check: false,
            date: Calendar.current.date(byAdding: .day, value: offset, to: startDate) ?? startDate,
            imagePath: nil
        )
    }
    let model = UserJacsimModel(
        id: UUID(),
        title: title,
        startDate: startDate,
        endDate: endDate,
        success: 0,
        alarm: alarm,
        isNotificationEnabled: true,
        memoList: records,
        stages: [stage]
    )
    stage.userJacsim = model
    records.forEach { record in
        record.userJacsim = model
    }
    return model
}

private func makeStageStatusModel(
    title: String,
    stageType: StageType,
    startDate: Date,
    checkedOffsets: Set<Int>
) -> UserJacsimModel {
    let endDate = Calendar.current.date(
        byAdding: .day,
        value: stageType.durationDays - 1,
        to: startDate
    ) ?? startDate
    let stage = StageModel(
        stageTypeRaw: stageType.rawValue,
        startDate: startDate,
        endDate: endDate,
        durationDays: stageType.durationDays,
        resultRaw: StageResult.inProgress.rawValue
    )
    let records = (0..<stageType.durationDays).map { offset in
        CertifiedModel(
            id: UUID(),
            memo: "",
            check: checkedOffsets.contains(offset),
            date: Calendar.current.date(byAdding: .day, value: offset, to: startDate) ?? startDate,
            imagePath: nil
        )
    }
    let model = UserJacsimModel(
        id: UUID(),
        title: title,
        startDate: startDate,
        endDate: endDate,
        success: checkedOffsets.count,
        memoList: records,
        stages: [stage]
    )
    stage.userJacsim = model
    records.forEach { record in
        record.userJacsim = model
    }
    return model
}
