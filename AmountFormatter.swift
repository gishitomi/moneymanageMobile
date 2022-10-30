//
//  AmountFormatter.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/08/27.
//

import UIKit

class AmountFormatter {
    //文字列を金額表示
    func amountFormatter(amount: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency // 先頭に通貨記号が付与される。ロケールが日本なら¥記号
        f.currencyCode = "JPY"
        f.groupingSeparator = ","
        f.groupingSize = 3
        
        let result = f.string(from: NSNumber(integerLiteral: amount)) ?? "\(amount)"
        
        return result
    }
}
