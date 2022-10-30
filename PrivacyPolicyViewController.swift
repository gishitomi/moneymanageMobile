//
//  PrivacyPolicyViewController.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/09/01.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {
    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        webView = WKWebView(frame: view.frame)

                view.addSubview(webView)

                // MARK: HTML
                /// HTMLのファイルURLを取得する
                guard let html = Bundle.main.url(forResource: "index", withExtension: "html")  else { return }
                /// ファイルURLからファイルの内容をStringで取得
                guard let htmlString = try? String(contentsOf: html) else { return }

                // MARK: CSS
                /// CSSのファイルURLを取得する
                guard let css = Bundle.main.url(forResource: "style", withExtension: "css")  else { return }

                // MARK: 読み込み
                webView.loadHTMLString(htmlString, baseURL: css)
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
