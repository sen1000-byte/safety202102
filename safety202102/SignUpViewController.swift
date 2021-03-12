//
//  SignUpViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/26.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import EAIntroView

class SignUpViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var userDefaults = UserDefaults.standard
    var easyModeBool: Bool!
    var isFirstStartBool: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //見た目
        registerButton.layer.cornerRadius = 20
        registerButton.layer.shadowColor = UIColor.lightGray.cgColor
        registerButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        registerButton.layer.shadowRadius = 3
        registerButton.layer.shadowOpacity = 1
        
        navigationController?.setNavigationBarHidden(true, animated: false)

        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //ボタンを無効にする
        registerButton.isEnabled = false
        registerButton.backgroundColor = UIColor.lightGray
        
        //簡単モードか否か
        easyModeBool = userDefaults.bool(forKey: "easyMode")
        
        //初回起動か否か
        isFirstStartBool = userDefaults.bool(forKey: "isFirstStart")//trueの場合は初回でない、falseの時は初回
        //初回の場合、walkthroughを表示する
        print("isFirstStartBool", isFirstStartBool)
        if isFirstStartBool == false {
            showWalkthrough()
            userDefaults.setValue(true, forKey: "isFirstStart")
        } else {
            print("viewdidloadだよ")
            //初回起動時でない&ログインしている状態
            if let user = Auth.auth().currentUser {
                let userID = user.uid
                toMain(userID: userID)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        //チュートリアルが終わってから起こる想定
//        if isFirstStartBool == true {
//            //ログインしている状態
//            if let user = Auth.auth().currentUser {
//                let userID = user.uid
//                toMain(userID: userID)
//            }
//        }

    }
    
    //ログインしていた場合に画面を飛ばす
    func toMain(userID: String) {
        
//        if easyModeBool {
//            //２つ先へ一気に遷移
//            let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
//            let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "AlternateViewController") as! AlternateViewController
//            // 遷移後のViewControllerの配列を作成
//            let ar = [self, vc2, vc3]
//            //データの受け渡し
//            vc3.userID = userID
//            // まとめて設定
//            self.navigationController?.setViewControllers(ar, animated: false)
//        }else{
//            //２つ先へ一気に遷移
//            let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
//            let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//            // 遷移後のViewControllerの配列を作成
//            let ar = [self, vc2, vc3]
//            //データの受け渡し
//            vc3.userID = userID
//            // まとめて設定
//            self.navigationController?.setViewControllers(ar, animated: false)
//        }
        // ２つ先へ一気に遷移
        let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        // 遷移後のViewControllerの配列を作成
        let ar = [self, vc2, vc3]
        //データの受け渡し
        vc3.userID = userID
        // まとめて設定
        self.navigationController?.setViewControllers(ar, animated: false)
//        let nVC = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//        nVC.userID = userID
//        
//        
//        self.navigationController?.pushViewController(nVC, animated: false)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func register(_ sender: Any) {
        guard let usertName = userNameTextField.text else {return}
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        let updatedAt = Timestamp()
        
        //新しいユーザーを登録する
        //Authenticationに追加
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("error: 認証情報保存\(String(describing: error))")
                return
            }
            //Cloud Firestoreに追加
            //AuthenticationのユーザーIDを取得する
            guard let userID = authResult?.user.uid else { return }
            //辞書型
            let documentData = [
                "userName": usertName,
                "email": email,
                "updatedAt": updatedAt,
                "userID": userID,
                "friends": [userID]
            ] as [String : Any]
            
            print("docData:" , documentData)
            //usersのフォルダの中に、userIDが入っていて、その中にdocumentDataが貯蓄されているイメージ
            Firestore.firestore().collection("users").document(userID).setData(documentData)
            
            //自分用のactivityの作成、
            let activityData = [
                "userName": usertName,
            ] as [String : Any]
            Firestore.firestore().collection("activities").document(userID).setData(activityData)
            
            //リセット
            self.userNameTextField.text = ""
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            
            //２つ先へ一気に遷移
            self.toMain(userID: userID)
        }
        
    }
    
    
    @IBAction func alreadyHave(_ sender: Any) {
        userNameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        performSegue(withIdentifier: "toSignIn", sender: nil)
    }
}

// MARK: - Extensions

//TextFieldについてのextension
extension SignUpViewController: UITextFieldDelegate{
    //入力があるたびに呼ばれる・入力判定
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let userNameIsEmpty = userNameTextField.text?.isEmpty ?? true
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        
        if userNameIsEmpty || emailIsEmpty || passwordIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor.lightGray
        }else{
            registerButton.isEnabled = true
            registerButton.backgroundColor = UIColor.orange
        }
    }
    //キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//walkthroughを表示させるためのextension
extension SignUpViewController: EAIntroDelegate {
    
    //walkthroughを表示させるfunc
    func showWalkthrough() {
        
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




