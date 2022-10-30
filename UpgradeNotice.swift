//
//  UpgradeNotice.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/09/20.
//

import Foundation
import UIKit

class UpgradeNotice {
    internal static let shared = UpgradeNotice()
    public init() {}
    
    public let apple_id = "1644662833"
    //URL：https://itunes.apple.com/jp/lookup?id=1644662833
            
//    internal func fire() {
//        guard let url: URL = URL(string: "https://itunes.apple.com/jp/lookup?id=\(apple_id)") else {
//            return
//        }
// 
//        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
//        
//        let task = URLSession.shared.dataTask(with: url) {data, response, error in
//            // コンソールに出力
//            print("data: \(String(describing: data))")
//            print("response: \(String(describing: response))")
//            print("error: \(String(describing: error))")
//            guard let data = data else {
//                return
//            }
//
//            do {
//                let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//                guard let storeVersion = ((jsonData?["results"] as? [Any])?.first as? [String : Any])?["version"] as? String,
//                      let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
//                    return
//                }
//                switch storeVersion.compare(appVersion, options: .numeric) {
//                case .orderedDescending:
//                    DispatchQueue.main.async {
//                        self.showAlert()
//                    }
//                    return
//                case .orderedSame, .orderedAscending:
//                    return
//                }
//            }catch {
//            }
//        }
//        task.resume()
//    }
    
    func appVersionCheck() {
        guard let info = Bundle.main.infoDictionary,
            let appVersion = info["CFBundleShortVersionString"] as? String,
//            let identifier = info["CFBundleIdentifier"] as? String,
//            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else { return }
              let url = URL(string: "https://itunes.apple.com/jp/lookup?id=1644662833") else {
            return
        }
         
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any],
                      let storeVersion = result["version"] as? String else { return }
                if appVersion != storeVersion {
                    // appVersion と storeVersion が異なっている時に実行したい処理を記述
                    self.showAlert()
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    public func showAlert() {
        guard let parent = topViewController() else {
            return
        }
        let actionA = UIAlertAction(title: "更新", style: .default, handler: {
                    (action: UIAlertAction!) in
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(self.apple_id)"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        let actionB = UIAlertAction(title: "あとで", style: .default, handler: {
                    (action: UIAlertAction!) in
        })
        
        let alert: UIAlertController = UIAlertController(title: "最新バージョンのお知らせ", message: "最新バージョンがあります。", preferredStyle: .alert)
        alert.addAction(actionA)
        alert.addAction(actionB)
        DispatchQueue.main.sync {
            // code...
            parent.present(alert, animated: true, completion: nil)
        }

    }
    
    public func topViewController() -> UIViewController? {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        return vc
    }

}
