//
//  ViewController.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/07/31.
//

import UIKit
import Charts
import Foundation
import GoogleMobileAds

//グローバル変数
var globalDt: Date = Date()
//編集フラグ
var editModalFlg: Int = 0
//合計支出/収入額
var globalTotalAmount: Int = 0
//支出、収入切り替えフラグ 1:支出, 2:収入
var kakeiboFlg: Int = 1

//広告ID取得
var adUnitIdFooter: String {
    return Bundle.main.object(forInfoDictionaryKey: "GADApplicationFooter") as! String
}


class ViewController: UIViewController, ChartViewDelegate, SpendDataReturn, IncomDataReturn, UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate {

    @IBOutlet weak var lastMonth: UILabel!
    @IBOutlet weak var thisMonth: UILabel!
    @IBOutlet weak var nextMonth: UILabel!
    
    //日付選択用テキストボックス
    @IBOutlet weak var thisMonthTextField: UITextField!
    let years = (1960...2500).map { $0 }
    let months = (1...12).map { $0 }
    
    //広告バー
    var bannerView: GADBannerView!
    
    //画面に表示される年月
    var dispMonth = Date()
    var dateCount: Int = 0
    
    var dt = Date()
//    let lm = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
//    let nm = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    let dateFormatter = DateFormatter()
    let dateFormatterMonthOnly = DateFormatter()
    let dateFormatterForList = DateFormatter()
    let dateFormatterYearMonth = DateFormatter()
    
    var startDate: String = ""
    var lastDate: String = ""
    
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    let leftImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
    let rightImage = UIImage(systemName: "chevron.right")
    //家計簿円グラフ
    @IBOutlet weak var pieChart: PieChartView!
    
    //総資産ラベル
    @IBOutlet weak var totalAssets: UILabel!
    //収支ラベル
    @IBOutlet weak var amountDiffDate: UILabel!
    @IBOutlet weak var amountDiff: UILabel!
    
    //支出フラグ 今月に支出額が一つでもあれば1、一つもなければ0
    var spendFlg:Int = 0
    
    //全財産
    var totalAmount: String = ""
    //収支
    var moneyDiff: String = ""
    //当月の総支出額
    var strTotalSpendAmount: String = ""
    
    //カレンダー
    private let dateManager = MonthDateManager()
    private let weeks = ["日","月", "火", "水", "木", "金", "土"]
    private let itemSize: CGFloat = (UIScreen.main.bounds.width - 60) / 7
    
    private lazy var calenderCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: itemSize, height: 50)
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    let dbConn = DBService()
    let amoFormat = AmountFormatter()
    let upgradeNotice = UpgradeNotice()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        upgradeNotice.appVersionCheck()
        
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        addBannerViewToView(bannerView)
        
