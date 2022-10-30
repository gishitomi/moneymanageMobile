//
//  AppDelegate.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/07/31.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard:UIStoryboard = self.grabStoryboard()
                        
                 if let window = window{
                           window.rootViewController = storyboard.instantiateInitialViewController() as UIViewController?
                        }
                   self.window?.makeKeyAndVisible()
        //ios15でスクロールバーが黒くなるのを防ぐ
        if #available(iOS 15.0, *) {
            // disable UITab bar transparent
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().standardAppearance = tabBarAppearance
        }
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
    
    func grabStoryboard() -> UIStoryboard{
               
               var storyboard = UIStoryboard()
               let height = UIScreen.main.bounds.size.height
               if height == 896 {
                   storyboard = UIStoryboard(name: "Main", bundle: nil)
                   //iPhone11
               }else if height == 667 {
                   storyboard = UIStoryboard(name: "iPhoneSE2", bundle: nil)
                   //iPhoneSE2
               }else if height == 812{
                   storyboard = UIStoryboard(name: "iPhone12mini", bundle: nil)
                   //iPhone12,13mini
               }else if height == 844{
                   storyboard = UIStoryboard(name: "iPhone12", bundle: nil)
                   //iPhone12,13
               }else if height == 926{
                   storyboard = UIStoryboard(name: "iPhone12ProMax", bundle: nil)
                   //iPhone12,13ProMax
               } else if height == 1112{
                   storyboard = UIStoryboard(name: "iPad", bundle: nil)
               }else{
                   
                   switch UIDevice.current.model {
                   case "iPnone" :
                   storyboard = UIStoryboard(name: "se", bundle: nil)
                       break
                   case "iPad" :
                   storyboard = UIStoryboard(name: "iPad", bundle: nil)
                   print("iPad")
                       break
                   default:
                   storyboard = UIStoryboard(name: "iPhoneSE2", bundle: nil)
                       break
                   }
               }
               return storyboard
       }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

