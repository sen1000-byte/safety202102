//
//  VerifyPasswordViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/08.
//

import UIKit
import FirebaseAuth
import PKHUD

class VerifyPasswordViewController: UIViewController {
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var verifyButton: UIButton!
    
    var flagToPreVCInt: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //見た目
        setUpViews()
        
        passwordTextField.delegate = self
        
        verifyButton.isEnabled = false
        verifyButton.tintColor = UIColor.darkGray

        // Do any additional setup after loading the view.
    }
    
    func setUpViews() {
        //影付きのボタンの生成
        verifyButton.layer.cornerRadius = 20
        verifyButton.layer.shadowOffset = CGSize(width: 1, height: 1 )
        verifyButton.layer.shadowColor = UIColor.gray.cgColor
        verifyButton.layer.shadowRadius = 5
        verifyButton.layer.shadowOpacity = 1.0

    }
    
    @IBAction func verify() {
        let verifiedPassword = passwordTextField.text ?? ""

        //現在のユーザー情報を取得
        if let user = Auth.auth().currentUser {
            //引数としてcredentialを生成　credential：保証書・証明書という意味
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: verifiedPassword)
            //再認証をする
            user.reauthenticate(with: credential, completion: { authResult, error in
                //認証のエラー
                if let error = error {
                    //!!!!!!podでエラー文章!!!!!!!!!!!!!!
                    HUD.dimsBackground = true
                    HUD.flash(.labeledError(title: "エラー", subtitle: "ユーザー認証に失敗しました。パスワードを確認してください"), delay: 1.5)
                    print("ユーザ認証に失敗しました。\(error)")
                    return
                }
                
                self.prepareToPreVC(whetherVerified: true)
                
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func cancel() {
        
        prepareToPreVC(whetherVerified: false)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //画面遷移用　値を渡すためのメソッド
    func prepareToPreVC(whetherVerified: Bool) {
        
        let preNC = self.presentingViewController as! UINavigationController
        switch flagToPreVCInt {
        
        case 1:    //emailの更新
            let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! SettingEmailTableViewController
            //値代入
            preVC.whetherVerified = whetherVerified
            
        case 2:    //passwordの更新
            let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! SettingPasswordTableViewController
            //値代入
            preVC.whetherVerified = whetherVerified
            
        default:   //エラーor値受け取り失敗
            return
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

extension VerifyPasswordViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //入力があるたびに呼ばれる・入力判定
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        if passwordIsEmpty {
            verifyButton.isEnabled = false
            verifyButton.tintColor = UIColor.darkGray
        }else {
            verifyButton.isEnabled = true
            verifyButton.tintColor = UIColor.orange
        }
    }
    
}
