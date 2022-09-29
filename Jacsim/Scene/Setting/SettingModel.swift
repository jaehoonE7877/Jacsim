//
//  SettingModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/22.
//

import Foundation

enum SettingModel: Int, CaseIterable {
    case alarm, backup, inquiry, review, version, licence
    
    var title: String {
        switch self {
        case .alarm:
            return "알람 초기화"
        case .backup:
            return "백업 및 복구"
        case .inquiry:
            return "문의하기"
        case .review:
            return "리뷰"
        case .version:
            return "버전정보"
        case .licence:
            return "오픈소스 라이선스"
        }
    }
}
