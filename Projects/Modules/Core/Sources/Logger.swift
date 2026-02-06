import Foundation

public enum Logger {
    
    private static let separator = "═══════════════════════════════════════════════════════════"
    private static let subSeparator = "───────────────────────────────────────────────────────────"
    
    private static func printBlock(_ title: String, content: () -> Void) {
        #if DEBUG
        print("\n\(separator)")
        print("📦 \(title)")
        print("\(subSeparator)")
        content()
        print("\(separator)\n")
        #endif
    }
    
    public static func taskCreated(title: String, taskId: String, startDate: Date, endDate: Date) {
        printBlock("작심 생성") {
            print("📝 제목: \(title)")
            print("🆔 아이디: \(taskId)")
            print("📅 기간: \(startDate) ~ \(endDate)")
        }
    }
    
    public static func taskSaved(duration: TimeInterval) {
        printBlock("작심 저장 완료") {
            print("⏱️ 소요시간: \(String(format: "%.3f", duration))초")
        }
    }
    
    public static func certificationStarted(taskId: String, memo: String, hasImage: Bool) {
        printBlock("인증 시작") {
            print("🆔 작심 아이디: \(taskId)")
            print("📝 메모: \(memo)")
            print("📷 사진 첨부: \(hasImage ? "✅ 있음" : "❌ 없음")")
        }
    }
    
    public static func imageSaved(key: String) {
        printBlock("사진 저장") {
            print("📷 키: \(key)")
        }
    }
    
    public static func certificationCompleted(duration: TimeInterval, index: Int, check: Bool, memo: String, imagePath: String?) {
        printBlock("인증 완료") {
            print("⏱️ 소요시간: \(String(format: "%.3f", duration))초")
            print("📍 인덱스: \(index)")
            print("✅ 인증상태: \(check ? "완료" : "미완료")")
            print("📝 메모: \(memo)")
            print("📷 사진경로: \(imagePath ?? "없음")")
        }
    }
    
    public static func certificationFailed(error: Error) {
        printBlock("인증 실패") {
            print("❌ 오류: \(error)")
        }
    }
    
    public static func certificationFetchFailed() {
        printBlock("작심 데이터 불러오기 실패") {
            print("❌ 데이터를 불러올 수 없습니다")
        }
    }
    
    public static func certificationIndexOutOfRange(index: Int, totalRecords: Int) {
        printBlock("인덱스 범위 초과") {
            print("📍 요청 인덱스: \(index)")
            print("📊 전체 레코드: \(totalRecords)")
        }
    }
    
    public static func certificationSaving(taskId: String, index: Int, memo: String, imagePath: String?) {
        printBlock("인증 저장 중") {
            print("🆔 작심 아이디: \(taskId)")
            print("📍 인덱스: \(index)")
            print("📝 메모: '\(memo)'")
            print("📷 사진경로: '\(imagePath ?? "없음")'")
        }
    }
    
    public static func certificationSavedToSwiftData(duration: TimeInterval) {
        printBlock("SwiftData 저장 완료") {
            print("⏱️ 소요시간: \(String(format: "%.3f", duration))초")
        }
    }
    
    public static func homeFetchingTasks() {
        printBlock("홈 화면 진입") {
            print("🔄 작심 목록 불러오는 중...")
        }
    }
    
    public static func homeTasksFetched(count: Int, duration: TimeInterval) {
        printBlock("작심 목록 로드 완료") {
            print("📊 불러온 작심: \(count)개")
            print("⏱️ 소요시간: \(String(format: "%.3f", duration))초")
        }
    }
    
    public static func homeFirstTaskDetails(title: String, totalRecords: Int, completedRecords: Int) {
        printBlock("첫 번째 작심 상세") {
            print("📝 제목: \(title)")
            print("📊 전체 레코드: \(totalRecords)")
            print("✅ 완료된 인증: \(completedRecords)/\(totalRecords)")
        }
    }
    
    public static func homeTasksProcessed(duration: TimeInterval, activeCount: Int, heroTaskTitle: String?) {
        printBlock("작심 데이터 처리 완료") {
            print("⏱️ 소요시간: \(String(format: "%.3f", duration))초")
            print("📊 활성 작심: \(activeCount)개")
            print("🌟 대표 작심: \(heroTaskTitle ?? "없음")")
        }
    }
}
