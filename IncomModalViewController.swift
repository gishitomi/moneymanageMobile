//
//  IncomModalViewController.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/08/03.
//

import UIKit

protocol IncomDataReturn {
    func getDelegate(num: Int, changedDt: Date)
}

class IncomModalViewController:
    UIViewController{
    //戻るボタン
    @IBOutlet weak var backBtn: UIButton!
    
    var incomType: String = ""
    
    @IBOutlet weak var incomMoney: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var thisDate: UILabel!
    @IBOutlet weak var yesterday: UILabel!
    @IBOutlet weak var tommorow: UILabel!
    
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    let leftImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
    let rightImage = UIImage(systemName: "chevron.right")
    
    let dateFormatter = DateFormatter()
    let dateFormatterDayOnly = DateFormatter()
    let dateFormatterForInsert = DateFormatter()
    
    var dt = Date()
    let yd = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let tm = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    
    //カテゴリボタン
    @IBOutlet weak var incomBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    
    //カテゴリボタンイメージ
    @IBOutlet weak var incomBtnImage: UIImageView!
    @IBOutlet weak var otherBtnImage: UIImageView!
    //カテゴリボタンラベル
    @IBOutlet weak var incomBtnLabel: UILabel!
    @IBOutlet weak var otherBtnLabel: UILabel!
    
    let incomCount: Int = 2
    
    var incomBtns: [UIButton] = []
    var incomBtnsImage: [UIImageView] = []
    var incomBtnsLabel: [UILabel] = []
    
    func appendBtns() {
        incomBtns += [
            incomBtn,
            otherBtn
        ]
        for i in 0..<incomBtns.count {
            incomBtns[i].contentMode = .scaleAspectFit
            incomBtns[i].contentHorizontalAlignment = .fill
            incomBtns[i].contentVerticalAlignment = .fill
            incomBtns[i].imageEdgeInsets = UIEdgeInsets(top: 27, left: 27, bottom: 27, right: 27)
            incomBtns[i].addTarget(self, action: #selector(buttonClicked(_:)), for: UIControl.Event.touchUpInside)
        }
    }
    func appendBtnImage() {
        incomBtnsImage += [
            incomBtnImage,
            otherBtnImage
        ]
    }
    func appendBtnLabel() {
        incomBtnsLabel += [
            incomBtnLabel,
            otherBtnLabel
        ]
    }
    
    //一覧画面から渡される変数
    var selectedAmount: String = ""
    var selectedType: String = ""
    var selectedDate: String = ""
    var selectedDescription: String = "init"
    var selectedId: String = ""
    var isSelected: Bool = false
    
    let dateUtils = DateUtils()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        // 対象のテキストフィールドがアクティブなとき、キーボードのツールバーに、前後ボタンや完了ボタンを設定する。
        addPreviousNextableDoneButtonOnKeyboard(textFields: [incomMoney, descriptionField], previousNextable: true)
        
        //画面スワイプ検知
        //右へ
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipeGesture.direction = .right
        view.addGestureRecognizer(rightSwipeGesture)
        //左へ
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipeGesture.direction = .left
        view.addGestureRecognizer(leftSwipeGesture)
        //下へ
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        downSwipeGesture.direction = .down
        view.addGestureRecognizer(downSwipeGesture)
        
        //金額テキストボックス 数値のみ
        incomMoney.keyboardType = UIKeyboardType.numberPad
        incomMoney.text = "0"
        incomMoney.returnKeyType = UIReturnKeyType.done
        
        //カテゴリボタン配置
        appendBtns()
        appendBtnImage()
        appendBtnLabel()
        
        //グローバル変数モーダルフラグ
        editModalFlg = 1
        
        if(selectedAmount != "") {
            incomMoney.text = selectedAmount
            isSelected = true
        }
        if(selectedType != "") {
            buttonSelected(selectedType: selectedType)
            incomType = selectedType
        }
        if(selectedDescription != "init") {
            descriptionField.text = selectedDescription
        }
        
        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterDayOnly.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterForInsert.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        
        if(selectedDate != "") {
            let calendar = Calendar(identifier: .gregorian)
            let selectedDt = dateUtils.dateFromString(string: selectedDate, format: "yyyy/MM/dd")
            let selectedYd = calendar.date(byAdding: .day, value: -1, to: selectedDt)
            let selectedTm = calendar.date(byAdding: .day, value: 1, to: selectedDt)
            dt = selectedDt
            
            thisDate.text = dateFormatter.string(from: dt)
            yesterday.text = dateFormatterDayOnly.string(from: selectedYd!)
            tommorow.text = dateFormatterDayOnly.string(from: selectedTm!)
        } else {
            thisDate.text = dateFormatter.string(from: dt)
            yesterday.text = dateFormatterDayOnly.string(from: yd)
            tommorow.text = dateFormatterDayOnly.string(from: tm)
        }
        

        self.leftArrow.setImage(leftImage, for: .normal)
        self.rightArrow.setImage(rightImage, for: .normal)

    }
    
    //押されたボタンを識別する（ラジオボタン選択時）
    @objc func buttonClicked(_ sender: UIButton) {
        for i in 0..<incomBtns.count {
            incomBtns[i].backgroundColor = UIColor.white
        }
        let button = sender
        button.backgroundColor = UIColor(red: 73/255, green: 123/255, blue: 42/255, alpha: 1)
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.duration = 2.0
        animation.fromValue = 1.25
        animation.toValue = 1.0
        animation.mass = 0.2
        animation.initialVelocity = 30.0
        animation.damping = 4.0
        animation.stiffness = 300.0
        button.layer.add(animation, forKey: nil)
        
        //ボタンの角を丸くする
        button.layer.cornerRadius = 10.0
        //キーボードを閉じる
        self.view.endEditing(true)
    }
    
    //編集の場合カテゴリボタンを選択ずみの状態にする
    func buttonSelected(selectedType: String) {
        for i in 0..<incomCount {
            if(selectedType == incomBtnsLabel[i].text!) {
                incomBtns[i].backgroundColor = UIColor(red: 73/255, green: 123/255, blue: 42/255, alpha: 1)
                incomBtnsLabel[i].textColor = UIColor.white
                incomBtnsImage[i].tintColor = UIColor.white
            }
        }
    }
    
    //テキストボックス以外が押されたとき、キーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {

        switch sender.direction {
        case .left:
            goTommorowSwipe()
        case .right:
            goYesterdaySwipe()
        case .down:
            self.dismiss(animated: true, completion: nil)
        default:
            break
        }

    }
    
    @IBAction func clickIncomBtn(_ sender: Any) {
        incomType = "給与"
        incomBtnImage.tintColor = UIColor.white
        incomBtnLabel.textColor = UIColor.white
        otherBtnImage.tintColor = UIColor.black
        otherBtnLabel.textColor = UIColor.black
    }
    
    @IBAction func clickOtherBtn(_ sender: Any) {
        incomType = "その他"
        incomBtnImage.tintColor = UIColor.black
        incomBtnLabel.textColor = UIColor.black
        otherBtnImage.tintColor = UIColor.white
        otherBtnLabel.textColor = UIColor.white
    }
    
    var dateCount: Int = 0
    //前日ボタン押下時
    @IBAction func goYesterday(_ sender: Any) {
        dateCount += -1
        if(isSelected) {
            dt = dateUtils.changeEditDate(selectedDate: selectedDate, dateCount: dateCount)
        } else {
            dt = Calendar.current.date(byAdding: .day, value: dateCount, to: Date())!
        }
        let yd = Calendar.current.date(byAdding: .day, value: -1, to: dt)!
        let tm = Calendar.current.date(byAdding: .day, value: 1, to: dt)!
        
        thisDate.text = dateFormatter.string(from: dt)
        yesterday.text = dateFormatterDayOnly.string(from: yd)
        tommorow.text = dateFormatterDayOnly.string(from: tm)
    }
    
    //翌日ボタン押下時
    @IBAction func goTommorow(_ sender: Any) {
        dateCount += 1
        if(isSelected) {
             dt = dateUtils.changeEditDate(selectedDate: selectedDate, dateCount: dateCount)
        } else {
             dt = Calendar.current.date(byAdding: .day, value: dateCount, to: Date())!
        }
        let yd = Calendar.current.date(byAdding: .day, value: -1, to: dt)!
        let tm = Calendar.current.date(byAdding: .day, value: 1, to: dt)!
        
        thisDate.text = dateFormatter.string(from: dt)
        yesterday.text = dateFormatterDayOnly.string(from: yd)
        tommorow.text = dateFormatterDayOnly.string(from: tm)
    }
    
    //前日ボタンスワイプ時
    @IBAction func goYesterdaySwipe() {
        dateCount += -1
        if(isSelected) {
            dt = dateUtils.changeEditDate(selectedDate: selectedDate, dateCount: dateCount)
        } else {
            dt = Calendar.current.date(byAdding: .day, value: dateCount, to: Date())!
        }
        let yd = Calendar.current.date(byAdding: .day, value: -1, to: dt)!
        let tm = Calendar.current.date(byAdding: .day, value: 1, to: dt)!
        
        thisDate.text = dateFormatter.string(from: dt)
        yesterday.text = dateFormatterDayOnly.string(from: yd)
        tommorow.text = dateFormatterDayOnly.string(from: tm)
    }
    
    //翌日ボタンスワイプ時
    @IBAction func goTommorowSwipe() {
        dateCount += 1
        if(isSelected) {
             dt = dateUtils.changeEditDate(selectedDate: selectedDate, dateCount: dateCount)
        } else {
             dt = Calendar.current.date(byAdding: .day, value: dateCount, to: Date())!
        }
        let yd = Calendar.current.date(byAdding: .day, value: -1, to: dt)!
        let tm = Calendar.current.date(byAdding: .day, value: 1, to: dt)!
        
        thisDate.text = dateFormatter.string(from: dt)
        yesterday.text = dateFormatterDayOnly.string(from: yd)
        tommorow.text = dateFormatterDayOnly.string(from: tm)
    }
    
    //決定ボタンクリック時
    let dbConn = DBService()
    var errorMessage: String = ""
    var delegate: IncomDataReturn?
    @IBAction func clickDecideBtn(_ sender: Any) {
        if(validation()) {
            let alert: UIAlertController = UIAlertController(title: "エラー", message: errorMessage, preferredStyle: .alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(defaultAction)
            //alert表示
            present(alert, animated: true, completion: nil)
        } else {
            let amount: Int = Int(incomMoney.text!)!
            let description: String = descriptionField.text!
            let date: String = dateFormatterForInsert.string(from: dt).replacingOccurrences(of: "/", with: "-")
            
            if(isSelected) {
                let id:Int = Int(selectedId)!
                let updateQueryBuilder: String = dbConn.updateQueryBuilder(id: id, type: incomType, date: date, amount: amount, description: description)
                dbConn.update(queryString: updateQueryBuilder)
            } else {
                let insertQueryBuilder: String = dbConn.insertQueryBuilder(type: incomType, date: date, amount: amount, amount_kbn: 2, description: description)
                dbConn.insert(queryString: insertQueryBuilder)
                editModalFlg = 0
            }
            //モーダルを閉じる
            delegate?.getDelegate(num: 2, changedDt: dt)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func validation() -> Bool {
        if(incomMoney.text == "") {
            errorMessage = "収入金額が未入力です"
            return true
        }
        if(Int(incomMoney.text!) == nil) {
            errorMessage = "数値を入力してください"
            return true
        }
        return false
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //戻るボタン処理
    @IBAction func closeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
