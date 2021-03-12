//
//  AlternateViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/27.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import EAIntroView

class AlternateViewController: UIViewController {
    
    @IBOutlet var whetherLabel: UILabel!
    @IBOutlet var smileButton: UIButton!
    @IBOutlet var myLatestActivityTimeLabel: UILabel!
    
    var userID: String!
    var me: AppUser!
    var friendsDictionary = [Int: Activity]()
    
    var dateFormatter = DateFormatter()
    var settingButtonItem: UIBarButtonItem!
    var walkthroughButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = Auth.auth().currentUser!.uid
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
        
        settingButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(settingBarButtonTapped))
        walkthroughButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(showWalkthrough))
        
        walkthroughButtonItem.tintColor = UIColor.darkGray
        settingButtonItem.tintColor = UIColor.darkGray
        self.parent?.navigationItem.rightBarButtonItems = [settingButtonItem, walkthroughButtonItem]
        
        
//        settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingBarButtonTapped))
//        self.parent?.navigationItem.rightBarButtonItem = settingButtonItem
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMMHHmm", options: 0, locale: Locale(identifier: "ja_JP"))
        
        //smilebuttonの見た目
        smileButton.layer.shadowColor = UIColor.lightGray.cgColor
        smileButton.layer.shadowOffset = CGSize(width: 8, height: 8)
        smileButton.layer.shadowRadius = 3
        smileButton.layer.shadowOpacity = 1

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        hidesBottomBarWhenPushed = true
        setUpMeFromFirestore()
    }
    
    func setUpMeFromFirestore() {
        //firebase firestoreから情報の引き出し meに代入
        Firestore.firestore().collection("users").document(userID!).getDocument { (snap, error) in
            if let error = error {
                print("firestoreからのmeへのデータの取得に失敗\(error)")
                return
            }
            guard let data = snap?.data() else {return}
            let meTemp = AppUser(data: data)
            self.me = meTemp
            self.setUpViews()
            self.setUpfriendsDictionaly()
        }
    }
    
    func setUpfriendsDictionaly() {
        for i in 0..<me.friends.count {
            Firestore.firestore().collection("activities").document("\(me.friends[i])").getDocument { (snap, error) in
                if let error = error {
                    print("firestoreからactivityのデータ取得に失敗しました\(error)")
                }
                guard let data = snap?.data() else {return}
                let friend = Activity(data: data)
                self.friendsDictionary[i] = friend
            }
        }
    }
    
    
    func setUpViews() {
        //タイトル
        self.parent?.navigationItem.title = me.userName
        Firestore.firestore().collection("activities").document(userID).getDocument { (snap, error) in
            if let error = error {
                print("firestoreからactivityのデータ取得に失敗しました\(error)")
            }
            //更新時間・ボタン
            guard let data = snap?.data() else {return}
            let myActivity = Activity(data: data)
            let timeStamp = myActivity.latestActiveTime ?? Timestamp(seconds: 0, nanoseconds: 0)
            if  timeStamp != Timestamp(seconds: 0, nanoseconds: 0) {
                let latestetActiveTime: Date = timeStamp.dateValue()
                self.smileButton.setImage(self.compareDate(fromDate: latestetActiveTime), for: .normal)
                self.myLatestActivityTimeLabel.text = self.dateFormatter.string(from: latestetActiveTime)
            }else{
                self.myLatestActivityTimeLabel.text = ""
                self.smileButton.setImage(UIImage(named: "smileloading"), for: .normal)
            }
        }
    }

    
    func compareDate(fromDate: Date) -> UIImage{
        let toDate = Timestamp().dateValue()
        let elapsedDays = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day!
        switch elapsedDays {
        case 0:
            return UIImage(named: "smile")!
        case 1:
            return UIImage(named: "smileone")!
        case 2:
            return UIImage(named: "smiletwo")!
        case 3:
            return UIImage(named: "smilethree")!
        case 4:
            return UIImage(named: "smilefour")!
        default:
            return UIImage(named: "smilefive")!
        }
    }
    
    @IBAction func smile() {
        let latestActiveTime = Timestamp()
        Firestore.firestore().collection("activities").document(userID).setData(["latestActiveTime": latestActiveTime], merge: true)
        smileButton.setImage(UIImage(named: "smile"), for: .normal)
        myLatestActivityTimeLabel.text = dateFormatter.string(from: latestActiveTime.dateValue())
        //情報の更新
        setUpMeFromFirestore()
    }
    
    @objc func settingBarButtonTapped() {
        performSegue(withIdentifier: "toSetting", sender: userID)
    }
    
    @IBAction func toSetting() {
        performSegue(withIdentifier: "toSetting", sender: userID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetting" {
            let nVC = segue.destination as! SettingTableViewController
            nVC.userID = sender as? String ?? ""
            nVC.me = me
            nVC.friendsDictionary = friendsDictionary
        }
    }

}


