//
//  MoneyListViewController.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/08/11.
//

import UIKit
import GoogleMobileAds

class MoneyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource,  GADBannerViewDelegate {
//  日付調整
    @IBOutlet weak var lastMonth: UILabel!
    @IBOutlet weak var thisMonth: UILabel!
    @IBOutlet weak var nextMonth: UILabel!
    
    //日付選択用テキストボックス
    @IBOutlet weak var thisMonthTextField: UITextField!
    let years = (1960...2500).map { $0 }
    let months = (1...12).map { $0 }
    
    //広告バー
    var bannerView: GADBannerView!
    
    var dt = Date()
    
    let dateFormatter = DateFormatter()
    let dateFormatterMonthOnly = DateFormatter()
    let dateFormatterForList = DateFormatter() //一覧表示用
    
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    
    var dateCount: Int = 0
    
    //月初取得
    var startDate: String = ""
    //月末取得
    var lastDate: String = ""
    
    @IBOutlet weak var IncomBtn: UIButton!
    @IBOutlet weak var SpendBtn: UIButton!
    
    //収入、支出ボタンクリック判定変数
    var ClickedBtn = UIButton.Configuration.filled()
    var UnClickedBtn = UIButton.Configuration.plain()
    
    @IBOutlet weak var MoneyTable: UITableView!
    
    //セル0件時表示ラベル
    @IBOutlet weak var EmptyCellLabel: UILabel!
    
    //合計支出/収入額ラベル
    @IBOutlet weak var TotalMoneyLabel: UILabel!
    @IBOutlet weak var TotalMoneyCalc: UILabel!
    //格納用合計支出/収入額
    var totalAmountStr: String = ""
    
    let dbConn = DBService()
    let dateUtils = DateUtils()
    let amoFormat = AmountFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        bannerView = GADBannerView(adSize: GADAdSizeBanner)
//        addBannerViewToView(bannerView)
        
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
        
        MoneyTable.dataSource = self
        MoneyTable.delegate = self
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterMonthOnly.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM", options: 0, locale: Locale(identifier: "ja_JP"))
        dateFormatterForList.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        
        let lm = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let nm = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        
        thisMonth.text = dateFormatter.string(from: dt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        
        totalAmountStr = amoFormat.amountFormatter(amount: globalTotalAmount)
        TotalMoneyCalc.text = totalAmountStr
        if(kakeiboFlg == 1) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: dt) + "の合計支出額："
        } else if(kakeiboFlg == 2) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: dt) + "の合計収入額："
        }
        
        //今月の月初、月末を取得
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: dt)
        let firstDay = calendar.date(from: comps)!
        let nowDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: nowDt)!
        startDate = dateFormatterForList.string(from: nowDt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        
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
        
//        bannerView.adUnitID = adUnitIdFooter
//        bannerView.rootViewController = self
//        bannerView.load(GADRequest())
//        bannerView.delegate = self
        
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
        
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: dt)!
        startDate = dateFormatterForList.string(from: dt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        updateList()
    }
    
    //テキストボックス以外が押されたとき、キーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let selectQueryBuilder: String = dbConn.selectQueryBuilder(kakeiboFlg, startDate, lastDate)
        let selectResults = dbConn.select(queryString: selectQueryBuilder)
        
        if (selectResults["id"]?.isEmpty)! {
            EmptyCellLabel.isHidden = false
            if(kakeiboFlg == 1) {
                EmptyCellLabel.text = "当月の支出金額はありません"
            } else {
                EmptyCellLabel.text = "当月の収入金額はありません"
            }
        } else {
            EmptyCellLabel.isHidden = true
        }
        
        return (selectResults["id"]?.count)!
    }
    
    //合計支出/収入金額
    var totalMoney: Int = 0
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = MoneyTable.dequeueReusableCell(withIdentifier: "MoneyListCell", for: indexPath)
        let selectQueryBuilder: String = dbConn.selectQueryBuilder(kakeiboFlg, startDate, lastDate)
        let selectResults = dbConn.select(queryString: selectQueryBuilder)
        //合計収入/支出額取得
        var spendTotalArr: [Int] = []
        var incomTotalArr: [Int] = []
        for i in 0..<(selectResults["id"]?.count)! {
            if(selectResults["amount_kbn"]?[i] == "1" && Int((selectResults["amount"]?[i])!)! > 0) {
                spendTotalArr.append(Int((selectResults["amount"]?[i])!)!)
            } else if(selectResults["amount_kbn"]?[i] == "2" && Int((selectResults["amount"]?[i])!)! > 0) {
                incomTotalArr.append(Int((selectResults["amount"]?[i])!)!)
            }
        }
        if(kakeiboFlg == 1) {
            globalTotalAmount = spendTotalArr.reduce(0, +)
        } else {
            globalTotalAmount = incomTotalArr.reduce(0, +)
        }
        totalAmountStr = amoFormat.amountFormatter(amount: globalTotalAmount)
        TotalMoneyCalc.text = totalAmountStr
        
        if(selectResults["type"]?[indexPath.row] == "") {
            cell.textLabel!.text = "未選択　¥" + (selectResults["amount"]?[indexPath.row])!
        } else {
            cell.textLabel!.text = (selectResults["type"]?[indexPath.row])! + "　¥" + (selectResults["amount"]?[indexPath.row])!
        }
        cell.detailTextLabel?.text =  (selectResults["date"]?[indexPath.row])!.replacingOccurrences(of: "-", with: "/") + "  " + (selectResults["description"]?[indexPath.row])!
        cell.imageView?.image = CategoryImageView(categoryType: (selectResults["type"]?[indexPath.row])!)