//        カレンダーview出力　ver1.0では一旦保留
//        calenderCollectionView.frame.size.width = view.bounds.width
//        calenderCollectionView.frame.size.height = 500
//        view.addSubview(calenderCollectionView)
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        //画面スワイプ検知
        //右へ
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipeGesture.direction = .right
        view.addGestureRecognizer(rightSwipeGesture)
        //左へ
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipeGesture.direction = .left
        view.addGestureRecognizer(leftSwipeGesture)
        
        pieChart.delegate = self
        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterMonthOnly.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterForList.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        
        let lm = Calendar.current.date(byAdding: .month, value: -1, to: dt)!
        let nm = Calendar.current.date(byAdding: .month, value: 1, to: dt)!
        
        thisMonth.text = dateFormatter.string(from: dt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        
        //今月の月初、月末を取得
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: Date())
        let firstDay = calendar.date(from: comps)!
        let dt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: dt)!
        startDate = dateFormatterForList.string(from: dt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        
        self.leftArrow.setImage(leftImage, for: .normal)
        self.rightArrow.setImage(rightImage, for: .normal)
        
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        // 決定バーの生成
          let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
          let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
          let doneItem = UIBarButtonItem(title: "完了", style: .done, target: view, action: #selector(UIView.endEditing))
          toolbar.setItems([spacelItem, doneItem], animated: true)
        
        let cal = Calendar.current
        let comp = cal.dateComponents(
            [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,
             Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second],
             from: globalDt)
        for(i, value) in years.enumerated() {
            if comp.year == value {
                pickerView.selectRow(i, inComponent: 0, animated: true)
            }
        }
        
        for(i, value) in months.enumerated() {
            if comp.month == value {
                pickerView.selectRow(i, inComponent: 1, animated: true)
            }
        }
        
        thisMonthTextField.inputView = pickerView
        thisMonthTextField.inputAccessoryView = toolbar
        thisMonthTextField.tintColor = .white
        
        bannerView.delegate = self
        bannerView.adUnitID = adUnitIdFooter
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

    }
    
    // MARK: - UIPickerView data source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        } else if component == 1 {
            return months.count
        } else {
            return 0
        }
    }

    // MARK: - UIPickerView delegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(years[row])年"
        } else if component == 1 {
            return "\(months[row])月"
        } else {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year = years[pickerView.selectedRow(inComponent: 0)]
        let month = months[pickerView.selectedRow(inComponent: 1)]
        
        //選択した年月を取得
        let calendar = Calendar(identifier: .gregorian)
        dt = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let lm = Calendar.current.date(byAdding: .month, value: -1, to: dt)!
        let nm = Calendar.current.date(byAdding: .month, value: 1, to: dt)!
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterMonthOnly.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM", options: 0, locale: Locale(identifier: "ja_JP"))
        
        thisMonth.text = dateFormatter.string(from: dt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        
        dateCount = 0
        globalDt = dt
        updateList(selectedDt: dt)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
         bannerView.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(bannerView)
         view.addConstraints(
           [NSLayoutConstraint(item: bannerView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: view.safeAreaLayoutGuide,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: bannerView,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0)
           ])
        }
    
    //テキストボックス以外が押されたとき、キーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            goNextMonthSwipe()
        case .right:
            goLastMonthSwipe()
        default:
            break
        }
    }
    
    //一覧画面の更新
    func updateList(selectedDt: Date) {
        setPieChart(dtSelect: selectedDt)
        totalAssets.text = totalAmount
        amountDiffDate.text = dateFormatter.string(from: selectedDt) + "の収支："
        amountDiff.text = moneyDiff

        if(totalAssets.text?.range(of: "-") != nil) {
            totalAssets.textColor = .red
        } else {
            totalAssets.textColor = .black
        }

        if(amountDiff.text?.range(of: "-") != nil) {
            amountDiff.textColor = .red
        } else {
            amountDiff.textColor = .black
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "spendModal" {
            let nextVC = segue.destination as! SpendModalViewController
            nextVC.delegate = self // delegateを登録
        } else if segue.identifier == "incomModal" {
            let nextVC = segue.destination as! IncomModalViewController
            nextVC.delegate = self
        }
    }
    
    //アニメーションフラグ
    var animationFlg: Int = 0
    //日付取得フラグ
    var datetimeFlg: Int = 0
    
    //delegate用関数
    func getDelegate(num: Int, changedDt: Date) {
        animationFlg = num
        datetimeFlg = 1
        dt = changedDt
        globalDt = changedDt
    }
    //モーダル、タブバーから戻った後に実行
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(animationFlg == 1) {
            let animation = CASpringAnimation(keyPath: "transform.scale")
            animation.duration = 2.0
            animation.fromValue = 1.25
            animation.toValue = 1.0
            animation.mass = 0.3
            animation.initialVelocity = 30.0
            animation.damping = 4.0
            animation.stiffness = 300.0
            pieChart.layer.add(animation, forKey: nil)
            
//            totalAssets.layer.add(animation, forKey: nil)
            UIView.transition(with: totalAssets, duration: 1.0, options: [.transitionFlipFromBottom], animations: nil, completion: nil)
        } else if(animationFlg == 2) {
            UIView.transition(with: totalAssets, duration: 1.0, options: [.transitionFlipFromBottom], animations: nil, completion: nil)
        }
        
        if(datetimeFlg == 1) {
            self.updateList(selectedDt: dt)
            let lm = Calendar.current.date(byAdding: .month, value: -1, to: dt)!
            let nm = Calendar.current.date(byAdding: .month, value: 1, to: dt)!
            
            thisMonth.text = dateFormatter.string(from: dt)
            lastMonth.text = dateFormatterMonthOnly.string(from: lm)
            nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        } else {
            //グローバル変数に代入
            dt = globalDt
            self.updateList(selectedDt: dt)
            let lm = Calendar.current.date(byAdding: .month, value: -1, to: dt)!
            let nm = Calendar.current.date(byAdding: .month, value: 1, to: dt)!
            
            thisMonth.text = dateFormatter.string(from: dt)
            lastMonth.text = dateFormatterMonthOnly.string(from: lm)
            nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        }
        animationFlg = 0
        datetimeFlg = 0
        dateCount = 0
        
    }
    
    //次月ボタン押下時
    @IBAction func goNextMonth(_ sender: Any) {
        dateCount += 1

        var nextDt = Calendar.current.date(byAdding: .month, value: dateCount, to: dt)!
        let lm = Calendar.current.date(byAdding: .month, value: -1 + dateCount, to: dt)!
        let nm = Calendar.current.date(byAdding: .month, value: 1 + dateCount, to: dt)!
        
        thisMonth.text = dateFormatter.string(from: nextDt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        
        dispMonth = dt
        
        dateFormatterForList.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        
        //今月の月初、月末を取得
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: dt)
        let firstDay = calendar.date(from: comps)!
        nextDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: nextDt)!
        startDate = dateFormatterForList.string(from: nextDt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        
        updateList(selectedDt: nextDt)
        
        //グローバル変数に代入
        globalDt = nextDt
        
    }
    
    //前月ボタン押下時
    @IBAction func goLastMonth(_ sender: Any) {
        dateCount += -1
        
        var previousDt = Calendar.current.date(byAdding: .month, value: dateCount, to: dt)!
        let lm = Calendar.current.date(byAdding: .month, value: -1 + dateCount, to: dt)!
        let nm = Calendar.current.date(byAdding: .month, value: 1 + dateCount, to: dt)!
        
        thisMonth.text = dateFormatter.string(from: previousDt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        
        
        
        dateFormatterForList.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        
        //今月の月初、月末を取得
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: dt)
        let firstDay = calendar.date(from: comps)!
        previousDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: previousDt)!
        startDate = dateFormatterForList.string(from: previousDt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        
        updateList(selectedDt: previousDt)
        
        //グローバル変数に代入
        globalDt = previousDt
    }
    
    //次月ボタンスワイプ時
    @IBAction func goNextMonthSwipe() {
        dateCount += 1

        var nextDt = Calendar.current.date(byAdding: .month, value: dateCount, to: dt)!
        let lm = Calendar.current.date(byAdding: .month, value: -1 + dateCount, to: dt)!
        let nm = Calendar.current.date(byAdding: .month, value: 1 + dateCount, to: dt)!
        
        thisMonth.text = dateFormatter.string(from: nextDt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        
        dispMonth = dt
        
        dateFormatterForList.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        
        //今月の月初、月末を取得
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: dt)
        let firstDay = calendar.date(from: comps)!
        nextDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: nextDt)!
        startDate = dateFormatterForList.string(from: nextDt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        
        updateList(selectedDt: nextDt)
        
        //グローバル変数に代入
        globalDt = nextDt
        
    }
    
    //前月ボタンスワイプ時
    @IBAction func goLastMonthSwipe() {
        dateCount += -1
        
        var previousDt = Calendar.current.date(byAdding: .month, value: dateCount, to: dt)!
        let lm = Calendar.current.date(byAdding: .month, value: -1 + dateCount, to: dt)!
        let nm = Calendar.current.date(byAdding: .month, value: 1 + dateCount, to: dt)!
        
        thisMonth.text = dateFormatter.string(from: previousDt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        
        
        
        dateFormatterForList.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        
        //今月の月初、月末を取得
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: dt)
        let firstDay = calendar.date(from: comps)!
        previousDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: previousDt)!
        startDate = dateFormatterForList.string(from: previousDt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        
        updateList(selectedDt: previousDt)
        
        //グローバル変数に代入
        globalDt = previousDt
    }    
    
    func setPieChart(dtSelect: Date) {
        //グローバル変数初期化
        globalTotalAmount = 0
        var dataEntries: [ChartDataEntry] = []
        
        //全データ取得
        let selectBuilder: String = dbConn.selectAllQueryBuilder()
        let selectResult = dbConn.select(queryString: selectBuilder)
        
        dateFormatterYearMonth.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM", options: 0, locale: Locale(identifier: "ja_JP"))
        //今月の日付を取得（例：2022-08）
        let searchDate: String = dateFormatterYearMonth.string(from: dtSelect).replacingOccurrences(of: "/", with: "-")
        //今月分の支出データを取得
        var spendDictionary: Dictionary<String, [String]> = ["id":[], "type":[], "date":[], "amount":[], "amount_kbn":[]]
        
        for i in 0..<(selectResult["id"]?.count)! {
            if(selectResult["amount_kbn"]?[i] == "1" && Int((selectResult["amount"]?[i])!)! > 0) {
                if(selectResult["date"]?[i].range(of: searchDate) != nil) {
                    spendDictionary["id"]?.append((selectResult["id"]?[i])!)
                    spendDictionary["type"]?.append((selectResult["type"]?[i])!)
                    spendDictionary["date"]?.append((selectResult["date"]?[i])!)
                    spendDictionary["amount"]?.append((selectResult["amount"]?[i])!)
                    spendDictionary["amount_kbn"]?.append((selectResult["amount_kbn"]?[i])!)
                }
            }
        }
        //金額を算出する
        var houseArr: [Int] = []
        var lightArr: [Int] = []
        var forkArr: [Int] = []
        var carArr: [Int] = []
        var rssArr: [Int] = []
        var starArr: [Int] = []
        var scisserArr: [Int] = []
        var tshirtArr: [Int] = []
        var personArr: [Int] = []
        var hospitalArr: [Int] = []
        var crossArr: [Int] = []
        var dollArr: [Int] = []
        var incidentArr: [Int] = []
        var noneArr: [Int] = []
        for i in 0..<(spendDictionary["id"]?.count)! {
            switch(spendDictionary["type"]?[i])! {
            case "住居費":
                houseArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "光熱費":
                lightArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "食費":
                forkArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "交通費":
                carArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "通信費":
                rssArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "娯楽費":
                starArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "美容費":
                scisserArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "被服費":
                tshirtArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "交際費":
                personArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "医療費":
                hospitalArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "保険費":
                crossArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "貯蓄":
                dollArr.append(Int((spendDictionary["amount"]?[i])!)!)
            case "雑費":
                incidentArr.append(Int((spendDictionary["amount"]?[i])!)!)
            default:
                noneArr.append(Int((spendDictionary["amount"]?[i])!)!)
            }
        }
        let houseTotal: Int = houseArr.reduce(0, +)
        let lightTotal: Int = lightArr.reduce(0, +)
        let forkTotal: Int = forkArr.reduce(0, +)
        let carTotal: Int = carArr.reduce(0, +)
        let rssTotal: Int = rssArr.reduce(0, +)
        let starTotal: Int = starArr.reduce(0, +)
        let scissorTotal: Int = scisserArr.reduce(0, +)
        let tshirtTotal: Int = tshirtArr.reduce(0, +)
        let personTotal: Int = personArr.reduce(0, +)
        let hospitalTotal: Int = hospitalArr.reduce(0, +)
        let crossTotal: Int = crossArr.reduce(0, +)
        let dollTotal: Int = dollArr.reduce(0, +)
        let incidentTotal: Int = incidentArr.reduce(0, +)
        let noneTotal: Int = noneArr.reduce(0, +)
        
        var spendTotalDictionary: Dictionary<String, [String]> = ["type":[], "amount":[]]
        if(houseTotal > 0) {
            spendTotalDictionary["type"]?.append("住居費")
            spendTotalDictionary["amount"]?.append(String(houseTotal))
        }
        if(lightTotal > 0) {
            spendTotalDictionary["type"]?.append("光熱費")
            spendTotalDictionary["amount"]?.append(String(lightTotal))
        }
        if(forkTotal > 0) {
            spendTotalDictionary["type"]?.append("食費")
            spendTotalDictionary["amount"]?.append(String(forkTotal))
        }
        if(carTotal > 0) {
            spendTotalDictionary["type"]?.append("交通費")
            spendTotalDictionary["amount"]?.append(String(carTotal))
        }
        if(rssTotal > 0) {
            spendTotalDictionary["type"]?.append("通信費")
            spendTotalDictionary["amount"]?.append(String(rssTotal))
        }
        if(starTotal > 0) {
            spendTotalDictionary["type"]?.append("娯楽費")
            spendTotalDictionary["amount"]?.append(String(starTotal))
        }
        if(scissorTotal > 0) {
            spendTotalDictionary["type"]?.append("美容費")
            spendTotalDictionary["amount"]?.append(String(scissorTotal))
        }
        if(tshirtTotal > 0) {
            spendTotalDictionary["type"]?.append("被服費")
            spendTotalDictionary["amount"]?.append(String(tshirtTotal))
        }
        if(personTotal > 0) {
            spendTotalDictionary["type"]?.append("交際費")
            spendTotalDictionary["amount"]?.append(String(personTotal))
        }
        if(hospitalTotal > 0) {
            spendTotalDictionary["type"]?.append("医療費")
            spendTotalDictionary["amount"]?.append(String(hospitalTotal))
        }
        if(crossTotal > 0) {
            spendTotalDictionary["type"]?.append("保険費")
            spendTotalDictionary["amount"]?.append(String(crossTotal))
        }
        if(dollTotal > 0) {
            spendTotalDictionary["type"]?.append("貯蓄")
            spendTotalDictionary["amount"]?.append(String(dollTotal))
        }
        if(incidentTotal > 0) {
            spendTotalDictionary["type"]?.append("雑費")
            spendTotalDictionary["amount"]?.append(String(incidentTotal))
        }
        if(noneTotal > 0) {
            spendTotalDictionary["type"]?.append("未選択")
            spendTotalDictionary["amount"]?.append(String(noneTotal))
        }
        
       for i in 0..<(spendTotalDictionary["amount"]?.count)! {
           dataEntries.append( PieChartDataEntry(value: Double((spendTotalDictionary["amount"]?[i])!)!, label: (spendTotalDictionary["type"]?[i])!))
       }

       let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")

        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        // 最低値を0に（Double→Int）
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        

        
        // 今月の合計支出額を追加
        let spendTotalAmount = houseTotal + lightTotal + forkTotal + carTotal + rssTotal + starTotal + scissorTotal + tshirtTotal + personTotal + hospitalTotal + crossTotal + dollTotal + incidentTotal + noneTotal
        strTotalSpendAmount = amoFormat.amountFormatter(amount: spendTotalAmount)
        // 円グラフの中心に表示するタイトル
        if(spendTotalAmount > 0) {
            pieChart.centerText = "合計支出額\n\(strTotalSpendAmount)"
        } else {
            pieChart.centerText = "当月の支出は\nありません"
        }

        var colors: [UIColor] = []
        
       for i in 0..<(spendTotalDictionary["type"]?.count)! {
           switch (spendTotalDictionary["type"]?[i])! {
           case "住居費":
               let color = UIColor.systemGreen
               colors.append(color)
           case "光熱費":
               let color = UIColor.systemOrange
               colors.append(color)
           case "食費":
               let color = UIColor.systemBrown
               colors.append(color)
           case "交通費":
               let color = UIColor.systemIndigo
               colors.append(color)
           case "通信費":
               let color = UIColor.systemPurple
               colors.append(color)
           case "娯楽費":
               let color = UIColor.systemYellow
               colors.append(color)
           case "美容費":
               let color = UIColor.systemMint
               colors.append(color)
           case "被服費":
               let color = UIColor.systemBlue
               colors.append(color)
           case "交際費":
               let color = UIColor.systemGray
               colors.append(color)
           case "医療費":
               let color = UIColor.systemRed
               colors.append(color)
           case "保険費":
               let color = UIColor.systemPink
               colors.append(color)
           case "貯蓄":
               let color = UIColor(red: 0/255, green: 143/255, blue: 1/255, alpha: 1)
               colors.append(color)
           case "雑費":
               let color = UIColor(red: 143/255, green: 110/255, blue: 93/255, alpha: 1)
               colors.append(color)
           default:
               let color = UIColor.black
               colors.append(color)
           }
       }
        pieChartDataSet.colors = colors
        pieChart.highlightPerTapEnabled = true   // グラフがタップされたときのハイライト
        pieChart.chartDescription.enabled = false  // グラフの説明
        pieChart.drawEntryLabelsEnabled = false  // グラフ上のデータラベル
        pieChart.legend.enabled = true  // グラフの注釈
        pieChart.rotationEnabled = false // グラフがぐるぐる動くやつ
   
       pieChart.drawHoleEnabled = true
        //穴のサイズ
        pieChart.holeRadiusPercent = 0.5 //0.5がデフォルト
        
        pieChart.data = PieChartData(dataSet: pieChartDataSet)
       
       
       
       //今月分の収入額を取得
       var incomDictionary: Dictionary<String, [String]> = ["id":[], "type":[], "date":[], "amount":[], "amount_kbn":[]]
       for i in 0..<(selectResult["id"]?.count)! {
           if(selectResult["amount_kbn"]?[i] == "2" && Int((selectResult["amount"]?[i])!)! > 0) {
               if(selectResult["date"]?[i].range(of: searchDate) != nil) {
                   incomDictionary["id"]?.append((selectResult["id"]?[i])!)
                   incomDictionary["type"]?.append((selectResult["type"]?[i])!)
                   incomDictionary["date"]?.append((selectResult["date"]?[i])!)
                   incomDictionary["amount"]?.append((selectResult["amount"]?[i])!)
                   incomDictionary["amount_kbn"]?.append((selectResult["amount_kbn"]?[i])!)
               }
           }
       }
       //収入金額の合計額を算出
       var incomArr: [Int] = []
       var otherArr: [Int] = []
       
       for i in 0..<incomDictionary["id"]!.count {
           switch(incomDictionary["type"]?[i])! {
           case "給与":
               incomArr.append(Int((incomDictionary["amount"]?[i])!)!)
           default:
               otherArr.append(Int((incomDictionary["amount"]?[i])!)!)
           }
       }
       let incomTotal: Int = incomArr.reduce(0, +)
       let otherTotal: Int = otherArr.reduce(0, +)
       //今月の合計収入額
       let incomTotalAmount: Int = incomTotal + otherTotal
       
       //収支
       let intMoneyDiff: Int = incomTotalAmount - spendTotalAmount
       moneyDiff = amoFormat.amountFormatter(amount: intMoneyDiff)
       //全財産
       //今までの総支出
       var spendAllDictionary: Dictionary<String, [String]> = ["type":[], "date":[], "amount":[]]
       //今までの総収入
       var incomAllDictionary: Dictionary<String, [String]> = ["type":[], "date":[], "amount":[]]
       for i in 0..<(selectResult["id"]?.count)! {
           if(selectResult["amount_kbn"]?[i] == "1" && Int((selectResult["amount"]?[i])!)! > 0)
           {
               spendAllDictionary["type"]?.append((selectResult["type"]?[i])!)
               spendAllDictionary["date"]?.append((selectResult["date"]?[i])!)
               spendAllDictionary["amount"]?.append((selectResult["amount"]?[i])!)
           }
           if(selectResult["amount_kbn"]?[i] == "2" && Int((selectResult["amount"]?[i])!)! > 0)
           {
               incomAllDictionary["type"]?.append((selectResult["type"]?[i])!)
               incomAllDictionary["date"]?.append((selectResult["date"]?[i])!)
               incomAllDictionary["amount"]?.append((selectResult["amount"]?[i])!)
           }
       }
       var spendTotalArr: [Int] = []
       var incomTotalArr: [Int] = []
       
       for i in 0..<(spendAllDictionary["amount"]?.count)! {
           spendTotalArr.append(Int((spendAllDictionary["amount"]?[i])!)!)
       }
       for i in 0..<(incomAllDictionary["amount"]?.count)! {
           incomTotalArr.append(Int((incomAllDictionary["amount"]?[i])!)!)
       }
       let allSpendTotal: Int = spendTotalArr.reduce(0, +)
       let allIncomTotal: Int = incomTotalArr.reduce(0, +)
        
       
       //総資産額
       let intTotalAmount: Int = allIncomTotal - allSpendTotal
        totalAmount = amoFormat.amountFormatter(amount: intTotalAmount)
        
        //グローバル変数に当月の合計支出/収入額格納
        if(kakeiboFlg == 1) {
            globalTotalAmount = spendTotalAmount
        }
        else if(kakeiboFlg == 2) {
            globalTotalAmount = incomTotalAmount
        }
       
   }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let dataSet = pieChart.data?.dataSets[highlight.dataSetIndex] {
            //全データ取得
            let selectBuilder: String = dbConn.selectAllQueryBuilder()
            let selectResult = dbConn.select(queryString: selectBuilder)
            //今月の日付を取得（例：2022-08）
            let searchDate: String = dateFormatterYearMonth.string(from: globalDt).replacingOccurrences(of: "/", with: "-")
            //今月分の支出データを取得
            var spendDictionary: Dictionary<String, [String]> = ["id":[], "type":[], "date":[], "amount":[], "amount_kbn":[]]
            for i in 0..<(selectResult["id"]?.count)! {
                if(selectResult["amount_kbn"]?[i] == "1" && Int((selectResult["amount"]?[i])!)! > 0) {
                    if(selectResult["date"]?[i].range(of: searchDate) != nil) {
                        spendDictionary["id"]?.append((selectResult["id"]?[i])!)
                        spendDictionary["type"]?.append((selectResult["type"]?[i])!)
                        spendDictionary["date"]?.append((selectResult["date"]?[i])!)
                        spendDictionary["amount"]?.append((selectResult["amount"]?[i])!)
                        spendDictionary["amount_kbn"]?.append((selectResult["amount_kbn"]?[i])!)
                    }
                }
            }
            //金額を算出する
            var houseArr: [Int] = []
            var lightArr: [Int] = []
            var forkArr: [Int] = []
            var carArr: [Int] = []
            var rssArr: [Int] = []
            var starArr: [Int] = []
            var scisserArr: [Int] = []
            var tshirtArr: [Int] = []
            var personArr: [Int] = []
            var hospitalArr: [Int] = []
            var crossArr: [Int] = []
            var dollArr: [Int] = []
            var incidentalArr: [Int] = []
            var noneArr: [Int] = []
            for i in 0..<(spendDictionary["id"]?.count)! {
                switch(spendDictionary["type"]?[i])! {
                case "住居費":
                    houseArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "光熱費":
                    lightArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "食費":
                    forkArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "交通費":
                    carArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "通信費":
                    rssArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "娯楽費":
                    starArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "美容費":
                    scisserArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "被服費":
                    tshirtArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "交際費":
                    personArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "医療費":
                    hospitalArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "保険費":
                    crossArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "貯蓄":
                    dollArr.append(Int((spendDictionary["amount"]?[i])!)!)
                case "雑費":
                    incidentalArr.append(Int((spendDictionary["amount"]?[i])!)!)
                default:
                    noneArr.append(Int((spendDictionary["amount"]?[i])!)!)
                }
            }
            let houseTotal: Int = houseArr.reduce(0, +)
            let lightTotal: Int = lightArr.reduce(0, +)
            let forkTotal: Int = forkArr.reduce(0, +)
            let carTotal: Int = carArr.reduce(0, +)
            let rssTotal: Int = rssArr.reduce(0, +)
            let starTotal: Int = starArr.reduce(0, +)
            let scissorTotal: Int = scisserArr.reduce(0, +)
            let tshirtTotal: Int = tshirtArr.reduce(0, +)
            let personTotal: Int = personArr.reduce(0, +)
            let hospitalTotal: Int = hospitalArr.reduce(0, +)
            let crossTotal: Int = crossArr.reduce(0, +)
            let dollTotal: Int = dollArr.reduce(0, +)
            let incidentalTotal: Int = incidentalArr.reduce(0, +)
            let noneTotal: Int = noneArr.reduce(0, +)
            
            var spendTotalDictionary: Dictionary<String, [String]> = ["type":[], "amount":[]]
            if(houseTotal > 0) {
                spendTotalDictionary["type"]?.append("住居費")
                spendTotalDictionary["amount"]?.append(String(houseTotal))
            }
            if(lightTotal > 0) {
                spendTotalDictionary["type"]?.append("光熱費")
                spendTotalDictionary["amount"]?.append(String(lightTotal))
            }
            if(forkTotal > 0) {
                spendTotalDictionary["type"]?.append("食費")
                spendTotalDictionary["amount"]?.append(String(forkTotal))
            }
            if(carTotal > 0) {
                spendTotalDictionary["type"]?.append("交通費")
                spendTotalDictionary["amount"]?.append(String(carTotal))
            }
            if(rssTotal > 0) {
                spendTotalDictionary["type"]?.append("通信費")
                spendTotalDictionary["amount"]?.append(String(rssTotal))
            }
            if(starTotal > 0) {
                spendTotalDictionary["type"]?.append("娯楽費")
                spendTotalDictionary["amount"]?.append(String(starTotal))
            }
            if(scissorTotal > 0) {
                spendTotalDictionary["type"]?.append("美容費")
                spendTotalDictionary["amount"]?.append(String(scissorTotal))
            }
            if(tshirtTotal > 0) {
                spendTotalDictionary["type"]?.append("被服費")
                spendTotalDictionary["amount"]?.append(String(tshirtTotal))
            }
            if(personTotal > 0) {
                spendTotalDictionary["type"]?.append("交際費")
                spendTotalDictionary["amount"]?.append(String(personTotal))
            }
            if(hospitalTotal > 0) {
                spendTotalDictionary["type"]?.append("医療費")
                spendTotalDictionary["amount"]?.append(String(hospitalTotal))
            }
            if(crossTotal > 0) {
                spendTotalDictionary["type"]?.append("保険費")
                spendTotalDictionary["amount"]?.append(String(crossTotal))
            }
            if(dollTotal > 0) {
                spendTotalDictionary["type"]?.append("貯蓄")
                spendTotalDictionary["amount"]?.append(String(dollTotal))
            }
            if(incidentalTotal > 0) {
                spendTotalDictionary["type"]?.append("雑費")
                spendTotalDictionary["amount"]?.append(String(incidentalTotal))
            }
            if(noneTotal > 0) {
                spendTotalDictionary["type"]?.append("未選択")
                spendTotalDictionary["amount"]?.append(String(noneTotal))
            }


            let sliceIndex: Int = dataSet.entryIndex(entry: entry)
            let label = (spendTotalDictionary["type"]?[sliceIndex])!
            let value = Int((spendTotalDictionary["amount"]?[sliceIndex])!)
            let categoryAmount = amoFormat.amountFormatter(amount: value!)
            
            pieChart.centerText = label + "\n" + categoryAmount
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        pieChart.centerText = "合計支出額\n\(strTotalSpendAmount)"
    }
    
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
    
    

}

//カレンダー処理

extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? weeks.count : dateManager.days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        if indexPath.section == 0 {
            let day = weeks[indexPath.row]
            let model = CalendarCell.Model(text: day, textColor: .black)
            cell.configure(model: model)
        } else {
            let date = dateManager.days[indexPath.row]
            cell.configure(model: CalendarCell.Model(date: date))
        }
        return cell
    }
}
//カレンダー処理
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        /// DateFomatterクラスのインスタンス生成
        let dateFormatter = DateFormatter()
        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
         
        /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
        dateFormatter.dateFormat = "yyyy/MM"
        title = dateFormatter.string(from: dateManager.days[indexPath.row])
    }
}



