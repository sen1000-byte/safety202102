//
//  SearchFriendViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/09.
//

import UIKit
import FirebaseFirestore

class SearchFriendViewController: UIViewController{
    
    //受け取り用
    var me: AppUser!
    var friendsDictionary = [Int: Activity]()    //friendsDictionalyには0:自分,後は友達のactivityが入っている。最後尾me.friends.count-1
    var flagForPreVCInt: Int = 0
    
    @IBOutlet var searchNameTextField: UITextField!
    @IBOutlet var searchEmailTextField: UITextField!
    @IBOutlet var searchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(flagForPreVCInt)
        
        //見た目系
        setViews()
        
        //キーボード関係
        searchNameTextField.delegate = self
        searchEmailTextField.delegate = self

    }
    
    //見た目系
    func setViews() {
        searchButton.isEnabled = false
        searchButton.backgroundColor = UIColor.lightGray
        searchButton.layer.cornerRadius = 20
        searchButton.layer.shadowColor = UIColor.lightGray.cgColor
        searchButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        searchButton.layer.shadowRadius = 3
        searchButton.layer.shadowOpacity = 1
    }
    
    //キャンセル時
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    //登録ボタンが押された時
    @IBAction func search() {
        let friendEmail = searchEmailTextField.text ?? ""
        let friendUserName = searchNameTextField.text ?? ""
        
        //自分を検索していないか
        if friendEmail == me.email && friendUserName == me.userName {
            //!!!!!!!!!!!!!!!!!!自分を検索してます!!!!!!!!!
            let alert = UIAlertController(title: "エラー", message: "自分と違うアカウントを検索してください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        //firestoreからユーザー名・メールアドレスが同じ人のみのデータを得る
        Firestore.firestore().collection("users").whereField("email", isEqualTo: friendEmail).whereField("userName", isEqualTo: friendUserName).getDocuments{ (snapshots, error) in
            
            //エラーが起きた時
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            if let numOfResult = snapshots?.count {
                switch numOfResult {
                case 0:     //見つからなかった&０と表示された
                    let alert = UIAlertController(title: "エラー", message: "相手が見つかりませんでした。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                case 1:     //正常に見つかった
                    print("1と表示されました")
                    snapshots?.documents.forEach( { (snapshot) in
                        let data = snapshot.data()
                        let friendUser = AppUser(data: data)
                        
                        //過去に追加したことがないか
                        let myFriens = self.me.friends
                        if myFriens.firstIndex(of: friendUser.userID) != nil {
                            let alert = UIAlertController(title: "エラー", message: "すでに登録されています。", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        
                        //追加する
                        self.addAlert(friendUser: friendUser)
                    })
                default:    //みつかりすぎた時
                    print("複数見つかりました")
                    return
                }
            } else {
                // !!!!!!!エラー　nilと表示された　←これは基本発動されない。
                print("エラー、nilです")
                return
            }
        }
    }
    
    //追加するためのアラートのメソッド
    func addAlert(friendUser: AppUser) {
        let alert = UIAlertController(title: "検索した相手が見つかりました", message: "\(friendUser.userName)を追加しますか", preferredStyle: .alert)
        
        //アラートのはいを作成
        alert.addAction(UIAlertAction(title: "はい", style: .default, handler: {action in
            var myFriends = self.me.friends
            let numOfFriends = myFriends.count
            //データを追加する
            //meに追加
            myFriends.append(friendUser.userID)
            
            //自分のfriendsのデータを更新
            Firestore.firestore().collection("users").document(self.me.userID).setData(["friends": myFriends], merge: true)
            
            //相手のfriedsに追加
            var friendFriends = friendUser.friends
            friendFriends.append(self.me.userID)
            
            //相手のfriendsを更新
            Firestore.firestore().collection("users").document(friendUser.userID).setData(["friends": friendFriends], merge: true)
            
            //friendsDictionalyの編集
            //friendのActivityを取得
            Firestore.firestore().collection("activities").document("\(friendUser.userID)").getDocument { (snap, error) in
                if let error = error {
                    print("firestoreからfriendのactivityのデータ取得に失敗しました\(error)")
                }
                guard let data = snap?.data() else {return}
                let friendActivity = Activity(data: data)
                self.friendsDictionary[numOfFriends] = friendActivity
                
                self.prepareToPreVC()
                //画面を閉じる
                self.dismiss(animated: true, completion: nil)
            }
        }))
        
        //アラートにいいえの追加
        alert.addAction(UIAlertAction(title: "いいえ", style: .destructive, handler: nil))
        
        //アラート発動
        present(alert, animated: true, completion: nil)
    }
    
    //画面遷移用　値を渡すためのメソッド
    func prepareToPreVC() {
        
        switch flagForPreVCInt {
        
        case 1:    //SettingViewControllerに戻る
            let preNC = self.presentingViewController as! UINavigationController
            let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! SettingTableViewController
            //値代入
            preVC.me = me
            preVC.friendsDictionary = friendsDictionary
            
        case 2:    //mainViewControllerに戻る
            //navigationcontrollerを取得
            let preNC = self.presentingViewController as! UINavigationController
            //tabBarControllerが取得される
            let preTVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! TabBarViewController
            //一番最近に選んだviewControllerを取得する。
            let preVC = preTVC.selectedViewController as! MainViewController
            //リロードを行う
            preVC.reloadView()
            
        default:   //エラーor値受け取り失敗
            return
        }
    }
}

extension SearchFriendViewController: UITextFieldDelegate{
    
    //入力があるたびに呼ばれる・入力判定
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let searchNameIsEmpty = searchNameTextField.text?.isEmpty ?? true
        let searchEmailIsEmpty = searchEmailTextField.text?.isEmpty ?? true
        
        if searchNameIsEmpty || searchEmailIsEmpty {
            searchButton.isEnabled = false
            searchButton.backgroundColor = UIColor.lightGray
        }else{
            searchButton.isEnabled = true
            searchButton.backgroundColor = UIColor.orange
        }
    }
    
    //エンターが押された時に呼ばれる・キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
