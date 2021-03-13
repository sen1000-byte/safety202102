//
//  SignInViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/27.
//

import UIKit
import Firebase
import FirebaseAuth
import PKHUD

class SignInViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInButton: UIButton!
    
    var userDefaults = UserDefaults.standard
    var easyModeBool: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //見た目
        signInButton.layer.cornerRadius = 20
        signInButton.layer.shadowColor = UIColor.lightGray.cgColor
        signInButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        signInButton.layer.shadowRadius = 3
        signInButton.layer.shadowOpacity = 1
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        easyModeBool = userDefaults.bool(forKey: "easyMode")
        
        signInButton.isEnabled = false
        signInButton.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func signIn() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if let error = error {
                print("ログインに失敗\(error)")
                HUD.dimsBackground = true
                HUD.flash(.labeledError(title: "認証エラー", subtitle: "メールアドレス・パスワード(６文字以上)を確認してください"), delay: 1.5)
                return
            }
            let nVC = strongSelf.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            guard let userID = authResult?.user.uid else {return}
            nVC.userID = userID
            self?.navigationController?.pushViewController(nVC, animated: false)
        }
    }
    
    @IBAction func didnotHave() {
        self.navigationController?.popViewController(animated: true)
    }
    

}


extension SignInViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty {
            signInButton.isEnabled = false
            signInButton.backgroundColor = UIColor.lightGray
        }else{
            signInButton.isEnabled = true
            signInButton.backgroundColor = UIColor.orange
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
