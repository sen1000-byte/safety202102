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

class AlternateViewController: UIViewController {
    
    @IBOutlet var whetherLabel: UILabel!
    @IBOutlet var smileButton: UIButton!
    @IBOutlet var myLatestActivityTimeLabel: UILabel!
    
    var userID: String!
    var me: AppUser!
    var friendsDictionary = [Int: Activity]()
    
    var dateFormatter = DateFormatter()
    var settingButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = Auth.auth().currentUser!.uid
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
        
        settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingBarButtonTapped))
        self.parent?.navigationItem.rightBarButtonItem = settingButtonItem
        
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
