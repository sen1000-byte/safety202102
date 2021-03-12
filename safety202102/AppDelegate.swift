//
//  AppDelegate.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/25.
//

import UIKit
import Firebase
import EAIntroView

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        //初回起動かどうかを判断するためのuserdefaults
//        let launchedBeforeBool = UserDefaults.standard.bool(forKey: "launchedBefore")
//        //初回起動かどうかを判断
//        if launchedBeforeBool == true {
//            print("以前に開いたことがあります")
//        }else{
//            showWalkthrough()
//            //userDefaultsを更新する
//            UserDefaults.standard.setValue(true, forKey: "launchedBefore")
//        }
        
        
        FirebaseApp.configure()
        return true
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
