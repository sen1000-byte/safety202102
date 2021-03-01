//
//  SearchViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/28.
//

import UIKit
import Firebase
import FirebaseFirestore

class SearchViewController: UIViewController {
    
    var me: AppUser!
    var userID: String!
    
    @IBOutlet var searchNameTextField: UITextField!
    @IBOutlet var searchEmailTextField: UITextField!
    @IBOutlet var searchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchNameTextField.delegate = self
        searchEmailTextField.delegate = self
        
        loadFromFirestore()
        uiSettings()

        // Do any additional setup after loading the view.
    }
    
    func loadFromFirestore() {
        //firebase firestoreから情報の引き出し
        Firestore.firestore().collection("users").document(userID).getDocument { (snap, error) in
            if let error = error {
                print("firestoreからのデータの取得に失敗\(error)")
                return
            }
            guard let data = snap?.data() else {return}
            self.me = AppUser.init(data: data)
        }
    }
    
    func uiSettings() {
        //見た目系
        searchButton.isEnabled = false
        searchButton.backgroundColor = UIColor.lightGray
    }
    
    
    @IBAction func seach() {
        //もし自分を検索している場合はエラーにする
        if judge(){
            //firesetoreから情報を取ってくる
            Firestore.firestore().collection("users").getDocuments { (snapshots, error) in
                if let error = error {
                    print("firestoreの全ユーザ取得に失敗しました\(error)")
                    return
                }

                snapshots?.documents.forEach({ (snapshot) in
                    let data = snapshot.data()
                    let user = AppUser(data: data)
                    if user.userName == self.searchNameTextField.text && user.email == self.searchEmailTextField.text {
                        let alert = UIAlertController(title: "検索した相手が見つかりました", message: "\(user.userName)を追加しますか", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "はい", style: .default, handler: {action in
                            self.addMyFriends(user: user)
//                            self.createNewConnection(user: user)
                            self.dismiss(animated: true, completion: nil)
                        }))
                        alert.addAction(UIAlertAction(title: "いいえ", style: .destructive, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                //見つからなかった時
                let alert = UIAlertController(title: "エラー", message: "検索した相手が見つかりませんでした。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func judge() -> Bool {
        if me.userName == searchNameTextField.text && me.email == searchEmailTextField.text {
            let alert = UIAlertController(title: "エラー", message: "自分と違うアカウントを検索してください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }else{
            return true
        }
    }
    
    func addMyFriends(user: AppUser) {
        var myFriends: [String?] = self.me.friends
        if myFriends.firstIndex(of: user.userID) != nil {
            let alert = UIAlertController(title: "エラー", message: "すでに登録されています。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }else{
        myFriends.append(user.userID)
            var userFriends = user.friends
            userFriends.append(me.userID)
            Firestore.firestore().collection("users").document(me.userID).setData(["friends": myFriends], merge: true)
            Firestore.firestore().collection("users").document(user.userID).setData(["friends": userFriends], merge: true)
        }
    }
    
//    func createNewConnection(user: AppUser) {
//        let myUid = me.userID
//        let partnerUid = user.userID
//        let members = [myUid, partnerUid]
//        let docData = [
//            "members": members,
//            "createdAt": Timestamp(),
//            "latestTime": Timestamp()
//        ] as [String : Any]
//        Firestore.firestore().collection("connection").addDocument(data: docData) { (error) in
//            if let error = error {
//                print("connectionの情報の保存に失敗しました。\(error)")
//            }
//            
//        }
//    }
    
    //検索が一致した時に行う
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
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

extension SearchViewController: UITextFieldDelegate{
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
