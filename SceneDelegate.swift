//
//  SceneDelegate.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/07/31.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let storyboard:UIStoryboard = self.grabStoryboard()
                        
                 if let window = window{
                           window.rootViewController = storyboard.instantiateInitialViewController() as UIViewController?
                        }
                   self.window?.makeKeyAndVisible()
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
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
               }else if height == 736 {
                   storyboard = UIStoryboard(name: "iPhone8plus", bundle: nil)
                   //iPhone6,7,8plus
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

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

