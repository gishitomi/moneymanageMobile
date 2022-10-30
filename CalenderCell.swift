//
//  CalenderCell.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/09/10.
//

import UIKit

final class CalendarCell: UICollectionViewCell {

    private var label: UILabel = {
        let it = UILabel()
        it.textAlignment = .center
        it.translatesAutoresizingMaskIntoConstraints = false
        return it
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: Model) {
         label.text = model.text
         label.textColor = model.textColor
    }
}


extension CalendarCell {

    struct Model {
        var text: String = ""
        var textColor: UIColor = .black
        /// DateFomatterクラスのインスタンス生成
        let dateFormatter = DateFormatter()
    }
}

extension CalendarCell.Model {
    init(date: Date) {
        let weekday = Calendar.current.component(.weekday, from: date)
        if weekday == 1 {
            textColor = .red
        } else if weekday == 7 {
            textColor = .blue
        } else {
            textColor = .gray
        }
        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
         
        /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
        dateFormatter.dateFormat = "d"
        text = dateFormatter.string(from: date)
    }
}
