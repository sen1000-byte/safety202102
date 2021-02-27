//
//  SignInViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/27.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInButton: UIButton!

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
        
        signInButton.isEnabled = false
        signInButton.backgroundColor = UIColor.lightGray

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signIn() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if let error = error {
                print("ログインに失敗\(error)")
                return
            }
            let nVC = self?.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            self?.navigationController?.pushViewController(nVC, animated: false)
//            dismiss(animated: true, completion: { [presentingViewController]() -> Void in
//                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController3")
//                    presentingViewController?.present(viewController!, animated: true, completion: nil)
//                })
//            }
        }
    }
    
    @IBAction func didnotHave() {
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
