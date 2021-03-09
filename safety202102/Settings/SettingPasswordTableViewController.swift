//
//  SettingPasswordTableViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/09.
//

import UIKit
import FirebaseAuth

class SettingPasswordTableViewController: UITableViewController {
    
    //受け取り用
    var me: AppUser!
    var verifiedPassword: String!
    var whetherVerified: Bool! = nil
    
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var reNewPasswordTextField: UITextField!
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        newPasswordTextField.delegate = self
        reNewPasswordTextField.delegate = self
        //ボタン設定
        doneBarButtonItem.isEnabled = false
        doneBarButtonItem.tintColor = UIColor.darkGray
        doneBarButtonItem.style = .plain
        
        //パスワード認証画面を表示させる
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
        verifyVC.modalPresentationStyle = .fullScreen
        verifyVC.flagToPreVCInt = 2
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
    
    func setUpViews() {
        //見た目
        self.tableView.backgroundColor = UIColor.backGroundGreenColor()

    }
    
    
    @IBAction func done() {
        if whetherVerified == nil {
            print("認証エラー")
            return
        }
        
        if newPasswordTextField.text != reNewPasswordTextField.text {
            //!!!!!!!!エラー分！！！!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            print("パスワードが一致しません。")
            return
        } else {
            
            let password: String = newPasswordTextField.text ?? ""
            
            Auth.auth().currentUser?.updatePassword(to: password) { error in
                //emailのエラー
                if let error = error {
                    //!!!!!!!!!!!!!!!!podのをインストールしたやつでエラーを表示させる！！！！！！！
                    print("パスワードの更新に失敗しました\(error)")
                    return
                }
                //podの完了を出す
                self.navigationController?.popViewController(animated: true)
            }
        }
        
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

extension SettingPasswordTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //入力があるたびに呼ばれる・入力判定
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let newPasswordIsEmpty = newPasswordTextField.text?.isEmpty ?? true
        let reNewPasswordIsEmpty = reNewPasswordTextField.text?.isEmpty ?? true
        if newPasswordIsEmpty || reNewPasswordIsEmpty {
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
