//
//  SpendModalViewController.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/08/03.
//

import UIKit

protocol SpendDataReturn {
    func getDelegate(num: Int, changedDt: Date)
}

class SpendModalViewController: UIViewController, UITextFieldDelegate {
    
    var spendType: String = ""
    
    //戻るボタン
    @IBOutlet weak var backBtn: UIButton!
    
    //カテゴリボタン
    @IBOutlet weak var houseBtn: UIButton!
    @IBOutlet weak var lightBtn: UIButton!
    @IBOutlet weak var forkBtn: UIButton!
    @IBOutlet weak var carBtn: UIButton!
    @IBOutlet weak var rssBtn: UIButton!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var scissorsBtn: UIButton!
    @IBOutlet weak var tshirtBtn: UIButton!
    @IBOutlet weak var peopleBtn: UIButton!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var moneyBtn: UIButton!
    @IBOutlet weak var incidentalBtn: UIButton!
    
    //カテゴリボタンイメージ
    @IBOutlet weak var houseImage: UIImageView!
    @IBOutlet weak var lightImage: UIImageView!
    @IBOutlet weak var forkImage: UIImageView!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var rssImage: UIImageView!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var scissorImage: UIImageView!
    @IBOutlet weak var tshirtImage: UIImageView!
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var crossImage: UIImageView!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var dolImage: UIImageView!
    @IBOutlet weak var basketImage: UIImageView!
    
    //カテゴリボタンラベル
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var forkLabel: UILabel!
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var rssLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var scissorLabel: UILabel!
    @IBOutlet weak var tshirtLabel: UILabel!
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var crossLabel: UILabel!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var dolLabel: UILabel!
    @IBOutlet weak var incidentalLabel: UILabel!
    