//        cell.imageView?.tintColor = UIColor(red: 0/255, green: 143/255, blue: 1/255, alpha: 1)
        //cell.imageView?.tintColor = UIColor(red: 0/255, green: 143/255, blue: 1/255, alpha: 1)
//        cell.imageView?.tintColor = .brown
        //カテゴリごとに色を分ける
        cell.imageView?.tintColor = CategoryImageColor(categoryType: (selectResults["type"]?[indexPath.row])!)
        
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell
    }
    
    //画面遷移用変数
    var selectedAmount: String = ""
    var selectedType: String = ""
    var selectedDate: String = ""
    var selectedDescription: String = ""
    var selectedAmountKbn: String = ""
    var selectedId: String = ""
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        let selectQueryBuilder: String = dbConn.selectQueryBuilder(kakeiboFlg, startDate, lastDate)
        let selectResults = dbConn.select(queryString: selectQueryBuilder)
        
        selectedAmount = (selectResults["amount"]?[indexPath.row])!
        selectedType = (selectResults["type"]?[indexPath.row])!
        selectedDate = (selectResults["date"]?[indexPath.row])!
        selectedDescription = (selectResults["description"]?[indexPath.row])!
        selectedAmountKbn = (selectResults["amount_kbn"]?[indexPath.row])!
        selectedId = (selectResults["id"]?[indexPath.row])!
        
        //Segueの呼び出し
        if(selectedAmountKbn == "1") {
            performSegue(withIdentifier: "spendModal",sender: nil)
        } else {
            performSegue(withIdentifier: "incomModal",sender: nil)
        }
    }
    
    //セル削除ボタン実装
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive,
                                        title: "削除") { (action, view, completionHandler) in
            self.showAlert(deleteIndexPath: indexPath)
            completionHandler(true)
        }
        action.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func showAlert(deleteIndexPath indexPath: IndexPath) {
        let dialog = UIAlertController(title: "削除",
                                       message: "削除されますがよろしいですか？",
                                       preferredStyle: .alert)
        let selectQueryBuilder: String = dbConn.selectQueryBuilder(kakeiboFlg, startDate, lastDate)
        let selectResults = dbConn.select(queryString: selectQueryBuilder)
        
        let id = (selectResults["id"]?[indexPath.row])!
        
        let deleteQueryBuilder: String = dbConn.deleteQueryBUilder(id: Int(id)!)

        dialog.addAction(UIAlertAction(title: "削除する", style: .default, handler: { (_) in
            self.dbConn.delete(queryString: deleteQueryBuilder)
            self.updateList()
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(dialog, animated: true, completion: nil)
    }
    
    //セルスワイプ時ボタン表示
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
     
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "spendModal") {
            let subVC: SpendModalViewController = (segue.destination as? SpendModalViewController)!

            subVC.selectedAmount = selectedAmount
            subVC.selectedType = selectedType
            subVC.selectedDate = selectedDate
            subVC.selectedDescription = selectedDescription
            subVC.selectedId = selectedId
            
        } else if(segue.identifier == "incomModal") {
            let subVC: IncomModalViewController = (segue.destination as? IncomModalViewController)!

            subVC.selectedAmount = selectedAmount
            subVC.selectedType = selectedType
            subVC.selectedDate = selectedDate
            subVC.selectedDescription = selectedDescription
            subVC.selectedId = selectedId
        }
    }
    
    //一覧画面の更新
    func updateList() {
        MoneyTable?.reloadData()
    }
    
    var datetimeFlg: Int = 1
    
    //モーダル、タブバーから戻った後に実行
    override func viewWillAppear(_ animated: Bool) {
        if(editModalFlg == 0) {
            //グローバル変数に代入
            dt = globalDt
        } else {
            //グローバル変数に代入
            dt = globalDt
            //0に戻す
            editModalFlg = 0
        }
        
        //グローバル変数更新
        totalAmountStr = amoFormat.amountFormatter(amount: globalTotalAmount)
        TotalMoneyCalc.text = totalAmountStr
        if(kakeiboFlg == 1) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: dt) + "の合計支出額："
        } else if(kakeiboFlg == 2) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: dt) + "の合計収入額："
        }
        super.viewWillAppear(animated)
        dateCount = 0
        //datetimeFlgは特に意味はない
        if(datetimeFlg == 1) {
            let lm = Calendar.current.date(byAdding: .month, value: -1, to: dt)!
            let nm = Calendar.current.date(byAdding: .month, value: 1, to: dt)!
            
            thisMonth.text = dateFormatter.string(from: dt)
            lastMonth.text = dateFormatterMonthOnly.string(from: lm)
            nextMonth.text = dateFormatterMonthOnly.string(from: nm)
            
            //今月の月初、月末を取得
            let calendar = Calendar(identifier: .gregorian) // 西暦を指定
            let comps = calendar.dateComponents([.year, .month], from: dt)
            let firstDay = calendar.date(from: comps)!
            let nowDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
            let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
            let lastDay = calendar.date(byAdding: add, to: nowDt)!
            startDate = dateFormatterForList.string(from: nowDt).replacingOccurrences(of: "/", with: "-")
            lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        }
        self.updateList()
        totalMoney = 0
    }
    
    //カテゴリ画像表示
    func CategoryImageView(categoryType: String) -> UIImage {
        switch categoryType {
        case "住居費":
            return UIImage(systemName: "house.fill")!
        case "光熱費":
            return UIImage(systemName: "lightbulb.fill")!
        case "食費":
            return UIImage(systemName: "fork.knife")!
        case "交通費":
            return UIImage(systemName: "car.fill")!
        case "通信費":
            return UIImage(systemName: "wifi")!
        case "娯楽費":
            return UIImage(systemName: "star.fill")!
        case "美容費":
            return UIImage(systemName: "scissors")!
        case "被服費":
            return UIImage(systemName: "tshirt.fill")!
        case "交際費":
            return UIImage(systemName: "person.fill")!
        case "医療費":
            return UIImage(systemName: "cross.case.fill")!
        case "保険費":
            return UIImage(systemName: "heart.fill")!
        case "貯蓄":
            return UIImage(systemName: "dollarsign.circle.fill")!
        case "雑費":
            return UIImage(systemName: "ellipsis.circle.fill")!
        case "給与":
            return UIImage(systemName: "yensign.circle.fill")!
        case "その他":
            return UIImage(systemName: "ellipsis.bubble.fill")!
        default:
            return UIImage(systemName: "questionmark")!
        }
    }
    
    //カテゴリ画像色
    func CategoryImageColor(categoryType: String) -> UIColor {
        switch categoryType {
        case "住居費":
            return UIColor.systemGreen
            
        case "光熱費":
            return UIColor.systemOrange
            
        case "食費":
            return UIColor.systemBrown
            
        case "交通費":
            return UIColor.systemIndigo
            
        case "通信費":
            return UIColor.systemPurple
            
        case "娯楽費":
            return UIColor.systemYellow
            
        case "美容費":
            return UIColor.systemMint
            
        case "被服費":
            return UIColor.systemBlue
            
        case "交際費":
            return UIColor.systemGray
            
        case "医療費":
            return UIColor.systemRed
            
        case "保険費":
            return UIColor.systemPink
            
        case "貯蓄":
            return UIColor(red: 0/255, green: 143/255, blue: 1/255, alpha: 1)
            
        case "雑費":
            return UIColor(red: 143/255, green: 110/255, blue: 93/255, alpha: 1)
        
        case "給与":
            return UIColor.systemGreen
        
        case "その他":
            return UIColor.systemBrown
            
        default:
            return UIColor.black
            
        }
    }
    
    //収入ボタンクリック時
    @IBAction func clickIncomBtn(_ sender: Any) {
        ClickedBtn.title = "収入"
        ClickedBtn.baseBackgroundColor = UIColor(red: 0/255, green: 143/255, blue: 1/255, alpha: 1)
        UnClickedBtn.title = "支出"
        
        IncomBtn.configuration = ClickedBtn
        SpendBtn.configuration = UnClickedBtn
        
        kakeiboFlg = 2
        globalTotalAmount = totalAmountCalc.totalAmountCalclator(amountKbn: kakeiboFlg, startDate: startDate, lastDate: lastDate)
        totalAmountStr = amoFormat.amountFormatter(amount: globalTotalAmount)
        TotalMoneyCalc.text = totalAmountStr
        TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: dt) + "の合計収入額："
        
        MoneyTable?.reloadData()
        
    }
    
    //支出ボタンクリック時
    @IBAction func clickSpendBtn(_ sender: Any) {
        ClickedBtn.title = "支出"
        ClickedBtn.baseBackgroundColor = .systemRed
        UnClickedBtn.title = "収入"
        
        
        IncomBtn.configuration = UnClickedBtn
        SpendBtn.configuration = ClickedBtn
        
        kakeiboFlg = 1
        globalTotalAmount = totalAmountCalc.totalAmountCalclator(amountKbn: kakeiboFlg, startDate: startDate, lastDate: lastDate)
        totalAmountStr = amoFormat.amountFormatter(amount: globalTotalAmount)
        TotalMoneyCalc.text = totalAmountStr
        TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: dt) + "の合計支出額："
        
        MoneyTable?.reloadData()
        
    }
    
    //今月の支出/収入額を取得
    let totalAmountCalc = TotalAmount()
    //先月ボタン押下時
    @IBAction func goLastMonth(_ sender: Any) {
        dateCount += -1
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: dt)
        let firstDay = calendar.date(from: comps)!
        
        let previousDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let lm = Calendar.current.date(byAdding: .month, value: -1 + dateCount, to: firstDay)!
        let nm = Calendar.current.date(byAdding: .month, value: 1 + dateCount, to: firstDay)!
        
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: previousDt)!
        
        thisMonth.text = dateFormatter.string(from: previousDt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)

        startDate = dateFormatterForList.string(from: previousDt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        //グローバル変数に代入
        globalDt = previousDt
 
        globalTotalAmount = totalAmountCalc.totalAmountCalclator(amountKbn: kakeiboFlg, startDate: startDate, lastDate: lastDate)
        totalAmountStr = amoFormat.amountFormatter(amount: globalTotalAmount)
        TotalMoneyCalc.text = totalAmountStr
        if(kakeiboFlg == 1) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: previousDt) + "の合計支出額："
        } else if(kakeiboFlg == 2) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: previousDt) + "の合計収入額："
        }
        
        MoneyTable?.reloadData()
    }
    
    //次月ボタン押下時
    @IBAction func goNextMonth(_ sender: Any) {
        dateCount += 1
        
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: dt)
        let firstDay = calendar.date(from: comps)!
        
        let nextDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let lm = Calendar.current.date(byAdding: .month, value: -1 + dateCount, to: firstDay)!
        let nm = Calendar.current.date(byAdding: .month, value: 1 + dateCount, to: firstDay)!
        
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: nextDt)!
        
        thisMonth.text = dateFormatter.string(from: nextDt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        
        startDate = dateFormatterForList.string(from: nextDt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        
        //グローバル変数に代入
        globalDt = nextDt
        
        globalTotalAmount = totalAmountCalc.totalAmountCalclator(amountKbn: kakeiboFlg, startDate: startDate, lastDate: lastDate)
        totalAmountStr = amoFormat.amountFormatter(amount: globalTotalAmount)
        TotalMoneyCalc.text = totalAmountStr
        if(kakeiboFlg == 1) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: nextDt) + "の合計支出額："
        } else if(kakeiboFlg == 2) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: nextDt) + "の合計収入額："
        }
        
        MoneyTable?.reloadData()
    }
    
    //先月ボタンスワイプ時
    @IBAction func goLastMonthSwipe() {
        dateCount += -1
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: dt)
        let firstDay = calendar.date(from: comps)!
        
        let previousDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let lm = Calendar.current.date(byAdding: .month, value: -1 + dateCount, to: firstDay)!
        let nm = Calendar.current.date(byAdding: .month, value: 1 + dateCount, to: firstDay)!
        
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: previousDt)!
        
        thisMonth.text = dateFormatter.string(from: previousDt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)

        startDate = dateFormatterForList.string(from: previousDt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        //グローバル変数に代入
        globalDt = previousDt
 
        globalTotalAmount = totalAmountCalc.totalAmountCalclator(amountKbn: kakeiboFlg, startDate: startDate, lastDate: lastDate)
        totalAmountStr = amoFormat.amountFormatter(amount: globalTotalAmount)
        TotalMoneyCalc.text = totalAmountStr
        if(kakeiboFlg == 1) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: previousDt) + "の合計支出額："
        } else if(kakeiboFlg == 2) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: previousDt) + "の合計収入額："
        }
        
        MoneyTable?.reloadData()
    }
    
    //次月ボタンスワイプ時
    @IBAction func goNextMonthSwipe() {
        dateCount += 1
        
        let calendar = Calendar(identifier: .gregorian) // 西暦を指定
        let comps = calendar.dateComponents([.year, .month], from: dt)
        let firstDay = calendar.date(from: comps)!
        
        let nextDt = Calendar.current.date(byAdding: .month, value: dateCount, to: firstDay)!
        let lm = Calendar.current.date(byAdding: .month, value: -1 + dateCount, to: firstDay)!
        let nm = Calendar.current.date(byAdding: .month, value: 1 + dateCount, to: firstDay)!
        
        let add = DateComponents(month: 1, day: -1) // 月初から1ヶ月進めて1日戻す
        let lastDay = calendar.date(byAdding: add, to: nextDt)!
        
        thisMonth.text = dateFormatter.string(from: nextDt)
        lastMonth.text = dateFormatterMonthOnly.string(from: lm)
        nextMonth.text = dateFormatterMonthOnly.string(from: nm)
        
        startDate = dateFormatterForList.string(from: nextDt).replacingOccurrences(of: "/", with: "-")
        lastDate = dateFormatterForList.string(from: lastDay).replacingOccurrences(of: "/", with: "-")
        
        //グローバル変数に代入
        globalDt = nextDt
        
        globalTotalAmount = totalAmountCalc.totalAmountCalclator(amountKbn: kakeiboFlg, startDate: startDate, lastDate: lastDate)
        totalAmountStr = amoFormat.amountFormatter(amount: globalTotalAmount)
        TotalMoneyCalc.text = totalAmountStr
        if(kakeiboFlg == 1) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: nextDt) + "の合計支出額："
        } else if(kakeiboFlg == 2) {
            TotalMoneyLabel.text = dateFormatterMonthOnly.string(from: nextDt) + "の合計収入額："
        }
        
        MoneyTable?.reloadData()
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

//画像サイズを調整
extension UIImage {
    
    func resize(size: CGSize) -> UIImage {
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
        let resizedSize = CGSize(width: (self.size.width * ratio), height: (self.size.height * ratio))
        // 画質を落とさないように以下を修正
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
