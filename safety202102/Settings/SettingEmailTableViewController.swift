//
//  SettingEmailTableViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/07.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SettingEmailTableViewController: UITableViewController {
    
    //受け取り用
    var me: AppUser!
    var verifiedPassword: String!
    var whetherVerified: Bool! = nil
    
    @IBOutlet var previousEmailLabel: UILabel!
    @IBOutlet var newEmailTextField: UITextField!
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //見た目
        self.tableView.backgroundColor = UIColor.backGroundGreenColor()
        
        
        newEmailTextField.delegate = self
        previousEmailLabel.text = me.email
        //ボタン設定
        doneBarButtonItem.isEnabled = false
        doneBarButtonItem.tintColor = UIColor.darkGray
        doneBarButtonItem.style = .plain
        
        //パスワード認証画面を表示させる
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
        verifyVC.modalPresentationStyle = .fullScreen
        verifyVC.flagToPreVCInt = 1
        self.present(verifyVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //認証をキャンセルしたら戻る
        if whetherVerified == false {
            //ひとつ前の画面に戻る
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if whetherVerified == true {
            let nav = self.navigationController!
            //呼び出し元のView Controllerを遷移履歴から取得しパラメータを渡す
            let bVC = nav.viewControllers[nav.viewControllers.count-1] as! SettingTableViewController
            bVC.me = me
        }
    }
    
    @IBAction func done() {
        if whetherVerified == nil {
            print("認証エラー")
            return
        }
        
        let email: String = newEmailTextField.text ?? ""
        
//        let user = Auth.auth().currentUser
//        var credential: AuthCredential
//
//        // Prompt the user to re-provide their sign-in credentials
//
//        user?.reauthenticate(with: credential) { error in
//          if let error = error {
//            // An error happened.
//          } else {
//            // User re-authenticated.
//          }
//        }

        
        
//        //現在のユーザー情報を取得
//        if let user = Auth.auth().currentUser {
//            //引数としてcredentialを生成　credential：保証書・証明書という意味
//            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: verifiedPassword)
//            //再認証をする
//            user.reauthenticate(with: credential, completion: { authResult, error in
//                //認証のエラー
//                if let error = error {
//                    //!!!!!!podでエラー文章
//                    print("ユーザ認証に失敗しました。\(error)")
//                    return
//                }
                //認証ができたらemailの更新
//                user.updateEmail(to: email) { error in
        Auth.auth().currentUser?.updateEmail(to: email) { error in
                    //emailのエラー
                    if let error = error {
                        //!!!!!!!!!!!!!!!!podのをインストールしたやつでエラーを表示させる！！！！！！！
                        print("メールアドレスの更新に失敗しました\(error)")
                        return
                    }
                    //エラーじゃない場合は、firestoreに上書き保存
                    Firestore.firestore().collection("users").document(self.me.userID).setData(["email": email], merge: true)
                    //エラーじゃない場合は、meを変更する
                    self.me.email = email
            self.navigationController?.popViewController(animated: true)
                }
//            })
//        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

   

    
}

extension SettingEmailTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //入力があるたびに呼ばれる・入力判定
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let newEmailIsEmpty = newEmailTextField.text?.isEmpty ?? true
        if newEmailIsEmpty {
            doneBarButtonItem.isEnabled = false
            doneBarButtonItem.tintColor = UIColor.darkGray
            doneBarButtonItem.style = .plain
        }else {
            doneBarButtonItem.isEnabled = true
            doneBarButtonItem.tintColor = UIColor.orange
            doneBarButtonItem.style = .done
        }
    }
    
}
