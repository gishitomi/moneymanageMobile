//
//  SettingViewController.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/08/31.
//

import UIKit
import GoogleMobileAds
import StoreKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    @IBOutlet var settingTable: UITableView!

    //広告バー
    var bannerView: GADBannerView!
    //情報
    var info: Dictionary<String, [String]> = ["name":[], "value":[]]
    //セクション名
    var sectionTitle: [String] = ["情報"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        settingTable.delegate = self
        settingTable.dataSource = self
        
        info["name"]?.append("バージョン")
        info["name"]?.append("プライバシーポリシー")
        info["name"]?.append("レビューする")
        
        //現在のバージョン
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        info["value"]?.append(version)
        info["value"]?.append("")
        info["value"]?.append("")
        //スクロールさせない
        settingTable.isScrollEnabled = false
        
        bannerView.adUnitID = adUnitIdFooter
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self

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

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return info["name"]!.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = settingTable.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        
        if indexPath.section == 0 {
            if info["value"]?[indexPath.row] == "" {
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.textLabel?.text = info["name"]?[indexPath.row]
            } else {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "")
                cell.textLabel?.text = info["name"]?[indexPath.row]
                cell.detailTextLabel?.text = info["value"]?[indexPath.row]
                cell.detailTextLabel?.textColor = .lightGray
            }
            //ハイライトさせない
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        if info["value"]?[indexPath.row] == "" {
            if info["name"]?[indexPath.row] == "プライバシーポリシー" {
                //Segueの呼び出し
                performSegue(withIdentifier: "policyDetail",sender: nil)
            } else if info["name"]?[indexPath.row] == "レビューする" {
                let url = URL(string: "https://apps.apple.com/app/1644662833?action=write-review")!
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            
        }

    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "policyDetail") {
            let subVC: PrivacyPolicyViewController = (segue.destination as? PrivacyPolicyViewController)!
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
