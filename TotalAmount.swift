//
//  TotalAmount.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/09/07.
//

import UIKit

class TotalAmount {
    let dbConn = DBService()
    let dateFormatterYearMonth = DateFormatter()
    func totalAmountCalclator(amountKbn: Int, startDate: String, lastDate: String) -> Int {
        //全データ取得
        let selectBuilder: String = dbConn.selectQueryBuilder(amountKbn, startDate, lastDate)
        let selectResult = dbConn.select(queryString: selectBuilder)
        
        dateFormatterYearMonth.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM", options: 0, locale: Locale(identifier: "ja_JP"))
        //今月の日付を取得（例：2022-08）
//        let searchDate: String = dateFormatterYearMonth.string(from: dtSelect).replacingOccurrences(of: "/", with: "-")
        
        var amountDictionary: Dictionary<String, [String]> = ["id":[], "amount":[]]
        
        var totalAmount: Int = 0
        
        for i in 0..<(selectResult["id"]?.count)! {
            if(Int((selectResult["amount"]?[i])!)! > 0) {
                amountDictionary["id"]?.append((selectResult["id"]?[i])!)
                amountDictionary["amount"]?.append((selectResult["amount"]?[i])!)
            }
        }
        var incomArr: [Int] = []
        for i in 0..<amountDictionary["id"]!.count {
            incomArr.append(Int((amountDictionary["amount"]?[i])!)!)
        }
        totalAmount = incomArr.reduce(0, +)
        return totalAmount
    }
}
