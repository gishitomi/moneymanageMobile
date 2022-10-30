//
//  DateUtils.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/08/17.
//

import UIKit

final class DateUtils{
     func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

     func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    //日付切り替え※編集時実行
    func changeEditDate(selectedDate: String, dateCount: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        var dt = dateFromString(string: selectedDate, format: "yyyy/MM/dd")
        dt = calendar.date(byAdding: .day, value: dateCount, to: dt)!
        
        return dt
    }

}
