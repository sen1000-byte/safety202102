//
//  MainViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/26.
//

import UIKit
import Firebase
import FirebaseFirestore

class MainViewController: UIViewController {
    
    var userID: String!
    var me: AppUser!
//    var myConnections = [Connect]()
    var friendsActivities = [Activity]()     //0]には自分のuserIDが入っているが、friendsActivitiesには[1]以降が入っている
    
    var dateFormatter = DateFormatter()
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var smileButton: UIButton!
    @IBOutlet var myLatestActivityTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
        setUpMeFromFirestore()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = true
        
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMMHHmm", options: 0, locale: Locale(identifier: "ja_JP"))
        

//        //アカウント登録画面を表示させる
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let signUpStoryboard = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
//        signUpStoryboard.modalPresentationStyle = .fullScreen
//        self.present(signUpStoryboard, animated: true, completion: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    
    func setUpCollectionView() {
        //collectionview
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = UIColor.lightGray
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 30, left: 20, bottom: 8, right: 20)
        collectionViewFlowLayout.minimumLineSpacing = 15
        collectionViewFlowLayout.minimumInteritemSpacing = 10
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: collectionView.frame.width / 2 - 30, height: collectionView.frame.width / 2 - 20)
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
            self.setUpfriendsActivities()
        }
//        //firebase firestoreから情報の引き出し　connectionsに代入
//        Firestore.firestore().collection("connection").getDocuments{ (snaps, error) in
//            if let error = error {
//                print("firestoreからのmyconnectionへのデータの取得に失敗\(error)")
//                return
//            }
//
//            snaps?.documents.forEach({ (snap) in
//                let data = snap.data()
//                let connection = Connect(data: data)
//
//                connection.members.forEach({ (uid) in
//                    if self.me.userID != uid {
//
//                    }
//                })
//
//                self.myConnections.append(connection)
//            })
//        }

    }
    
    func setUpfriendsActivities() {
        if me.friends.count != 1 {
            for i in 0..<me.friends.count {
                Firestore.firestore().collection("activities").document("\(me.friends[i])").getDocument { (snap, error) in
                    if let error = error {
                        print("firestoreからactivityのデータ取得に失敗しました\(error)")
                    }
                    guard let data = snap?.data() else {return}
                    let friendActivity = Activity(data: data)
                    self.friendsActivities.append(friendActivity)
                    print("わからん",i)
                    self.collectionView.reloadData()
                    self.setUpViews()
                }
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
    
    func setUpViews() {
        //更新時間・ボタン
        if let timeStamp = self.friendsActivities[0].latestActiveTime {
            let latestetActiveTime: Date = timeStamp.dateValue()
            smileButton.setImage(compareDate(fromDate: latestetActiveTime), for: .normal)
            self.myLatestActivityTimeLabel.text = self.dateFormatter.string(from: latestetActiveTime)
        }else{
            self.myLatestActivityTimeLabel.text = ""
        }
        
    }
    
    @IBAction func smile() {
        let latestActiveTime = Timestamp()
        Firestore.firestore().collection("activities").document("\(me.userID)").setData(["latestActiveTime": latestActiveTime], merge: true)
        smileButton.setImage(UIImage(named: "smile"), for: .normal)
        myLatestActivityTimeLabel.text = dateFormatter.string(from: latestActiveTime.dateValue())
        
    }
    
    @IBAction func toSetting() {
        performSegue(withIdentifier: "toSetting", sender: userID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetting" {
            let nVC = segue.destination as! SettingTableViewController
            nVC.userID = sender as? String ?? ""
        }
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

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("friendsActivities.count",friendsActivities.count)
        return friendsActivities.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MainCollectionViewCell
        cell.backgroundColor = UIColor.yellow
        cell.layer.cornerRadius = 20
        print("friendsActivities[indexPath.row + 1]", friendsActivities[indexPath.row + 1].userName)
        cell.friendName.text = friendsActivities[indexPath.row + 1].userName
        if let friendLatestActiveTimeStamp = friendsActivities[indexPath.row + 1].latestActiveTime {
            let friendLatestetActiveTime: Date = friendLatestActiveTimeStamp.dateValue()
            cell.smileButton.setImage(compareDate(fromDate: friendLatestetActiveTime), for: .normal)
            cell.timeStamp.text = dateFormatter.string(from: friendLatestetActiveTime)
        }else{
            cell.timeStamp.text = ""
        }

        return cell
    }
    
    
}
