//
//  MainViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/26.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //アカウント登録画面を表示させる
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signUpStoryboard = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        signUpStoryboard.modalPresentationStyle = .fullScreen
        self.present(signUpStoryboard, animated: true, completion: nil)

        // Do any additional setup after loading the view.
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
