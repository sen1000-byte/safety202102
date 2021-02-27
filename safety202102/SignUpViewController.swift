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

class SignUpViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
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

        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            toMain()
        }
    }
    
    //ログインしていた場合に画面を飛ばす
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func toMain() {
        //２つ先へ一気に遷移
        let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        // 遷移後のViewControllerの配列を作成
        let ar = [self, vc2, vc3]
        // まとめて設定
        self.navigationController?.setViewControllers(ar, animated: false)
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
                "usertName": usertName,
                "email": email,
            ]
            //usersのフォルダの中に、userIDが入っていて、その中にdocumentDataが貯蓄されているイメージ
            Firestore.firestore().collection("users").document(userID).setData(documentData)
            
//            self.performSegue(withIdentifier: "toMain", sender: nil)
            //２つ先へ一気に遷移
            self.toMain()
        }
        
    }
    
    
    @IBAction func alreadyHave(_ sender: Any) {
        performSegue(withIdentifier: "toSignIn", sender: nil)
    }
}


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
