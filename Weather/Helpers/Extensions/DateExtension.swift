//
//  DateExtension.swift
//  Weather
//
//  Created by Pooyan on 24/04/2023.
//

import Foundation

extension Date {
    func withAddedMinutes(minutes: Double) -> Date {
        addingTimeInterval(minutes * 60)
    }
    
    func withAddedHours(hours: Double) -> Date {
        withAddedMinutes(minutes: hours * 60)
    }
    
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E"
        let stringDate = formatter.string(from: date)
        print("Date Converted To String ==>", stringDate)
        return stringDate
    }
}

