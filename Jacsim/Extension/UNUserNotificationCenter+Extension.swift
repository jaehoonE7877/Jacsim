//
//  UNUserNotificationCenter+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/23.
//

import Foundation
import UserNotifications

extension UNUserNotificationCenter {
    
    func sendNotificationRequest(by alarm: Alarm) {
        
        let content = UNMutableNotificationContent()
        
        content.title = "완성되지 않은 작심이 있습니다."
        content.body = "확인 부탁드릴게요!"
        content.sound = .default
        content.badge = 1
        
        let component = Calendar.current.dateComponents([.hour, .minute], from: alarm.date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: alarm.isOn)
        
        let request = UNNotificationRequest(identifier: alarm.id, content: content, trigger: trigger)
        
        self.add(request)
    }
}
