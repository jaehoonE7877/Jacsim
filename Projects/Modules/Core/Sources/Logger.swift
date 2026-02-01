import Foundation

public enum Logger {
    
    public static func taskCreated(title: String, taskId: String, startDate: Date, endDate: Date) {
        #if DEBUG
        print("작심 생성됨: \(title) (아이디: \(taskId))")
        print("기간: \(startDate) ~ \(endDate)")
        #endif
    }
    
    public static func taskSaved(duration: TimeInterval) {
        #if DEBUG
        print("작심 저장 완료 (소요시간: \(String(format: "%.3f", duration))초)")
        #endif
    }
    
    public static func certificationStarted(taskId: String, memo: String, hasImage: Bool) {
        #if DEBUG
        print("인증 시작 - 작심 아이디: \(taskId)")
        print("메모: \(memo)")
        print("사진 첨부: \(hasImage ? "있음" : "없음")")
        #endif
    }
    
    public static func imageSaved(key: String) {
        #if DEBUG
        print("사진 저장됨: \(key)")
        #endif
    }
    
    public static func certificationCompleted(duration: TimeInterval, index: Int, check: Bool, memo: String, imagePath: String?) {
        #if DEBUG
        print("인증 완료 (소요시간: \(String(format: "%.3f", duration))초)")
        print("인덱스: \(index), 인증상태: \(check ? "완료" : "미완료"), 메모: \(memo)")
        print("사진경로: \(imagePath ?? "없음")")
        #endif
    }
    
    public static func certificationFailed(error: Error) {
        #if DEBUG
        print("인증 실패: \(error)")
        #endif
    }
    
    public static func certificationFetchFailed() {
        #if DEBUG
        print("작심 데이터 불러오기 실패")
        #endif
    }
    
    public static func certificationIndexOutOfRange(index: Int, totalRecords: Int) {
        #if DEBUG
        print("인덱스 범위 초과: \(index), 전체 레코드: \(totalRecords)")
        #endif
    }
    
    public static func certificationSaving(taskId: String, index: Int, memo: String, imagePath: String?) {
        #if DEBUG
        print("인증 저장 중 - 작심 아이디: \(taskId), 인덱스: \(index)")
        print("메모: '\(memo)', 사진경로: '\(imagePath ?? "없음")'")
        #endif
    }
    
    public static func certificationSavedToSwiftData(duration: TimeInterval) {
        #if DEBUG
        print("인증 스위프트데이터 저장 완료 (소요시간: \(String(format: "%.3f", duration))초)")
        #endif
    }
    
    public static func homeFetchingTasks() {
        #if DEBUG
        print("홈 화면 진입 - 작심 목록 불러오는 중...")
        #endif
    }
    
    public static func homeTasksFetched(count: Int, duration: TimeInterval) {
        #if DEBUG
        print("작심 \(count)개 불러옴 (소요시간: \(String(format: "%.3f", duration))초)")
        #endif
    }
    
    public static func homeFirstTaskDetails(title: String, totalRecords: Int, completedRecords: Int) {
        #if DEBUG
        print("첫 번째 작심: \(title) (전체 레코드: \(totalRecords))")
        print("완료된 인증: \(completedRecords)/\(totalRecords)")
        #endif
    }
    
    public static func homeTasksProcessed(duration: TimeInterval, activeCount: Int, heroTaskTitle: String?) {
        #if DEBUG
        print("작심 데이터 처리 완료 (소요시간: \(String(format: "%.3f", duration))초)")
        print("활성 작심: \(activeCount)개, 대표 작심: \(heroTaskTitle ?? "없음")")
        #endif
    }
}
