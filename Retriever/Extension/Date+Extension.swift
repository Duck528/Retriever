//
//  Date+Extension.swift
//  Retriever
//
//  Created by thekan on 05/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import Foundation

extension Date {
    func formattedString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    // maxOfWeeks : 최대 몇주 전까지 표시 (default 3주 전), 7~21일 까지는 1, 2주 전 표시, 21일 이후에는 절대 날짜 표시
    // 간혹 21일이 MAX 가 아닌 7일 14일.. 까지일 경우가 존재
    func offsetFromCurrentDate(_ format: String = "dd MMM. YYYY", maxOfWeeks: Int = 3) -> String {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: self, to: Date())
        
        let minutes = String(format: "%1$@ mins ago", String(difference.minute ?? 0))
        let hours = String(format: "%1$@ hours ago", String(difference.hour ?? 0))
        let days = String(format: "%1$@ days ago", String(difference.day ?? 0))
        let week = (difference.day ?? 0) / 7
        let weeks = String(format: "%1$@ weeks ago", String(week))
        
        if week >= maxOfWeeks { return formattedString(format) }
        
        if week > 0 {
            return week == 1 ? "Last week" : weeks
        }
        
        if let day = difference.day, day > 0 {
            return day == 1 ? "Yesterday" : days
        }
        
        if let hour = difference.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : hours
        }
        
        if let minute = difference.minute, minute > 0 {
            return minute == 1 ? "1 min ago" : minutes
        }
        
        return "Just now"
    }
}