    var spendBtns: [UIButton] = []
    var spendBtnImage: [UIImageView] = []
    var spendBtnLabel: [UILabel] = []
    let spendCount:Int = 13
    //配列にカテゴリボタンを追加
    func appendBtns() {
        spendBtns += [
            houseBtn,
            lightBtn,
            forkBtn,
            carBtn,
            rssBtn,
            starBtn,
            scissorsBtn,
            tshirtBtn,
            peopleBtn,
            crossBtn,
            heartBtn,
            moneyBtn,
            incidentalBtn
        ]
        for i in 0..<spendBtns.count {
            spendBtns[i].contentMode = .scaleAspectFit
            spendBtns[i].contentHorizontalAlignment = .fill
            spendBtns[i].contentVerticalAlignment = .fill
            spendBtns[i].imageEdgeInsets = UIEdgeInsets(top: 27, left: 27, bottom: 27, right: 27)
            spendBtns[i].addTarget(self, action: #selector(buttonClicked(_:)), for: UIControl.Event.touchUpInside)
        }
    }
    //配列にカテゴリ画像を追加
    func appendBtnImage() {
        spendBtnImage += [
            houseImage,
            lightImage,
            forkImage,
            carImage,
            rssImage,
            starImage,
            scissorImage,
            tshirtImage,
            personImage,
            crossImage,
            heartImage,
            dolImage,
            basketImage
        ]
    }
    //配列にカテゴリラベルを追加
    func appendBtnLabel() {
        spendBtnLabel += [
            houseLabel,
            lightLabel,
            forkLabel,
            carLabel,
            rssLabel,
            starLabel,
            scissorLabel,
            tshirtLabel,
            personLabel,
            crossLabel,
            heartLabel,
            dolLabel,
            incidentalLabel
        ]
    }
    
    
    @IBOutlet weak var spendMoney: UITextField!
    @IBOutlet weak var spendDescription: UITextField!
    
    @IBOutlet weak var thisDate: UILabel!
    @IBOutlet weak var yesterday: UILabel!
    @IBOutlet weak var tommorow: UILabel!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    
    let leftImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
    let rightImage = UIImage(systemName: "chevron.right")
    
    let dateFormatter = DateFormatter()
    let dateFormatterDayOnly = DateFormatter()
    let dateFormatterForInsert = DateFormatter()
    let dateFormatterMonthOnly = DateFormatter()
    
    var dt = Date()
    let yd = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let tm = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    
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
        addPreviousNextableDoneButtonOnKeyboard(textFields: [spendMoney, spendDescription], previousNextable: true)
        
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
        spendMoney.keyboardType = UIKeyboardType.numberPad
        spendMoney.text = "0"
        spendMoney.returnKeyType = UIReturnKeyType.done
        
        //グローバル変数モーダルフラグ
        editModalFlg = 1
        
        //カテゴリボタン画像、ラベル配列配置
        appendBtns()
        appendBtnImage()
        appendBtnLabel()
        
        if(selectedAmount != "") {
            spendMoney.text = selectedAmount
            isSelected = true
        }
        if(selectedType != "") {
            buttonSelected(selectedType: selectedType)
            spendType = selectedType
        }
        if(selectedDescription != "init") {
            spendDescription.text = selectedDescription
        }
        
        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterDayOnly.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterForInsert.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterMonthOnly.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM", options: 0, locale: Locale(identifier: "ja_JP"))
        
        if(selectedDate != "") {
            let calendar = Calendar(identifier: .gregorian) // 西暦を指定
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
    
    //押されたボタンを識別する（ラジオボタン選択時）
    @objc func buttonClicked(_ sender: UIButton) {
        for i in 0..<spendBtns.count {
            spendBtns[i].backgroundColor = UIColor.white
        }
        let button = sender
        button.backgroundColor = UIColor(red: 188/255, green: 41/255, blue: 29/255, alpha: 1)
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
    
    //編集の場合カテゴリボタンを選択済みの状態にする
    func buttonSelected(selectedType: String) {
        for i in 0..<spendCount {
            if(selectedType == spendBtnLabel[i].text!) {
                spendBtns[i].backgroundColor = UIColor(red: 188/255, green: 41/255, blue: 29/255, alpha: 1)
                spendBtnLabel[i].textColor = UIColor.white
                spendBtnImage[i].tintColor = UIColor.white
            }
        }
    }
    
    //住居費タップ時
    @IBAction func clickHouseBtn(_ sender: Any) {
        spendType = "住居費"
        houseImage.tintColor = UIColor.white
        houseLabel.textColor = UIColor.white
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //光熱費タップ時
    @IBAction func clickLightBtn(_ sender: Any) {
        spendType = "光熱費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.white
        lightLabel.textColor = UIColor.white
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //食費タップ時
    @IBAction func clickForkBtn(_ sender: Any) {
        spendType = "食費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.white
        forkLabel.textColor = UIColor.white
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //交通費タップ時
    @IBAction func clickCarBtn(_ sender: Any) {
        spendType = "交通費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.white
        carLabel.textColor = UIColor.white
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //通信費タップ時
    @IBAction func clickRssBtn(_ sender: Any) {
        spendType = "通信費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.white
        rssLabel.textColor = UIColor.white
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //娯楽費タップ時
    @IBAction func clickStarBtn(_ sender: Any) {
        spendType = "娯楽費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.white
        starLabel.textColor = UIColor.white
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //美容費タップ時
    @IBAction func clickScissorBtn(_ sender: Any) {
        spendType = "美容費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.white
        scissorLabel.textColor = UIColor.white
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //被服費タップ時
    @IBAction func clickTshirtBtn(_ sender: Any) {
        spendType = "被服費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.white
        tshirtLabel.textColor = UIColor.white
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //交際費タップ時
    @IBAction func clickPersonBtn(_ sender: Any) {
        spendType = "交際費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.white
        personLabel.textColor = UIColor.white
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //医療費タップ時
    @IBAction func clickCrossBtn(_ sender: Any) {
        spendType = "医療費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.white
        crossLabel.textColor = UIColor.white
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //保険費タップ時
    @IBAction func clickHeartBtn(_ sender: Any) {
        spendType = "保険費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.white
        heartLabel.textColor = UIColor.white
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //貯蓄タップ時
    @IBAction func clickDolBtn(_ sender: Any) {
        spendType = "貯蓄"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.white
        dolLabel.textColor = UIColor.white
        basketImage.tintColor = UIColor.black
        incidentalLabel.textColor = UIColor.black
    }
    
    //雑費ボタンタップ時
    @IBAction func clickIncidentalBtn(_ sender: Any) {
        spendType = "雑費"
        houseImage.tintColor = UIColor.black
        houseLabel.textColor = UIColor.black
        lightImage.tintColor = UIColor.black
        lightLabel.textColor = UIColor.black
        forkImage.tintColor = UIColor.black
        forkLabel.textColor = UIColor.black
        carImage.tintColor = UIColor.black
        carLabel.textColor = UIColor.black
        rssImage.tintColor = UIColor.black
        rssLabel.textColor = UIColor.black
        starImage.tintColor = UIColor.black
        starLabel.textColor = UIColor.black
        scissorImage.tintColor = UIColor.black
        scissorLabel.textColor = UIColor.black
        tshirtImage.tintColor = UIColor.black
        tshirtLabel.textColor = UIColor.black
        personImage.tintColor = UIColor.black
        personLabel.textColor = UIColor.black
        crossImage.tintColor = UIColor.black
        crossLabel.textColor = UIColor.black
        heartImage.tintColor = UIColor.black
        heartLabel.textColor = UIColor.black
        dolImage.tintColor = UIColor.black
        dolLabel.textColor = UIColor.black
        basketImage.tintColor = UIColor.white
        incidentalLabel.textColor = UIColor.white
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
    
    //決定ボタンタップ時
    var delegate: SpendDataReturn?
    let dbConn = DBService()
    var errorMessage: String = ""
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
            let amount: Int = Int(spendMoney.text!)!
            let description: String = spendDescription.text!
            let date: String = dateFormatterForInsert.string(from: dt).replacingOccurrences(of: "/", with: "-")
            
            //編集時
            if(isSelected) {
                let id: Int = Int(selectedId)!
                let updateQueryBuilder: String = dbConn.updateQueryBuilder(id: id, type: spendType, date: date, amount: amount, description: description)
                dbConn.update(queryString: updateQueryBuilder)
            } else {
                let insertQueryBuilder: String = dbConn.insertQueryBuilder(type: spendType, date: date, amount: amount, amount_kbn: 1, description: description)
                dbConn.insert(queryString: insertQueryBuilder)
                editModalFlg = 0
            }
            //モーダルを閉じる
            delegate?.getDelegate(num: 1, changedDt: dt)
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    //バリデーション
    func validation() -> Bool{
        if(spendMoney.text == "") {
            errorMessage = "支出金額が未入力です"
            return true
        }
        if(Int(spendMoney.text!) == nil) {
            errorMessage = "数値を入力してください"
            return true
        }
        return false
    }
    
    //戻るボタン処理
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //戻るボタン処理
    @IBAction func closeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension UIViewController {
    //テキストフィールド上部の完了ボタン　上下矢印付与
    /// 対象のテキストフィールドがアクティブなとき、キーボードのツールバーに、前後ボタンや完了ボタンを設定する処理。
    /// - Parameters:
    ///   - textFields: 設定したいテキストフィールドの配列
    ///   - previousNextable: 前後ボタンを有効にするか否か
    ///
    /// 使い方
    /// =============================================
    ///     // テキストフィールドのキーボードのツールバーの設定
    ///     addPreviousNextableDoneButtonOnKeyboard(textFields: [textField1], previousNextable: false)
    ///     addPreviousNextableDoneButtonOnKeyboard(textFields: [textField2, textField3], previousNextable: true)
    ///
    func addPreviousNextableDoneButtonOnKeyboard(textFields: [UITextField], previousNextable: Bool = false) {
        for (index, textField) in textFields.enumerated() {
            // テキストフィールドごとにループ処理を行う。
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            toolBar.barStyle = .default
            /// バーボタンアイテム
            var items = [UIBarButtonItem]()

            // MARK: 前後ボタンの設定

            if previousNextable {
                // 前後ボタンが有効な場合
                /// 上矢印ボタン
                let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: self, action: nil)
                if textField == textFields.first {
                    // 設定したいテキストフィールドの配列のうち、一番上のテキストフィールドの場合、不活性化させる。
                    previousButton.isEnabled = false
                } else {
                    // 上記以外の場合
                    // １つ前のテキストフィールドをターゲットに設定する。
                    previousButton.target = textFields[index - 1]
                    // ターゲットにフォーカスを当てる。
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }

                /// 固定スペース
                let fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: self, action: nil)
                fixedSpace.width = 8

                /// 下矢印ボタン
                let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: nil)
                if textField == textFields.last {
                    // 設定したいテキストフィールドの配列のうち、一番下のテキストフィールドの場合、不活性化させる。
                    nextButton.isEnabled = false
                } else {
                    // 上記以外の場合
                    // １つ後のテキストフィールドをターゲットに設定する。
                    nextButton.target = textFields[index + 1]
                    // ターゲットにフォーカスを当てる。
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }

                // バーボタンアイテムに前後ボタンを追加する。
                items.append(contentsOf: [previousButton, fixedSpace, nextButton])
            }

            // MARK: 完了ボタンの設定

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "完了", style: .done, target: view, action: #selector(UIView.endEditing))
            // バーボタンアイテムに完了ボタンを追加する。
            items.append(contentsOf: [flexSpace, doneButton])

            toolBar.setItems(items, animated: false)
            toolBar.sizeToFit()

            textField.inputAccessoryView = toolBar
        }
    }
}
