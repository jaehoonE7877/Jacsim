//
//  TimeInterval+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    static var oneHour: TimeInterval {
        return 3600
    }
    
    static var twoHour: TimeInterval {
        return oneHour * 2
    }
    
    static var oneDay: TimeInterval {
        return oneHour * 24
    }
    
    static var twoDays: TimeInterval {
        return oneDay * 2
    }
    
    static var threeDays: TimeInterval {
        return oneDay * 3
    }
    
    static var oneWeek: TimeInterval {
        return oneDay * 7
    }
    
    static var oneMonth: TimeInterval {
        return oneDay * 30
    }
    
    static var oneYear: TimeInterval {
        return oneDay * 365
    }
}
