//
//  TabBarViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/04.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TabBarViewController: UITabBarController {
    
    var userID: String!
    var settingButtonItem: UIBarButtonItem!
    
    let userdefaults = UserDefaults.standard
    var easyModeBool: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notification()
        setNotification()
        
        navigationItem.hidesBackButton = true
//        navigationController?.setNavigationBarHidden(false, animated: false)
//        navigationController?.setToolbarHidden(true, animated: false)
        
        easyModeBool = userdefaults.bool(forKey: "easyMode")
        let mytabBarController: UITabBarController = self
        mytabBarController.tabBar.isHidden = true
        print("bool", mytabBarController.tabBar.isHidden)
        if easyModeBool {
            selectedIndex = 1
        }else {
            selectedIndex = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        easyModeBool = userdefaults.bool(forKey: "easyMode")
        self.tabBarController?.tabBar.isHidden = true
        print("bool",easyModeBool)
        if easyModeBool {
            selectedIndex = 1
        }else {
            selectedIndex = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingBarButtonTapped))
        self.parent?.navigationItem.rightBarButtonItem = settingButtonItem
    }
    
    @objc func settingBarButtonTapped() {
        performSegue(withIdentifier: "toSetting", sender: userID)
    }
    
    // Do any additional setup after loading the view.
}



// アクションをenumで宣言
enum ActionIdentifier: String {
    case actionOne
}


//通知許可を求める
extension TabBarViewController: UNUserNotificationCenterDelegate {
    //通知許可を求める
    func notification() {
        //ios10以上と9以下で分ける
        if #available(iOS 10.0, *) {
            // iOS 10
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                if error != nil {
                    return
                }
                
                if granted {
                    print("通知許可")
                    
                    let center = UNUserNotificationCenter.current()
                    center.delegate = self
                    
                } else {
                    print("通知拒否")
                }
            })
            
        } else {
            // iOS 9以下
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    func setNotification() {
        // アクション設定
        let actionOne = UNNotificationAction(identifier: ActionIdentifier.actionOne.rawValue,
                                             title: "天気を見て安否を伝える",
                                             options: [.foreground])
        
        let category = UNNotificationCategory(identifier: "safty",
                                              actions: [actionOne],
                                              intentIdentifiers: [],
                                              options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = self
        

//        //　通知設定に必要なクラスをインスタンス化
//        let trigger: UNNotificationTrigger
        //通知に中身を設定する
        let content = UNMutableNotificationContent()
        var dateComponents = DateComponents()

        
        // トリガー設定
        dateComponents.hour = 6
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)

        
        // 通知内容の設定
        content.title = "おはようございます！"
        content.body = "アプリを開いて天気をみよう！"
        content.sound = UNNotificationSound.default
        // categoryIdentifierを設定
        content.categoryIdentifier = "safty"

        
        // 通知スタイルを指定
        let request = UNNotificationRequest(identifier: "safty", content: content, trigger: trigger)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // アクションを押されると呼び出される
       @available(iOS 10.0, *)
       func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   didReceive response: UNNotificationResponse,
                                   withCompletionHandler completionHandler: () -> Swift.Void) {

           // 選択されたアクションごとに処理を分けることができる（今は１つのアクションのみ）
           switch response.actionIdentifier {

           case ActionIdentifier.actionOne.rawValue:
               //安否を記録する
            //今のログインしているiDを取得
            if let userID = Auth.auth().currentUser?.uid {
                //現在時刻を取得
                let latestActiveTime = Timestamp()
                //安否を記録する
                Firestore.firestore().collection("activities").document("\(userID)").setData(["latestActiveTime": latestActiveTime], merge: true)
            }
           default:
               ()
           }

           completionHandler()
       }
    
}