// MARK: -extensions


//walkthroughを表示させるためのextension
extension AlternateViewController: EAIntroDelegate {
    
    //walkthroughを表示させるfunc
    @objc func showWalkthrough() {
        
        let page1 = EAIntroPage()
        page1.title = "インストールありがとうございます！！"
        page1.titleColor = UIColor.darkGray
        page1.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page1.desc = "天気を確認しつつ、家族や友人の安全を把握できるアプリです。"
        page1.descColor = UIColor.darkGray
        page1.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page1.bgColor = UIColor.init(red: 242 / 255, green: 255 / 255, blue: 220 / 255, alpha: 1)
        page1.bgImage = UIImage(named: "walkthrough1")
         
        let page2 = EAIntroPage()
        page2.title = "仲間を登録して安否をチェック！"
        page2.titleColor = UIColor.darkGray
        page2.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page2.desc = "ボタンを押すことで、登録しておいた相手の画面に自分の安否が反映されます。"
        page2.descColor = UIColor.darkGray
        page2.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page2.bgColor = UIColor.init(red: 207 / 255, green: 249 / 255, blue: 244 / 255, alpha: 1)
        page2.bgImage = UIImage(named: "walkthrough2")
         
        let page3 = EAIntroPage()
        page3.title = "一目で安否確認！"
        page3.titleColor = UIColor.darkGray
        page3.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page3.desc = "更新時刻に合わせて、画像が変化します"
        page3.descColor = UIColor.darkGray
        page3.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page3.bgColor = UIColor.init(red: 255 / 255, green: 222 / 255, blue: 231 / 255, alpha: 1)
        page3.bgImage = UIImage(named: "walkthrough3")
        
        let page4 = EAIntroPage()
        page4.title = "選べる２つのモード"
        page4.titleColor = UIColor.darkGray
        page4.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page4.desc = "通常モードでは、自分と登録した仲間の活動状況が確認できます。簡単モードでは自分の活動状況のみが表示されます。"
        page4.descColor = UIColor.darkGray
        page4.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page4.bgColor = UIColor.init(red: 252 / 255, green: 255 / 255, blue: 199 / 255, alpha: 1)
        page4.bgImage = UIImage(named: "walkthrough4")
        
        let page5 = EAIntroPage()
        page5.title = "通知機能でリマインド"
        page5.titleColor = UIColor.darkGray
        page5.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page5.desc = "毎朝６時に自分の安否を更新するよう、通知します。"
        page5.descColor = UIColor.darkGray
        page5.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page5.bgColor = UIColor.init(red: 255 / 255, green: 253 / 255, blue: 235 / 255, alpha: 1)
        page5.bgImage = UIImage(named: "walkthrough5")
         
        //ここでページを追加
        let introView = EAIntroView(frame: self.view.bounds, andPages: [page1, page2, page3, page4, page5])
        //スキップボタン
        introView?.skipButton.tintColor = UIColor.darkGray
        introView?.skipButton.setTitle("スキップ", for: UIControl.State.normal)
        
        //ページコントロール
        introView?.pageControl.tintColor = UIColor.darkGray
         
        introView?.delegate = self
        introView?.show(in: self.view, animateDuration: 1.0)
        
    }
}

