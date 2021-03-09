//
//  MainViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/26.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class MainViewController: UIViewController {
    
    var userID: String!
    var me: AppUser!
//    var myConnections = [Connect]()
    var friendsDictionary = [Int: Activity]()
    
    var dateFormatter = DateFormatter()
    
    var settingButtonItem: UIBarButtonItem!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var smileButton: UIButton!
    @IBOutlet var myLatestActivityTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = Auth.auth().currentUser!.uid
        
        setUpCollectionView()
//        setUpMeFromFirestore()

        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
//        navigationController?.navigationItem.setRightBarButton(settingButtonItem, animated: false)

        settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingBarButtonTapped))
        settingButtonItem.tintColor = UIColor.darkGray
        self.parent?.navigationItem.rightBarButtonItem = settingButtonItem

        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMMHHmm", options: 0, locale: Locale(identifier: "ja_JP"))
        
        //smilebuttonの見た目
        smileButton.layer.shadowColor = UIColor.lightGray.cgColor
        smileButton.layer.shadowOffset = CGSize(width: 8, height: 8)
        smileButton.layer.shadowRadius = 3
        smileButton.layer.shadowOpacity = 1
        

//        //アカウント登録画面を表示させる
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let signUpStoryboard = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
//        signUpStoryboard.modalPresentationStyle = .fullScreen
//        self.present(signUpStoryboard, animated: true, completion: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        setUpMeFromFirestore()
//        collectionView.reloadData()
        
    }
    
    func setUpCollectionView() {
        //collectionview
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = UIColor.white
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 8, right: 20)
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
            self.setUpfriendsDictionaly()
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
    
    func setUpfriendsDictionaly() {
        //friendsDictionaryを初期化
        friendsDictionary = [:]
        for i in 0..<me.friends.count {
            Firestore.firestore().collection("activities").document("\(me.friends[i])").getDocument { (snap, error) in
                if let error = error {
                    print("firestoreからactivityのデータ取得に失敗しました\(error)")
                }
                guard let data = snap?.data() else {return}
                let friend = Activity(data: data)
                self.friendsDictionary[i] = friend
                
                self.collectionView.reloadData()
                self.setUpViews()
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
        //タイトル
        self.parent?.navigationItem.title = me.userName
        //更新時間・ボタン
        let timeStamp = friendsDictionary[0]?.latestActiveTime ?? Timestamp(seconds: 0, nanoseconds: 0)
        if  timeStamp != Timestamp(seconds: 0, nanoseconds: 0) {
            let latestetActiveTime: Date = timeStamp.dateValue()
            smileButton.setImage(compareDate(fromDate: latestetActiveTime), for: .normal)
            myLatestActivityTimeLabel.text = self.dateFormatter.string(from: latestetActiveTime)
        }else{
            myLatestActivityTimeLabel.text = ""
            smileButton.setImage(UIImage(named: "smileloading"), for: .normal)
        }
    }
    
    @IBAction func smile() {
        let latestActiveTime = Timestamp()
        Firestore.firestore().collection("activities").document("\(me.userID)").setData(["latestActiveTime": latestActiveTime], merge: true)
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

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendsDictionary.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MainCollectionViewCell
        //cellの見た目系
        cell.backgroundColor = UIColor.lightPinkColor()
        cell.layer.cornerRadius = 10
        //cellの表示系
        cell.friendName.text = friendsDictionary[indexPath.row + 1]?.userName
        let friendLatestActiveTimeStamp = friendsDictionary[indexPath.row + 1]?.latestActiveTime ?? Timestamp(seconds: 0, nanoseconds: 0)
        if  friendLatestActiveTimeStamp != Timestamp(seconds: 0, nanoseconds: 0)  {
            let friendLatestetActiveTime: Date = friendLatestActiveTimeStamp.dateValue()
            cell.smileButton.setImage(compareDate(fromDate: friendLatestetActiveTime), for: .normal)
            cell.timeStamp.text = dateFormatter.string(from: friendLatestetActiveTime)
        }else{
            cell.timeStamp.text = "活動記録がありません"
            cell.smileButton.setImage(UIImage(named: "smileloading"), for: .normal)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var header: UICollectionReusableView? = nil
        if kind == "UICollectionElementKindSectionHeader" {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? MainCollectionViewHeader
        }
        return header!
    }
    
}
